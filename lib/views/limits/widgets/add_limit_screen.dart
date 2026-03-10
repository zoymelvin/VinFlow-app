import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vinflow/models/limit_model.dart';
import 'package:vinflow/providers/limit_provider.dart';
import 'package:vinflow/providers/pocket_provider.dart';
import 'package:vinflow/utils/formatters.dart';

class AddLimitScreen extends StatefulWidget {
  const AddLimitScreen({super.key});

  @override
  State<AddLimitScreen> createState() => _AddLimitScreenState();
}

class _AddLimitScreenState extends State<AddLimitScreen> {
  final _amountController = TextEditingController();
  int _selectedTargetType = 0; // 0: Kategori, 1: Kantong
  String? _selectedCategory;
  String? _selectedPocketId;
  String? _selectedPocketName;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Belanja', 'icon': CupertinoIcons.bag_fill, 'color': Colors.orange},
    {'name': 'Makan', 'icon': CupertinoIcons.cart_fill, 'color': Colors.red},
    {'name': 'Transport', 'icon': CupertinoIcons.bus, 'color': Colors.blue},
    {'name': 'Hobi', 'icon': CupertinoIcons.gamecontroller_fill, 'color': Colors.purple},
    {'name': 'Kuota', 'icon': CupertinoIcons.wifi, 'color': Colors.indigo},
    {'name': 'Lainnya', 'icon': CupertinoIcons.ellipsis_circle_fill, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    final pocketProv = context.watch<PocketProvider>();
    final dynamicTitle = _selectedTargetType == 0 
        ? "Limit ${_selectedCategory ?? 'Kategori'}" 
        : "Limit ${_selectedPocketName ?? 'Kantong'}";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text("Buat Batas Baru", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreviewCard(dynamicTitle),
            const SizedBox(height: 32),
            Text("Pilih Target Batasan", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  _targetTypeBtn(0, "Kategori"),
                  _targetTypeBtn(1, "Kantong"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _selectedTargetType == 0 ? _buildCategoryGrid() : _buildPocketGrid(pocketProv),
            const SizedBox(height: 40),
            Text("Nominal Batasan", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF4F46E5)),
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: InputDecoration(
                prefixText: "Rp ",
                prefixStyle: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                hintText: "0",
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4F46E5), width: 2)),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildSaveButton(dynamicTitle),
    );
  }

  Widget _targetTypeBtn(int index, String label) {
    bool isSelected = _selectedTargetType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTargetType = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)] : [],
          ),
          alignment: Alignment.center,
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B))),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CupertinoIcons.checkmark_shield_fill, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          Text("Otomatis aktif mulai hari ini", style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
      itemBuilder: (context, index) {
        final cat = _categories[index];
        bool isSel = _selectedCategory == cat['name'];
        return GestureDetector(
          onTap: () => setState(() { _selectedCategory = cat['name']; _selectedPocketId = null; }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSel ? cat['color'] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSel ? Colors.transparent : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'], color: isSel ? Colors.white : cat['color']),
                const SizedBox(height: 8),
                Text(cat['name'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPocketGrid(PocketProvider pocketProv) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pocketProv.pockets.length,
        itemBuilder: (context, index) {
          final pocket = pocketProv.pockets[index];
          bool isSel = _selectedPocketId == pocket.id;
          return GestureDetector(
            onTap: () => setState(() { _selectedPocketId = pocket.id; _selectedPocketName = pocket.name; _selectedCategory = null; }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSel ? Colors.transparent : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(pocket.icon, color: isSel ? Colors.white : const Color(0xFF64748B)),
                  const SizedBox(height: 8),
                  Text(pocket.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.black87)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaveButton(String title) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          if (_amountController.text.isEmpty) return;
          final double amount = double.parse(_amountController.text.replaceAll('.', ''));
          
          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);

          final newLimit = LimitModel(
            id: '',
            title: title,
            limitAmount: amount,
            targetCategory: _selectedCategory,
            targetPocketId: _selectedPocketId,
            startDate: startOfToday, 
            endDate: startOfToday.add(const Duration(days: 30)),
          );

          await context.read<LimitProvider>().addLimit(newLimit);
          if (mounted) Navigator.pop(context);
        },
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          alignment: Alignment.center,
          child: Text("Simpan Batas Pengeluaran", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}