import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/pocket_provider.dart';

class PocketSelectorPill extends StatelessWidget {
  final String? selectedPocketId;
  final PocketProvider pocketProv;
  final VoidCallback onTap;

  const PocketSelectorPill({
    super.key,
    required this.selectedPocketId,
    required this.pocketProv,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activePocketName = selectedPocketId == null 
        ? "Semua Transaksi" 
        : pocketProv.pockets.firstWhere((p) => p.id == selectedPocketId).name;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // GRADIENT BIRU MODERN (MENGGANTI HITAM)
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 59, 57, 97), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 82, 77, 182).withValues(alpha: 0.25), 
              blurRadius: 20, 
              offset: const Offset(0, 8)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2), 
                shape: BoxShape.circle
              ),
              child: const Icon(CupertinoIcons.briefcase_fill, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kantong Terpilih", 
                    style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500)),
                  Text(activePocketName, 
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            // Ikon ganti arah agar lebih simetris
            const Icon(CupertinoIcons.chevron_up_chevron_down, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}