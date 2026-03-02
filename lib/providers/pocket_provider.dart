import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/pocket_model.dart';

class PocketProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Pocket> _pockets = [];
  
  // Variabel lokal untuk menyimpan ringkasan hari ini
  double _todayIncome = 0.0;
  double _todayExpense = 0.0;

  // Flag untuk mencegah double listener
  bool _isListening = false;

  List<Pocket> get pockets => [..._pockets];
  double get todayIncome => _todayIncome;
  double get todayExpense => _todayExpense;

  double get totalBalance {
    return _pockets.fold(0.0, (sum, item) => sum + item.balance);
  }

  /// Memulai sinkronisasi data Kantong dan Transaksi secara Realtime.
  /// Dipanggil di main.dart menggunakan operator cascade (..fetchPockets())
  void fetchPockets() {
    if (_isListening) return;
    _isListening = true;

    // 1. Listen ke data Kantong secara Realtime
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
      
      // Setelah data kantong berubah, hitung ulang ringkasan hari ini
      _calculateTodaySummary();
      notifyListeners();
    });
  }

  /// Fungsi internal untuk menghitung pemasukan & pengeluaran hari ini (WIB)
  /// Menggunakan collectionGroup agar mencakup semua transaksi dari semua kantong
  Future<void> _calculateTodaySummary() async {
    try {
      final now = DateTime.now();
      // Menetapkan batas awal hari (00:00:00)
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

  /// Menambah kantong baru ke Firestore
  Future<void> addPocket(String name, double balance, IconData icon, Color color) async {
    await _db.collection('pockets').add({
      'name': name,
      'balance': balance,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Menambah saldo pada kantong spesifik dan mencatat transaksi pemasukan
  Future<bool> topUpBalance(String pocketId, double currentBalance, double amount, {String? title, String? imageUrl}) async {
    try {
      final WriteBatch batch = _db.batch();
      DocumentReference pocketRef = _db.collection('pockets').doc(pocketId);
      DocumentReference transRef = pocketRef.collection('transactions').doc(); 

      batch.update(pocketRef, {'balance': currentBalance + amount});
      batch.set(transRef, {
        'title': title ?? 'Isi Saldo',
        'amount': amount,
        'type': 'income', 
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      _calculateTodaySummary(); // Segera refresh summary harian
      return true;
    } catch (e) {
      debugPrint("TopUp Error: $e");
      return false;
    }
  }

  /// Mengurangi saldo pada kantong spesifik dan mencatat transaksi pengeluaran
  Future<bool> withdrawBalance(String pocketId, double currentBalance, double amount, {String? title, String? imageUrl}) async {
    try {
      final WriteBatch batch = _db.batch();
      DocumentReference pocketRef = _db.collection('pockets').doc(pocketId);
      DocumentReference transRef = pocketRef.collection('transactions').doc(); 

      batch.update(pocketRef, {'balance': currentBalance - amount});
      batch.set(transRef, {
        'title': title ?? 'Pengeluaran',
        'amount': amount,
        'type': 'expense', 
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      _calculateTodaySummary(); // Segera refresh summary harian
      return true;
    } catch (e) {
      debugPrint("Withdraw Error: $e");
      return false;
    }
  }

  /// Menghapus kantong beserta seluruh sub-koleksi transaksi di dalamnya.
  /// Mencegah data transaksi "yatim piatu" yang mengotori summary harian.
  Future<void> deletePocket(String pocketId) async {
    try {
      // 1. Ambil semua dokumen transaksi di dalam sub-koleksi kantong ini
      final transactions = await _db
          .collection('pockets')
          .doc(pocketId)
          .collection('transactions')
          .get();

      final WriteBatch batch = _db.batch();

      // 2. Tambahkan setiap transaksi ke batch delete
      for (var doc in transactions.docs) {
        batch.delete(doc.reference);
      }

      // 3. Tambahkan dokumen kantong induk ke batch delete
      batch.delete(_db.collection('pockets').doc(pocketId));

      // 4. Commit penghapusan massal (atomik)
      await batch.commit();
      
      // 5. Hitung ulang ringkasan agar Dashboard terupdate menjadi Rp0 jika perlu
      await _calculateTodaySummary();
      notifyListeners();
      
      debugPrint("Pocket and its transactions deleted successfully");
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  /// Transfer saldo antar kantong dengan pencatatan transaksi ganda (Income & Expense)
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
          'timestamp': FieldValue.serverTimestamp(),
        });

        final toTransRef = toRef.collection('transactions').doc();
        transaction.set(toTransRef, {
          'title': 'Terima dari ${fromPocket.name}',
          'amount': amount,
          'type': 'income',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
      _calculateTodaySummary(); // Segera refresh summary harian
      return true;
    } catch (e) {
      debugPrint("Transfer Gagal: $e");
      return false;
    }
  }
}