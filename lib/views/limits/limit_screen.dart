import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vinflow/utils/formatters.dart';
import 'package:vinflow/views/limits/widgets/add_limit_screen.dart';
import '../../providers/limit_provider.dart';
import '../../models/limit_model.dart';

class LimitScreen extends StatefulWidget {
  const LimitScreen({super.key});
  @override
  State<LimitScreen> createState() => _LimitScreenState();
}

class _LimitScreenState extends State<LimitScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<LimitProvider>().listenToLimits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final limitProv = context.watch<LimitProvider>(); 
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text(
          "Manajemen Limit", 
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1E293B))
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      body: limitProv.isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : limitProv.limits.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  itemCount: limitProv.limits.length,
                  itemBuilder: (context, index) {
                    return _LimitCard(limit: limitProv.limits[index], currency: currency);
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildModernPrimaryButton(context),
    );
  }

  Widget _buildModernPrimaryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const AddLimitScreen())),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: const Color(0xFF0F172A).withOpacity(0.3),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.plus_circle_fill, size: 20),
                const SizedBox(width: 10),
                Text(
                  "Tambah Batas Pengeluaran",
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(CupertinoIcons.shield_slash, size: 60, color: Color(0xFFCBD5E1)),
      const SizedBox(height: 16),
      Text("Belum ada limit aktif", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
    ]));
  }
}

class _LimitCard extends StatelessWidget {
  final LimitModel limit;
  final NumberFormat currency;

  const _LimitCard({required this.limit, required this.currency});

  // UI MODAL POPUP YANG KEREN
  void _showTopUpSheet(BuildContext context, LimitProvider prov) {
  final TextEditingController amountController = TextEditingController();
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 24, right: 24
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4, 
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Tingkatkan Anggaran",
            style: GoogleFonts.inter(
              fontSize: 18, 
              fontWeight: FontWeight.w700, // Semi-bold lebih profesional
              color: const Color(0xFF1E293B)
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Masukkan nominal tambahan untuk limit ${limit.title}",
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: amountController,
            autofocus: true,
            keyboardType: TextInputType.number,
            // Menggunakan ThousandsSeparatorInputFormatter (Titik sebagai pemisah ribuan)
            inputFormatters: [ThousandsSeparatorInputFormatter()], 
            style: GoogleFonts.inter(
              fontSize: 22, 
              fontWeight: FontWeight.w600, // Ukuran normal & elegan
              color: const Color.fromARGB(255, 0, 0, 0),
              letterSpacing: 0.5
            ),
            decoration: InputDecoration(
              hintText: "0",
              prefixText: "Rp ",
              prefixStyle: GoogleFonts.inter(
                color: const Color.fromARGB(255, 0, 0, 0), 
                fontWeight: FontWeight.w500,
                fontSize: 18
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), 
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), 
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (amountController.text.isNotEmpty) {
                  // Bersihkan titik sebelum parsing ke double
                  double addVal = double.parse(amountController.text.replaceAll('.', ''));
                  await prov.updateLimitAmount(limit.id, addVal, limit.limitAmount);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                "Simpan Anggaran Baru", 
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final limitProv = context.read<LimitProvider>();
    final remaining = limit.limitAmount - limit.totalSpent;
    final spent = limit.totalSpent;
    
    double remainingPercent = limit.limitAmount > 0 
        ? (remaining / limit.limitAmount).clamp(0.0, 1.0) 
        : 0.0;
    
    Color barColor = remainingPercent > 0.4 ? Colors.white 
                 : remainingPercent > 0.15 ? const Color(0xFFFB923C) 
                 : const Color(0xFFF43F5E);

    final bool isOverLimit = spent >= limit.limitAmount;

    return GestureDetector(
      onTap: () => _showTopUpSheet(context, limitProv),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isOverLimit
                ? [const Color(0xFF334155), const Color(0xFF1E293B)] 
                : [const Color(0xFF4F46E5), const Color(0xFF4338CA)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isOverLimit ? Colors.black : const Color(0xFF4F46E5)).withOpacity(0.15), 
              blurRadius: 12, offset: const Offset(0, 6)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(limit.title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      limit.targetCategory != null ? "Kategori: ${limit.targetCategory}" : "Batas Pengeluaran",
                      style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ]),
                ),
                Icon(
                  isOverLimit ? CupertinoIcons.exclamationmark_octagon_fill : CupertinoIcons.check_mark_circled_solid, 
                  color: isOverLimit ? const Color(0xFFF43F5E) : Colors.white.withOpacity(0.7), size: 22
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("SISA ANGGARAN", style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(currency.format(remaining < 0 ? 0 : remaining), style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${(remainingPercent * 100).toStringAsFixed(0)}%", style: GoogleFonts.inter(color: barColor, fontWeight: FontWeight.w800, fontSize: 18)),
                    Text("tersedia", style: GoogleFonts.inter(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8))),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  height: 8,
                  width: (MediaQuery.of(context).size.width - 80) * remainingPercent,
                  decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            if (isOverLimit) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Text("Peringatan: Anggaran telah habis! Ketuk untuk tambah.", style: GoogleFonts.inter(color: const Color(0xFFFCA5A5), fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}