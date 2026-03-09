import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../providers/report_provider.dart';

class DateBanner extends StatelessWidget {
  final ReportProvider prov;
  final bool isFilterOpen;
  final VoidCallback onToggleFilter;

  const DateBanner({
    super.key,
    required this.prov,
    required this.isFilterOpen,
    required this.onToggleFilter,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = DateFormat('dd MMM').format(prov.selectedDateRange.start);
    final endDate = DateFormat('dd MMM yyyy').format(prov.selectedDateRange.end);
    final diffDays = prov.selectedDateRange.duration.inDays + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.calendar, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$startDate - $endDate", 
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF3730A3), fontSize: 14)),
                  Text("$diffDays Hari Terdata", 
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF4F46E5),
            borderRadius: BorderRadius.circular(12),
            onPressed: onToggleFilter,
            child: Text(isFilterOpen ? "Tutup" : "Ubah", 
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }
}