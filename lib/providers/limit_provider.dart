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
      notifyListeners(); 
    }, onError: (e) {
      _isLoading = false;
      notifyListeners();
    });
  }

  // Fungsi memperbarui nominal limit (Emergency Top-Up)
  Future<void> updateLimitAmount(String limitId, double additionalAmount, double currentLimit) async {
    try {
      await _db.collection('limits').doc(limitId).update({
        'limitAmount': currentLimit + additionalAmount,
        // Reset flag notifikasi agar user dapat peringatan lagi jika nanti menipis kembali
        'hasSentWarning': false, 
        'hasSentCritical': false,
      });
    } catch (e) {
      debugPrint("Gagal update limit: $e");
    }
  }

  double getRemainingAmountSync(LimitModel limit) {
    double remaining = limit.limitAmount - limit.totalSpent;
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