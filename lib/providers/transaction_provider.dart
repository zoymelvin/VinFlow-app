import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import '../models/pocket_model.dart';
import './pocket_provider.dart';

class TransactionProvider with ChangeNotifier {
  final CloudinaryService _cloudinary = CloudinaryService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _pickedImage;
  XFile? get pickedImage => _pickedImage;

  void setPickedImage(XFile? image) {
    _pickedImage = image;
    notifyListeners();
  }

  Future<bool> executeTransaction({
    required PocketProvider pocketProv,
    required Pocket selectedPocket,
    required String type,
    required String amountText,
    required String category,
    required String note,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _cloudinary.uploadImage(_pickedImage!);
      }

      final amount = double.parse(amountText.replaceAll('.', ''));
      final title = note.isEmpty ? category : note;

      bool success;
      if (type == 'income') {
        success = await pocketProv.topUpBalance(
          selectedPocket.id, 
          selectedPocket.balance, 
          amount, 
          title: title, 
          imageUrl: imageUrl,
          category: category,
        );
      } else {
        success = await pocketProv.withdrawBalance(
          selectedPocket.id, 
          selectedPocket.balance, 
          amount, 
          title: title, 
          imageUrl: imageUrl,
          category: category,
        );
      }
      
      if (success) _pickedImage = null; // Reset image on success
      return success;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}