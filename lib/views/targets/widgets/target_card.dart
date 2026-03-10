import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/target_model.dart';
import '../../../providers/pocket_provider.dart';
import 'target_detail_dialog.dart';

class TargetCard extends StatelessWidget {
  final TargetModel target;
  final NumberFormat currency;

  const TargetCard({super.key, required this.target, required this.currency});

  @override
  Widget build(BuildContext context) {
    final pockets = context.watch<PocketProvider>().pockets;
    final pocket = pockets.isNotEmpty 
        ? pockets.firstWhere((p) => p.id == target.pocketId, orElse: () => pockets.first)
        : null;
    
    double progress = (pocket != null) ? (pocket.balance / target.targetAmount).clamp(0.0, 1.0) : 0.0;
    int percentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => TargetDetailDialog(
          target: target, 
          pocket: pocket, 
          percentage: percentage, 
          progress: progress, 
          currency: currency
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Positioned(
                top: -10, right: -10,
                child: CircleAvatar(radius: 35, backgroundColor: (pocket?.color ?? const Color(0xFF4F46E5)).withValues(alpha: 0.04)),
              ),
              // PENTING: Menggunakan Center agar semua konten benar-benar di tengah
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Agar tidak memaksa mengambil seluruh tinggi (Hapus space kosong)
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 65, height: 65,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(percentage >= 100 ? const Color(0xFF10B981) : const Color(0xFF4F46E5)),
                            ),
                          ),
                          Text("$percentage%", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14, color: const Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(target.title, 
                        textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFF1E293B))),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: (pocket?.color ?? const Color(0xFF4F46E5)).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(target.pocketName, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: pocket?.color ?? const Color(0xFF4F46E5), fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 10), // Jarak proporsional pengganti Spacer
                      Text(currency.format(target.targetAmount), 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13, color: const Color(0xFF4F46E5))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}