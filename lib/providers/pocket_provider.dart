import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/pocket_model.dart';

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

  Future<void> addPocket(String name, double balance, IconData icon, Color color) async {
    await _db.collection('pockets').add({
      'name': name,
      'balance': balance,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // FIX: Menambahkan field pocketId ke transaksi masuk
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
        'pocketId': pocketId, // PENTING UNTUK LIMIT
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      _calculateTodaySummary(); 
      return true;
    } catch (e) {
      debugPrint("TopUp Error: $e");
      return false;
    }
  }

  // FIX: Menambahkan field pocketId ke transaksi keluar
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
        'pocketId': pocketId, // PENTING UNTUK LIMIT
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      _calculateTodaySummary(); 
      return true;
    } catch (e) {
      debugPrint("Withdraw Error: $e");
      return false;
    }
  }

  Future<void> deletePocket(String pocketId) async {
    try {
      final transactions = await _db
          .collection('pockets')
          .doc(pocketId)
          .collection('transactions')
          .get();

      final WriteBatch batch = _db.batch();
      for (var doc in transactions.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_db.collection('pockets').doc(pocketId));

      await batch.commit();
      await _calculateTodaySummary();
      notifyListeners();
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
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
      _calculateTodaySummary(); 
      return true;
    } catch (e) {
      debugPrint("Transfer Gagal: $e");
      return false;
    }
  }
}