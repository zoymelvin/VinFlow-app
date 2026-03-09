import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../providers/report_provider.dart';

class DistributionCard extends StatelessWidget {
  final ReportProvider prov;
  final NumberFormat currency;

  const DistributionCard({super.key, required this.prov, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Distribusi Pengeluaran", 
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 24),
          if (prov.categoryTotals.isEmpty) 
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada data pengeluaran"))) 
          else
            ...prov.categoryTotals.entries.map((e) {
              double percent = prov.totalExpense > 0 ? (e.value / prov.totalExpense) : 0;
              int colorIndex = prov.categoryTotals.keys.toList().indexOf(e.key);
              Color catColor = Colors.primaries[colorIndex % Colors.primaries.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: catColor, shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Text(e.key, 
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF1E293B))),
                          ],
                        ),
                        Text(currency.format(e.value), 
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(height: 10, width: double.infinity, color: const Color(0xFFF1F5F9)),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: 10,
                            width: (MediaQuery.of(context).size.width - 88) * percent,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [catColor, catColor.withValues(alpha: 0.7)]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight, 
                      child: Text("${(percent * 100).toStringAsFixed(1)}%", 
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: catColor))
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}