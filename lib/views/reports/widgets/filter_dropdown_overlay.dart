import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterDropdownOverlay extends StatelessWidget {
  final String activeLabel;
  final Function(String, DateTime) onSelect;
  final VoidCallback onCustomTap;

  const FilterDropdownOverlay({
    super.key,
    required this.activeLabel,
    required this.onSelect,
    required this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 155,
      right: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30)],
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            _filterItem("Hari Ini", 0),
            _filterItem("7 Hari Terakhir", 7),
            _filterItem("30 Hari Terakhir", 30),
            _filterItem("Bulan Ini", -1),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ListTile(
              leading: const Icon(CupertinoIcons.calendar_badge_plus, color: Color(0xFF64748B)),
              title: Text("Pilih di Kalender", 
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: onCustomTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterItem(String label, int days) {
    final isActive = activeLabel == label;
    DateTime start;
    if (days == 0) {
      start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    } else if (days == -1) {
      start = DateTime(DateTime.now().year, DateTime.now().month, 1);
    } else {
      start = DateTime.now().subtract(Duration(days: days));
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, 
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14, 
          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600, 
          color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF1E293B)
        )),
      trailing: isActive 
          ? const Icon(CupertinoIcons.checkmark_circle_fill, color: Color(0xFF4F46E5), size: 20) 
          : null,
      onTap: () => onSelect(label, start),
    );
  }
}