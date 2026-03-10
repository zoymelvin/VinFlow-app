import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/target_model.dart';
import 'dart:async';

class TargetProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<TargetModel> _targets = [];
  bool _isLoading = false;
  StreamSubscription? _targetSubscription;

  List<TargetModel> get targets => _targets;
  bool get isLoading => _isLoading;

  TargetProvider() {
    fetchTargets();
  }

  void fetchTargets() {
    _isLoading = true;
    
    // Batalkan subscription lama jika ada
    _targetSubscription?.cancel();

    // Gunakan snapshots dengan includeMetadataChanges untuk Web agar lebih responsif
    _targetSubscription = _db
        .collection('targets')
        .snapshots(includeMetadataChanges: true)
        .listen((snap) {
      _targets = snap.docs.map((doc) => TargetModel.fromFirestore(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error fetching targets: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addTarget(TargetModel target) async {
    try {
      await _db.collection('targets').add(target.toFirestore());
      // Tidak perlu panggil fetchTargets karena snapshots otomatis mendeteksi
    } catch (e) {
      debugPrint("Gagal menambah target: $e");
    }
  }

  Future<void> deleteTarget(String id) async {
    try {
      await _db.collection('targets').doc(id).delete();
    } catch (e) {
      debugPrint("Gagal menghapus target: $e");
    }
  }

  @override
  void dispose() {
    _targetSubscription?.cancel();
    super.dispose();
  }
}