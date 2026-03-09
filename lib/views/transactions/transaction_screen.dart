import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../providers/pocket_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/pocket_model.dart';
import './widgets/type_switcher.dart';
import './widgets/pocket_selector.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});
  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  Pocket? _selectedPocket;
  String _selectedCategory = 'Lainnya';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Belanja', 'icon': CupertinoIcons.bag_fill, 'color': Colors.orange},
    {'name': 'Makan', 'icon': CupertinoIcons.cart_fill, 'color': Colors.red},
    {'name': 'Transport', 'icon': CupertinoIcons.bus, 'color': Colors.blue},
    {'name': 'Hobi', 'icon': CupertinoIcons.gamecontroller_fill, 'color': Colors.purple},
    {'name': 'Kuota', 'icon': CupertinoIcons.wifi, 'color': Colors.indigo},
    {'name': 'Gaji', 'icon': CupertinoIcons.money_dollar_circle_fill, 'color': Colors.green},
    {'name': 'Lainnya', 'icon': CupertinoIcons.ellipsis_circle_fill, 'color': Colors.grey},
  ];

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Pilih Kategori', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        actions: _categories.map((cat) => CupertinoActionSheetAction(
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
        )).toList(),
        cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.red))),
      ),
    );
  }

  void _pickImage(TransactionProvider txProv) async {
    final ImagePicker picker = ImagePicker();
    showCupertinoModalPopup(context: context, builder: (context) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(onPressed: () async {
          Navigator.pop(context);
          final img = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
          txProv.setPickedImage(img);
        }, child: const Text("Ambil Foto Kamera")),
        CupertinoActionSheetAction(onPressed: () async {
          Navigator.pop(context);
          final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
          txProv.setPickedImage(img);
        }, child: const Text("Pilih dari Galeri")),
      ],
      cancelButton: CupertinoActionSheetAction(isDestructiveAction: true, onPressed: () => Navigator.pop(context), child: const Text("Batal")),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pockets = context.watch<PocketProvider>().pockets;
    final txProv = context.watch<TransactionProvider>();

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
                TypeSwitcher(currentType: _type, onTypeChanged: (val) => setState(() => _type = val)),
                const SizedBox(height: 24),
                _buildAmountField(),
                const SizedBox(height: 24),
                Text("Pilih Kantong", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                PocketSelector(pockets: pockets, selectedPocket: _selectedPocket, onSelected: (p) => setState(() => _selectedPocket = p)),
                const SizedBox(height: 24),
                _buildCategoryAndPhotoRow(txProv),
                const SizedBox(height: 24),
                Text("Catatan Tambahan", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                _buildNoteField(),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Positioned(bottom: 24, left: 24, right: 24, child: _buildSubmitButton(txProv)),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ]),
    );
  }

  Widget _buildCategoryAndPhotoRow(TransactionProvider txProv) {
    final cat = _categories.firstWhere((c) => c['name'] == _selectedCategory);
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Kategori", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showCategoryPicker,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(children: [
              Icon(cat['icon'], color: cat['color'], size: 18),
              const SizedBox(width: 10),
              Text(_selectedCategory, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              const Icon(CupertinoIcons.chevron_down, size: 12, color: Colors.grey),
            ]),
          ),
        ),
      ])),
      const SizedBox(width: 16),
      _buildImagePickerBox(txProv),
    ]);
  }

  Widget _buildImagePickerBox(TransactionProvider txProv) {
    return GestureDetector(
      onTap: () => _pickImage(txProv),
      child: Column(children: [
        Container(
          width: 75, height: 75,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: txProv.pickedImage != null 
            ? ClipRRect(borderRadius: BorderRadius.circular(18), child: kIsWeb ? Image.network(txProv.pickedImage!.path, fit: BoxFit.cover) : Image.file(File(txProv.pickedImage!.path), fit: BoxFit.cover))
            : const Icon(CupertinoIcons.camera_fill, color: Colors.grey, size: 24),
        ),
        const SizedBox(height: 4),
        Text(txProv.pickedImage != null ? "Ganti" : "Foto", style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildNoteField() {
    return CupertinoTextField(
      controller: _noteController,
      placeholder: "Beli barang apa hari ini?",
      padding: const EdgeInsets.all(16),
      style: GoogleFonts.plusJakartaSans(fontSize: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
    );
  }

  Widget _buildSubmitButton(TransactionProvider txProv) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: txProv.isLoading ? null : () async {
        if (_amountController.text.isEmpty || _selectedPocket == null) {
          _showError("Mohon isi nominal dan pilih kantong.");
          return;
        }
        bool success = await txProv.executeTransaction(
          pocketProv: Provider.of<PocketProvider>(context, listen: false),
          selectedPocket: _selectedPocket!,
          type: _type,
          amountText: _amountController.text,
          category: _selectedCategory,
          note: _noteController.text,
        );
        if (success && mounted) Navigator.pop(context);
      },
      child: Container(
        height: 56, width: double.infinity, alignment: Alignment.center,
        decoration: BoxDecoration(color: txProv.isLoading ? Colors.grey : const Color(0xFF0F172A), borderRadius: BorderRadius.circular(18)),
        child: txProv.isLoading ? const CupertinoActivityIndicator(color: Colors.white) : Text("Simpan Transaksi", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
      ),
    );
  }

  void _showError(String msg) {
    showCupertinoDialog(context: context, builder: (c) => CupertinoAlertDialog(
      title: const Text("Peringatan"), content: Text(msg),
      actions: [CupertinoDialogAction(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
    ));
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