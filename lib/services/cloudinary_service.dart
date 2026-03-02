import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // DISESUAIKAN: Berdasarkan gambar kredensial dashboard kamu
  final String _cloudName = "dznzuqsb8"; 
  
  // PENTING: Ganti ini dengan nama 'Unsigned' upload preset yang kamu buat di settings Cloudinary
  final String _uploadPreset = "ml_default"; 

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      String url = "https://api.cloudinary.com/v1_1/$_cloudName/image/upload";
      
      // Membaca bytes agar kompatibel dengan Flutter Web & Mobile
      final bytes = await imageFile.readAsBytes();

      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: imageFile.name),
        "upload_preset": _uploadPreset,
      });

      Response response = await Dio().post(url, data: formData);

      if (response.statusCode == 200) {
        // Mengembalikan URL permanen yang aman (https)
        return response.data["secure_url"];
      }
    } catch (e) {
      print("Cloudinary Upload Error: $e");
    }
    return null;
  }
}