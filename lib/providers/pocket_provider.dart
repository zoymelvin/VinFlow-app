import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/pocket_model.dart';
import '../models/limit_model.dart';

class PocketProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Pocket> _pockets = [];
  
  double _todayIncome = 0.0;
  double _todayExpense = 0.0;
  bool _isListening = false;

  List<Pocket> get pockets => [..._pockets];
  double get todayIncome => _todayIncome;
  double get todayExpense => _todayExpense;

  double get totalBalance {
    return _pockets.fold(0.0, (sum, item) => sum + item.balance);
  }

  void fetchPockets() {
    if (_isListening) return;
    _isListening = true;

    _db.collection('pockets').snapshots().listen((snapshot) {
      _pockets = snapshot.docs.map((doc) {
        final data = doc.data();
        return Pocket(
          id: doc.id,
          name: data['name'] ?? '',
          balance: (data['balance'] ?? 0).toDouble(),
          icon: IconData(
              data['iconCode'], 
              fontFamily: 'CupertinoIcons', 
              fontPackage: 'cupertino_icons'),
          color: Color(data['colorValue']),
        );
      }).toList();
      
      _calculateTodaySummary();
      notifyListeners();
    });
  }

  Future<void> _calculateTodaySummary() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final snapshot = await _db.collectionGroup('transactions')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      double income = 0.0;
      double expense = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        if (data['type'] == 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }

      _todayIncome = income;
      _todayExpense = expense;
      notifyListeners();
    } catch (e) {
      debugPrint("Error calculating summary: $e");
    }
  }

  /// LOGIKA NOTIFIKASI: Mengirim data ke koleksi 'notifications'
  Future<void> _sendToFirestore({
    required String title, 
    required String message, 
    required String type
  }) async {
    await _db.collection('notifications').add({
      'title': title,
      'message': message,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// NEW: Notifikasi Berhasil Transaksi
  Future<void> _sendTransactionNotification({
    required String type, // 'income', 'expense', 'transfer'
    required double amount,
    required String pocketName,
    String? category,
    String? targetPocketName,
    String? title,
  }) async {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    String formattedAmount = currency.format(amount);
    
    String notifTitle = "";
    String notifMessage = "";

    if (type == 'income') {
      notifTitle = "💰 Saldo Masuk!";
      notifMessage = "Berhasil menambah $formattedAmount ke kantong $pocketName. ${title != null ? 'Judul: $title' : ''}";
    } else if (type == 'expense') {
      notifTitle = "💸 Transaksi Berhasil";
      notifMessage = "Berhasil mengeluarkan $formattedAmount dari kantong $pocketName untuk ${category ?? 'Lainnya'}.";
    } else if (type == 'transfer') {
      notifTitle = "🔄 Transfer Sukses";
      notifMessage = "Berhasil mengirim $formattedAmount dari $pocketName ke $targetPocketName.";
    }

    await _sendToFirestore(title: notifTitle, message: notifMessage, type: type);
  }

  /// LOGIKA NOTIFIKASI LIMIT: Pengecekan ambang batas saldo limit
  Future<void> _checkAndSendNotification(LimitModel limit, double currentSpent) async {
    double remainingPercent = ((limit.limitAmount - currentSpent) / limit.limitAmount);
    
    if (remainingPercent <= 0.15 && !limit.hasSentCritical) {
      await _sendToFirestore(
        title: "🚨 Batas Kritis!",
        message: "Waspada! Saldo ${limit.title} tersisa kurang dari 15%. Segera atur pengeluaranmu.",
        type: "critical"
      );
      await _db.collection('limits').doc(limit.id).update({'hasSentCritical': true});
    } 
    else if (remainingPercent <= 0.40 && !limit.hasSentWarning) {
      await _sendToFirestore(
        title: "⚠️ Anggaran Menipis!",
        message: "Sisa saldo untuk ${limit.title} tinggal 40% lagi. Yuk, lebih hemat!",
        type: "warning"
      );
      await _db.collection('limits').doc(limit.id).update({'hasSentWarning': true});
    }
  }

  Future<void> _updateLimitUsage(String category, String pocketId, double amount) async {
    try {
      final limitDocs = await _db.collection('limits').get();
      final now = DateTime.now();

      for (var doc in limitDocs.docs) {
        final data = doc.data();
        final limit = LimitModel.fromFirestore(data, doc.id);
        
        if (now.isAfter(limit.startDate) && now.isBefore(limit.endDate)) {
          bool isMatch = false;
          if (limit.targetCategory == category) isMatch = true;
          if (limit.targetPocketId == pocketId) isMatch = true;

          if (isMatch) {
            double newSpent = limit.totalSpent + amount;
            await _db.collection('limits').doc(doc.id).update({
              'totalSpent': FieldValue.increment(amount),
            });
            await _checkAndSendNotification(limit, newSpent);
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal update usage limit: $e");
    }
  }

  Future<void> addPocket(String name, double balance, IconData icon, Color color) async {
    await _db.collection('pockets').add({
      'name': name,
      'balance': balance,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> topUpBalance(
    String pocketId, 
    double currentBalance, 
    double amount, 
    {String? title, String? imageUrl, String? category}
  ) async {
    try {
      final WriteBatch batch = _db.batch();
      DocumentReference pocketRef = _db.collection('pockets').doc(pocketId);
      DocumentReference transRef = pocketRef.collection('transactions').doc(); 

      batch.update(pocketRef, {'balance': currentBalance + amount});
      batch.set(transRef, {
        'title': title ?? 'Isi Saldo',
        'amount': amount,
        'type': 'income', 
        'category': category ?? 'Lainnya',
        'pocketId': pocketId, 
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Trigger Notifikasi Uang Masuk
      final pocket = _pockets.firstWhere((p) => p.id == pocketId);
      await _sendTransactionNotification(
        type: 'income',
        amount: amount,
        pocketName: pocket.name,
        title: title
      );

      _calculateTodaySummary(); 
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> withdrawBalance(
    String pocketId, 
    double currentBalance, 
    double amount, 
    {String? title, String? imageUrl, String? category}
  ) async {
    try {
      final WriteBatch batch = _db.batch();
      DocumentReference pocketRef = _db.collection('pockets').doc(pocketId);
      DocumentReference transRef = pocketRef.collection('transactions').doc(); 

      batch.update(pocketRef, {'balance': currentBalance - amount});
      batch.set(transRef, {
        'title': title ?? 'Pengeluaran',
        'amount': amount,
        'type': 'expense', 
        'category': category ?? 'Lainnya',
        'pocketId': pocketId, 
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Trigger Notifikasi Uang Keluar
      final pocket = _pockets.firstWhere((p) => p.id == pocketId);
      await _sendTransactionNotification(
        type: 'expense',
        amount: amount,
        pocketName: pocket.name,
        category: category
      );

      await _updateLimitUsage(category ?? 'Lainnya', pocketId, amount);
      _calculateTodaySummary(); 
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deletePocket(String pocketId) async {
    try {
      final transactions = await _db.collection('pockets').doc(pocketId).collection('transactions').get();
      final WriteBatch batch = _db.batch();
      for (var doc in transactions.docs) { batch.delete(doc.reference); }
      batch.delete(_db.collection('pockets').doc(pocketId));
      await batch.commit();
      await _calculateTodaySummary();
      notifyListeners();
    } catch (e) { debugPrint("Delete Error: $e"); }
  }

  Future<bool> transferBalance({
    required Pocket fromPocket,
    required Pocket toPocket,
    required double amount,
  }) async {
    try {
      final fromRef = _db.collection('pockets').doc(fromPocket.id);
      final toRef = _db.collection('pockets').doc(toPocket.id);

      await _db.runTransaction((transaction) async {
        transaction.update(fromRef, {'balance': fromPocket.balance - amount});
        transaction.update(toRef, {'balance': toPocket.balance + amount});

        final fromTransRef = fromRef.collection('transactions').doc();
        transaction.set(fromTransRef, {
          'title': 'Transfer ke ${toPocket.name}',
          'amount': amount,
          'type': 'expense',
          'category': 'Transfer',
          'pocketId': fromPocket.id,
          'timestamp': FieldValue.serverTimestamp(),
        });

        final toTransRef = toRef.collection('transactions').doc();
        transaction.set(toTransRef, {
          'title': 'Terima dari ${fromPocket.name}',
          'amount': amount,
          'type': 'income',
          'category': 'Transfer',
          'pocketId': toPocket.id,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      // Trigger Notifikasi Transfer
      await _sendTransactionNotification(
        type: 'transfer',
        amount: amount,
        pocketName: fromPocket.name,
        targetPocketName: toPocket.name
      );

      await _updateLimitUsage('Transfer', fromPocket.id, amount);
      _calculateTodaySummary(); 
      return true;
    } catch (e) {
      return false;
    }
  }
}