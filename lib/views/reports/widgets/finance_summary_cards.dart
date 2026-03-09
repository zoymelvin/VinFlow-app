import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../providers/report_provider.dart';

class FinanceSummaryCards extends StatelessWidget {
  final ReportProvider prov;
  final NumberFormat currency;

  const FinanceSummaryCards({super.key, required this.prov, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statCard("Pemasukan", prov.totalIncome, const Color(0xFF10B981), CupertinoIcons.add),
        const SizedBox(width: 15),
        _statCard("Pengeluaran", prov.totalExpense, const Color(0xFFF43F5E), CupertinoIcons.minus),
      ],
    );
  }

  Widget _statCard(String label, double val, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05), 
              blurRadius: 20, 
              offset: const Offset(0, 10)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 12),
            Text(label, 
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                currency.format(val),
                style: GoogleFonts.plusJakartaSans(color: color, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}