import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // KONFIGURASI CLOUDINARY (Pastikan data ini benar)
  final cloudinary = CloudinaryPublic(
    'your_cloud_name', 
    'your_upload_preset', 
    cache: false
  );

  // Logika upload yang disamakan dengan fitur transaksi
  Future<String?> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path, 
          folder: 'profile_photos',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  Future<void> updateFullProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Menggunakan ID dokumen 'user_profile' sesuai gambar database
      await _db.collection('profile').doc('user_profile').set(
        data, 
        SetOptions(merge: true)
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}