import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/target_provider.dart';
import 'widgets/target_card.dart';
import 'widgets/add_target_dialog.dart';

class TargetScreen extends StatelessWidget {
  const TargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final targetProv = context.watch<TargetProvider>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text("Target Impian", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      body: targetProv.isLoading 
        ? const Center(child: CupertinoActivityIndicator())
        : targetProv.targets.isEmpty 
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.88, 
              ),
              itemCount: targetProv.targets.length,
              itemBuilder: (context, index) {
                return TargetCard(target: targetProv.targets[index], currency: currency);
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildAddButton(context),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => showDialog(
          context: context, 
          builder: (context) => const AddTargetDialog()
        ),
        icon: const Icon(CupertinoIcons.add_circled_solid, color: Colors.white),
        label: Text("Buat Target", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 17, 51, 131),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.flag_circle, size: 60, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text("Belum ada target yang dibuat", 
            style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}