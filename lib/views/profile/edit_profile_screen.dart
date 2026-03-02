import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Field Baru
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  
  String _selectedCountry = "Indonesia";
  String _existingImageUrl = "";
  File? _imageFile;

  final List<String> _countries = ["Indonesia", "Malaysia", "Singapore", "Japan", "Australia", "USA"];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final doc = await FirebaseFirestore.instance.collection('profile').doc('user_profile').get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['name'] ?? "";
        _emailController.text = data['email'] ?? "";
        _phoneController.text = data['phone'] ?? "";
        _bioController.text = data['bio'] ?? "";
        _selectedCountry = data['country'] ?? "Indonesia";
        _existingImageUrl = data['profileImageUrl'] ?? "";
      });
    }
  }

  // LOGIKA PEMILIHAN FOTO (Disamakan dengan Catat Transaksi)
  void _showImageSourceActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Lampirkan Foto"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text("Ambil Foto Kamera"),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text("Pilih dari Galeri"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 60,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveData() async {
    final provider = context.read<ProfileProvider>();
    String? newImageUrl;

    if (_imageFile != null) {
      newImageUrl = await provider.uploadImage(_imageFile!);
    }

    await provider.updateFullProfile({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(), // Simpan Email
      'phone': _phoneController.text.trim(),
      'country': _selectedCountry,
      'bio': _bioController.text.trim(),
      'profileImageUrl': newImageUrl ?? _existingImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: CupertinoButton(
          child: const Icon(CupertinoIcons.back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Edit Profil", 
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1E293B), fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // PREVIEW FOTO (CLOUDINARY & LOCAL)
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 4),
                          color: const Color(0xFFF8FAFC),
                          image: _imageFile != null 
                            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                            : (_existingImageUrl.isNotEmpty 
                                ? DecorationImage(image: NetworkImage(_existingImageUrl), fit: BoxFit.cover)
                                : null),
                        ),
                        child: (_imageFile == null && _existingImageUrl.isEmpty)
                          ? const Icon(CupertinoIcons.person_fill, size: 50, color: Color(0xFFCBD5E1))
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showImageSourceActionSheet(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF007BFF), shape: BoxShape.circle),
                            child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),

                _buildLabel("Nama Lengkap"),
                _buildTextField(_nameController, "Masukkan nama kamu", CupertinoIcons.person),

                _buildLabel("Email"), // Field Baru
                _buildTextField(_emailController, "zoymelvin04@gmail.com", CupertinoIcons.mail, keyboardType: TextInputType.emailAddress),

                _buildLabel("Nomor Telepon"),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(
                    hint: "812xxx", 
                    icon: CupertinoIcons.phone,
                    prefixText: "+62 ",
                  ),
                ),

                _buildLabel("Negara"),
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  icon: const Icon(CupertinoIcons.chevron_down, size: 16),
                  decoration: _inputDecoration(hint: "", icon: CupertinoIcons.globe),
                  items: _countries.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => _selectedCountry = newValue!);
                  },
                ),

                _buildLabel("Bio Singkat"),
                _buildTextField(_bioController, "Ceritakan sedikit...", CupertinoIcons.doc_text, maxLines: 3, topIcon: true),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isLoading 
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Text("Simpan Profil", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (isLoading) Container(color: Colors.white54, child: const Center(child: CupertinoActivityIndicator())),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 20),
      child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, String? prefixText, bool topIcon = false}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold),
      prefixIcon: Padding(
        padding: EdgeInsets.only(bottom: topIcon ? 45 : 0), // Memperbaiki posisi ikon bio agar di atas
        child: Icon(icon, color: const Color(0xFF64748B), size: 20),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1, bool topIcon = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: _inputDecoration(hint: hint, icon: icon, topIcon: topIcon),
    );
  }
}