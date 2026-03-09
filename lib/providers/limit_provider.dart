import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/limit_model.dart';
import 'dart:async';

class LimitProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<LimitModel> _limits = [];
  bool _isLoading = false;
  StreamSubscription? _limitSubscription;

  List<LimitModel> get limits => _limits;
  bool get isLoading => _isLoading;

  void listenToLimits() {
    _isLoading = true;
    _limitSubscription?.cancel();
    
    _limitSubscription = _db.collection('limits').snapshots().listen((snapshot) {
      _limits = snapshot.docs.map((doc) => LimitModel.fromFirestore(doc.data(), doc.id)).toList();
      _isLoading = false;
      
      // TRIGGER REBUILD: Pastikan UI tahu ada data baru untuk dihitung
      notifyListeners(); 
    }, onError: (e) {
      _isLoading = false;
      notifyListeners();
    });
  }

  // Fungsi kalkulasi yang lebih kuat dengan filter ganda
  Future<double> getRemainingAmount(LimitModel limit) async {
    double spent = 0;
    try {
      final snapshot = await _db.collectionGroup('transactions')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(limit.startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(limit.endDate))
          .where('type', isEqualTo: 'expense')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Periksa Kategori
        bool matchCategory = limit.targetCategory != null && 
                            data['category'] == limit.targetCategory;
        
        // Periksa ID Kantong (Gunakan field pocketId yang sudah kita tanam)
        String? txPocketId = data['pocketId'] ?? doc.reference.parent.parent?.id;
        bool matchPocket = limit.targetPocketId != null && txPocketId == limit.targetPocketId;

        if (matchCategory || matchPocket) {
          spent += (data['amount'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      debugPrint("Kalkulasi Limit Error: $e");
    }
    
    double remaining = limit.limitAmount - spent;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> addLimit(LimitModel limit) async {
    await _db.collection('limits').add(limit.toFirestore());
  }

  Future<void> deleteLimit(String id) async {
    await _db.collection('limits').doc(id).delete();
  }

  @override
  void dispose() {
    _limitSubscription?.cancel();
    super.dispose();
  }
}