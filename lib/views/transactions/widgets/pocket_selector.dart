import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/pocket_model.dart';

class PocketSelector extends StatelessWidget {
  final List<Pocket> pockets;
  final Pocket? selectedPocket;
  final Function(Pocket) onSelected;

  const PocketSelector({super.key, required this.pockets, this.selectedPocket, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    if (pockets.isEmpty) return const Text("Belum ada kantong");
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: pockets.length,
        itemBuilder: (context, index) {
          final p = pockets[index];
          bool isSelected = selectedPocket?.id == p.id;
          return GestureDetector(
            onTap: () => onSelected(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? p.color : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? p.color : const Color(0xFFE2E8F0)),
                boxShadow: isSelected ? [BoxShadow(color: p.color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(p.icon, color: isSelected ? Colors.white : p.color, size: 20),
                  const SizedBox(height: 4),
                  Text(p.name, style: GoogleFonts.plusJakartaSans(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w700, fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}