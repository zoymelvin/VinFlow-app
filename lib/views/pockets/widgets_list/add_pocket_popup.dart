import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/pocket_provider.dart';

class AddPocketPopup extends StatefulWidget {
  const AddPocketPopup({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => const AddPocketPopup(),
    );
  }

  @override
  State<AddPocketPopup> createState() => _AddPocketPopupState();
}

class _AddPocketPopupState extends State<AddPocketPopup> {
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  Color selectedColor = const Color(0xFF007BFF);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tambah Kantong',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 20),
              ),
              const SizedBox(height: 24),
              CupertinoTextField(
                controller: nameController,
                placeholder: 'Nama Kantong',
                padding: const EdgeInsets.all(16),
                style: GoogleFonts.plusJakartaSans(fontSize: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: balanceController,
                placeholder: 'Saldo Awal (Rp)',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsSeparatorInputFormatter(),
                ],
                padding: const EdgeInsets.all(16),
                style: GoogleFonts.plusJakartaSans(fontSize: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _colorPicker(const Color(0xFF007BFF)),
                  _colorPicker(const Color(0xFFF59E0B)),
                  _colorPicker(const Color(0xFF10B981)),
                  _colorPicker(const Color(0xFFEF4444)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: const Color(0xFF007BFF),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () async {
                        if (nameController.text.isNotEmpty && balanceController.text.isNotEmpty) {
                          final cleanBalance = balanceController.text.replaceAll('.', '');
                          await context.read<PocketProvider>().addPocket(
                            nameController.text,
                            double.parse(cleanBalance),
                            CupertinoIcons.creditcard_fill,
                            selectedColor,
                          );
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      child: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorPicker(Color color) {
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selectedColor == color 
              ? Border.all(color: Colors.black, width: 2.5) 
              : Border.all(color: Colors.white, width: 2),
        ),
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
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}