import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill_model.dart';
import 'dart:async';

class BillProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<BillModel> _activeBills = [];
  List<BillModel> _historyBills = [];
  bool _isLoading = false;
  int _updateTick = 0;

  List<BillModel> get activeBills => _activeBills;
  List<BillModel> get historyBills => _historyBills;
  bool get isLoading => _isLoading;
  int get updateTick => _updateTick;

  StreamSubscription? _activeSub;
  StreamSubscription? _historySub;

  BillProvider() {
    initRealtimeListeners();
  }

  // LOGIKA BARU: Inisialisasi Listener dengan Re-sync Otomatis
  void initRealtimeListeners() {
    _activeSub?.cancel();
    _historySub?.cancel();

    // Listener Tagihan Aktif
    _activeSub = _db.collection('bills')
        .where('isPaid', isEqualTo: false)
        .orderBy('dueDate')
        .snapshots(includeMetadataChanges: true)
        .listen((snap) {
      _activeBills = snap.docs.map((doc) => BillModel.fromFirestore(doc.data(), doc.id)).toList();
      _isLoading = false;
      _triggerUIRefresh();
    });

    // Listener Riwayat
    _historySub = _db.collection('bill_history')
        .orderBy('dueDate', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen((snap) {
      _historyBills = snap.docs.map((doc) => BillModel.fromFirestore(doc.data(), doc.id)).toList();
      _triggerUIRefresh();
    });
  }

  // LOGIKA PUSAT: Memaksa Flutter Web untuk Sadar Ada Perubahan Data
  void _triggerUIRefresh() {
    _updateTick++;
    // Memastikan notifyListeners dipanggil di frame berikutnya agar tidak terjadi tabrakan render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // LOGIKA BARU: Fungsi Ambil Data Manual (Pull Method)
  Future<void> manualFetch() async {
    final active = await _db.collection('bills')
        .where('isPaid', isEqualTo: false)
        .orderBy('dueDate')
        .get(const GetOptions(source: Source.serverAndCache));
    
    _activeBills = active.docs.map((doc) => BillModel.fromFirestore(doc.data(), doc.id)).toList();

    final history = await _db.collection('bill_history')
        .orderBy('dueDate', descending: true)
        .get(const GetOptions(source: Source.serverAndCache));
        
    _historyBills = history.docs.map((doc) => BillModel.fromFirestore(doc.data(), doc.id)).toList();
    
    _triggerUIRefresh();
  }

  Future<void> addBill(BillModel bill) async {
    try {
      await _db.collection('bills').add(bill.toFirestore());
      // Tunggu sebentar untuk sinkronisasi server, lalu tarik paksa
      await Future.delayed(const Duration(milliseconds: 800));
      await manualFetch();
    } catch (e) {
      debugPrint("Gagal tambah: $e");
    }
  }

  Future<void> processPayment(BillModel bill, String pocketName) async {
    try {
      final batch = _db.batch();
      final historyRef = _db.collection('bill_history').doc();
      
      batch.set(historyRef, {
        ...bill.toFirestore(),
        'isPaid': true,
        'paidWithPocket': pocketName,
        'paidAt': FieldValue.serverTimestamp(),
      });

      if (bill.isRecurring) {
        DateTime nextDate;
        if (bill.isIntervalMode) {
          nextDate = DateTime.now().add(Duration(days: bill.intervalDays));
        } else {
          DateTime current = bill.dueDate;
          DateTime lastDayNextMonth = DateTime(current.year, current.month + 2, 0);
          nextDate = current.day > lastDayNextMonth.day 
              ? lastDayNextMonth 
              : DateTime(current.year, current.month + 1, current.day);
        }
        batch.update(_db.collection('bills').doc(bill.id), {
          'dueDate': Timestamp.fromDate(nextDate),
          'isPaid': false,
        });
      } else {
        batch.delete(_db.collection('bills').doc(bill.id));
      }

      await batch.commit();
      await Future.delayed(const Duration(milliseconds: 800));
      await manualFetch();
    } catch (e) {
      debugPrint("Gagal proses bayar: $e");
    }
  }

  Future<void> deleteBill(String id, bool isHistory) async {
    String collection = isHistory ? 'bill_history' : 'bills';
    await _db.collection(collection).doc(id).delete();
    await Future.delayed(const Duration(milliseconds: 500));
    await manualFetch();
  }

  @override
  void dispose() {
    _activeSub?.cancel();
    _historySub?.cancel();
    super.dispose();
  }
}