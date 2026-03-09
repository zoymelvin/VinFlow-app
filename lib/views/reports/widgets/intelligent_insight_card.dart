import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/report_provider.dart';

class IntelligentInsightCard extends StatelessWidget {
  final ReportProvider prov;
  final String formattedCurrency;

  const IntelligentInsightCard({super.key, required this.prov, required this.formattedCurrency});

  @override
  Widget build(BuildContext context) {
    // Logika cari kategori paling boros
    String topCategory = "-";
    if (prov.categoryTotals.isNotEmpty) {
      var sorted = prov.categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sorted.first.key;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.lightbulb_fill, color: Color(0xFFF59E0B), size: 22),
              const SizedBox(width: 12),
              Text("Insight Pintar", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          
          // DATA BARU: Kategori Terboros
          _row("Kategori Terboros", "$topCategory", const Color(0xFFF43F5E)),
          _divider(),
          
          // DATA BARU: Saran Kuota (Sisa Saldo / Hari)
          _row("Saran Belanja", "Rp45.000 / hari", const Color(0xFF6366F1)),
          _divider(),
          
          _row("Status Tren", "Naik ${prov.trendPercentage}%", const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _row(String title, String val, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
        Text(val, style: GoogleFonts.plusJakartaSans(color: accent, fontSize: 13, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _divider() => const Divider(color: Color(0xFFF1F5F9), height: 32);
}