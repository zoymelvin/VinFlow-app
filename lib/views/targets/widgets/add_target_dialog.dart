import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/target_model.dart';
import '../../../providers/target_provider.dart';
import '../../../providers/pocket_provider.dart';
import '../../../utils/formatters.dart';

class AddTargetDialog extends StatefulWidget {
  const AddTargetDialog({super.key});

  @override
  State<AddTargetDialog> createState() => _AddTargetDialogState();
}

class _AddTargetDialogState extends State<AddTargetDialog> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String? selectedPocketId;
  String? selectedPocketName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.rocket_fill, color: Color(0xFF4F46E5), size: 32),
            ),
            const SizedBox(height: 16),
            Text("Tambah Target", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Nama Impian"),
                  TextField(
                    controller: titleCtrl,
                    decoration: _inputDeco("Contoh: MacBook Pro...", CupertinoIcons.tag),
                  ),
                  const SizedBox(height: 16),
                  _label("Nominal Dibutuhkan"),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    decoration: _inputDeco("0", CupertinoIcons.money_dollar),
                  ),
                  const SizedBox(height: 20),
                  _label("Pilih Kantong"),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 95,
                    child: Consumer<PocketProvider>(
                      builder: (context, pProv, _) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pProv.pockets.length,
                        itemBuilder: (context, i) {
                          final p = pProv.pockets[i];
                          bool isSelected = selectedPocketId == p.id;
                          return GestureDetector(
                            onTap: () => setState(() {
                              selectedPocketId = p.id;
                              selectedPocketName = p.name;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 85,
                              margin: const EdgeInsets.only(right: 12, bottom: 5),
                              decoration: BoxDecoration(
                                color: isSelected ? p.color : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? p.color : const Color(0xFFE2E8F0), width: 1.5),
                                boxShadow: isSelected ? [BoxShadow(color: p.color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(p.icon, color: isSelected ? Colors.white : p.color, size: 22),
                                  const SizedBox(height: 6),
                                  Text(p.name, 
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                                      fontWeight: FontWeight.w800, fontSize: 9)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Batal", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if(selectedPocketId != null && titleCtrl.text.isNotEmpty) {
                          final t = TargetModel(
                            id: '', title: titleCtrl.text,
                            targetAmount: double.parse(amountCtrl.text.replaceAll('.', '')),
                            pocketId: selectedPocketId!,
                            pocketName: selectedPocketName!,
                            icon: "🎯"
                          );
                          context.read<TargetProvider>().addTarget(t);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text("Simpan", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 4), 
    child: Text(t, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF1E293B))));

  InputDecoration _inputDeco(String h, IconData i) => InputDecoration(
    hintText: h,
    prefixIcon: Icon(i, size: 18, color: const Color(0xFF4F46E5)),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.all(16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
  );
}