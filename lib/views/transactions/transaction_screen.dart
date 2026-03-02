import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../models/pocket_model.dart';
import '../../providers/pocket_provider.dart';
import '../../services/cloudinary_service.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final CloudinaryService _cloudinary = CloudinaryService();
  
  String _type = 'expense'; 
  Pocket? _selectedPocket;
  XFile? _pickedImage;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
  {'name': 'Belanja', 'icon': CupertinoIcons.bag_fill, 'color': Colors.orange},
  {'name': 'Makan', 'icon': CupertinoIcons.cart_fill, 'color': Colors.red},
  {'name': 'Transport', 'icon': CupertinoIcons.bus, 'color': Colors.blue},
  {'name': 'Hobi', 'icon': CupertinoIcons.gamecontroller_fill, 'color': Colors.purple},
  {'name': 'Kuota', 'icon': CupertinoIcons.wifi, 'color': Colors.indigo}, 
  {'name': 'Gaji', 'icon': CupertinoIcons.money_dollar_circle_fill, 'color': Colors.green},
  {'name': 'Lainnya', 'icon': CupertinoIcons.ellipsis_circle_fill, 'color': Colors.grey},
];
  String _selectedCategory = 'Lainnya';

  // FIX: Fungsi Ambil Foto (Aktifkan Kamera & Galeri)
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Lampirkan Foto"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
              if (image != null) setState(() => _pickedImage = image);
            },
            child: const Text("Ambil Foto Kamera"),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
              if (image != null) setState(() => _pickedImage = image);
            },
            child: const Text("Pilih dari Galeri"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Pilih Kategori', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        actions: _categories.map((cat) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _selectedCategory = cat['name']);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'], color: cat['color'], size: 20),
                const SizedBox(width: 12),
                Text(cat['name'], style: GoogleFonts.plusJakartaSans(color: Colors.black87, fontSize: 16)),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty || _selectedPocket == null) {
      _showError("Mohon isi nominal dan pilih kantong.");
      return;
    }

    setState(() => _isLoading = true);

    String? imageUrl;
    if (_pickedImage != null) {
      imageUrl = await _cloudinary.uploadImage(_pickedImage!);
    }

    final amount = double.parse(_amountController.text.replaceAll('.', ''));
    final title = _noteController.text.isEmpty ? _selectedCategory : _noteController.text;
    
    final pocketProvider = Provider.of<PocketProvider>(context, listen: false);

    bool success;
    if (_type == 'income') {
      success = await pocketProvider.topUpBalance(
        _selectedPocket!.id, _selectedPocket!.balance, amount, title: title, imageUrl: imageUrl,
      );
    } else {
      success = await pocketProvider.withdrawBalance(
        _selectedPocket!.id, _selectedPocket!.balance, amount, title: title, imageUrl: imageUrl,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pockets = context.watch<PocketProvider>().pockets;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text("Catat Transaksi", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeSwitcher(),
                const SizedBox(height: 24),

                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nominal Transaksi", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                      CupertinoTextField(
                        controller: _amountController,
                        placeholder: "0",
                        keyboardType: TextInputType.number,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1),
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, _ThousandsSeparatorInputFormatter()],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text("Pilih Kantong", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                _buildPocketSelector(pockets),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Kategori", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 12),
                          _buildCategoryButton(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildImagePickerBox(),
                  ],
                ),

                const SizedBox(height: 24),
                Text("Catatan Tambahan", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: _noteController,
                  placeholder: "Beli barang apa hari ini?",
                  padding: const EdgeInsets.all(16),
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Positioned(bottom: 24, left: 24, right: 24, child: _buildSubmitButton()),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }

  Widget _buildTypeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          _typeBtn("expense", "Pengeluaran", Colors.red),
          _typeBtn("income", "Pemasukan", Colors.green),
        ],
      ),
    );
  }

  Widget _typeBtn(String t, String label, Color color) {
    bool isSelected = _type == t;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)] : [],
          ),
          child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? color : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildPocketSelector(List<Pocket> pockets) {
    if (pockets.isEmpty) return const Text("Belum ada kantong");
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: pockets.length,
        itemBuilder: (context, index) {
          final p = pockets[index];
          bool isSelected = _selectedPocket?.id == p.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedPocket = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? p.color : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? p.color : const Color(0xFFE2E8F0)),
                boxShadow: isSelected ? [BoxShadow(color: p.color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(p.icon, color: isSelected ? Colors.white : p.color, size: 20),
                  const SizedBox(height: 4),
                  Text(p.name, style: GoogleFonts.plusJakartaSans(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w700, fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryButton() {
    final cat = _categories.firstWhere((c) => c['name'] == _selectedCategory);
    return GestureDetector(
      onTap: _showCategoryPicker,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(cat['icon'], color: cat['color'], size: 18),
            const SizedBox(width: 10),
            Text(_selectedCategory, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            const Icon(CupertinoIcons.chevron_down, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerBox() {
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          Container(
            width: 75, height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: _pickedImage != null 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: kIsWeb 
                    ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                    : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                )
              : const Icon(CupertinoIcons.camera_fill, color: Colors.grey, size: 24),
          ),
          const SizedBox(height: 4),
          Text(_pickedImage != null ? "Ganti" : "Foto", style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _isLoading ? null : _saveTransaction,
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isLoading ? Colors.grey : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: _isLoading 
          ? const CupertinoActivityIndicator(color: Colors.white)
          : Text("Simpan Transaksi", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
      ),
    );
  }

  void _showError(String msg) {
    showCupertinoDialog(
      context: context,
      builder: (c) => CupertinoAlertDialog(
        title: const Text("Peringatan"),
        content: Text(msg),
        actions: [CupertinoDialogAction(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String newValueText = newValue.text.replaceAll('.', '');
    double? value = double.tryParse(newValueText);
    if (value == null) return oldValue;
    final formatter = NumberFormat.decimalPattern('id');
    String newText = formatter.format(value);
    return newValue.copyWith(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}