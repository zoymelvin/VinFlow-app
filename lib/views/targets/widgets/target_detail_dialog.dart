import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/target_model.dart';
import '../../../providers/target_provider.dart';

class TargetDetailDialog extends StatelessWidget {
  final TargetModel target;
  final dynamic pocket;
  final int percentage;
  final double progress;
  final NumberFormat currency;

  const TargetDetailDialog({
    super.key, 
    required this.target, 
    required this.pocket, 
    required this.percentage, 
    required this.progress, 
    required this.currency
  });

  @override
  Widget build(BuildContext context) {
    final double remaining = target.targetAmount - (pocket?.balance ?? 0);
    final bool isAchieved = percentage >= 100;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Detail Target", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: const Color(0xFF64748B))),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Color(0xFFE2E8F0), size: 28),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160, height: 160,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 18,
                      strokeCap: StrokeCap.round,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(isAchieved ? const Color(0xFF10B981) : const Color(0xFF4F46E5)),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$percentage%", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 38, color: const Color(0xFF0F172A))),
                      Text("Tercapai", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(target.title, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 26, color: const Color(0xFF1E293B))),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    _detailRow("Total Yang Dibutuhkan", currency.format(target.targetAmount), const Color(0xFF0F172A), isBold: true),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                    _detailRow("Saldo Saat Ini", currency.format(pocket?.balance ?? 0), const Color(0xFF4F46E5)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(CupertinoIcons.creditcard, size: 12, color: Colors.blueGrey[300]),
                        const SizedBox(width: 6),
                        Text("Sumber: ${target.pocketName}", style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.blueGrey[400], fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                    _detailRow(
                      "Kekurangan", 
                      isAchieved ? "Selesai ✅" : currency.format(remaining < 0 ? 0 : remaining), 
                      isAchieved ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      isBold: true
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(18),
                      onPressed: () {
                        context.read<TargetProvider>().deleteTarget(target.id);
                        Navigator.pop(context);
                      },
                      child: const Icon(CupertinoIcons.trash_fill, color: Color(0xFFF43F5E), size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text("Selesai", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
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

  Widget _detailRow(String label, String value, Color valColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF64748B))),
        Text(value, style: GoogleFonts.plusJakartaSans(fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, fontSize: 14, color: valColor)),
      ],
    );
  }
}