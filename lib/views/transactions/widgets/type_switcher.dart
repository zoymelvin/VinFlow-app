import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TypeSwitcher extends StatelessWidget {
  final String currentType;
  final Function(String) onTypeChanged;

  const TypeSwitcher({super.key, required this.currentType, required this.onTypeChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          _buildBtn("expense", "Pengeluaran", Colors.red),
          _buildBtn("income", "Pemasukan", Colors.green),
        ],
      ),
    );
  }

  Widget _buildBtn(String type, String label, Color color) {
    bool isSelected = currentType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
          ),
          child: Text(label, textAlign: TextAlign.center, 
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? color : Colors.grey)),
        ),
      ),
    );
  }
}