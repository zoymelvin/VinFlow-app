import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
      if (mounted) {
        context.read<LimitProvider>().listenToLimits();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider agar UI merespon notifyListeners()
    final limitProv = context.watch<LimitProvider>(); 
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text("Manajemen Limit", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white.withOpacity(0.9),
      ),
      body: limitProv.isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : limitProv.limits.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  itemCount: limitProv.limits.length,
                  itemBuilder: (context, index) {
                    return _LimitCard(limit: limitProv.limits[index], currency: currency);
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildAddButton(context),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const AddLimitScreen())),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.add_circled_solid, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text("Tambah Batas Pengeluaran", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.shield_slash, size: 100, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 20),
          Text("Belum ada limit aktif", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  final LimitModel limit;
  final NumberFormat currency;

  const _LimitCard({required this.limit, required this.currency});

  @override
  Widget build(BuildContext context) {
    final limitProv = context.read<LimitProvider>();

    return FutureBuilder<double>(
      // PENTING: UniqueKey memastikan Future dipanggil ulang saat list refresh
      key: UniqueKey(), 
      future: limitProv.getRemainingAmount(limit),
      builder: (context, snapshot) {
        final remaining = snapshot.data ?? limit.limitAmount;
        final spent = limit.limitAmount - remaining;
        final percent = (spent / limit.limitAmount).clamp(0.0, 1.0);
        final isWarning = remaining < (limit.limitAmount * 0.2);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isWarning 
                  ? [const Color(0xFFF43F5E), const Color(0xFFE11D48)] 
                  : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: (isWarning ? Colors.red : Colors.indigo).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(limit.title, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    Text(limit.targetCategory != null ? "Kategori: ${limit.targetCategory}" : "Batas Seluruh Transaksi",
                        style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                  ]),
                  const Icon(CupertinoIcons.bolt_fill, color: Colors.white54, size: 24),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Sisa Saldo Limit", style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(currency.format(remaining), style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ]),
                  Text("${(percent * 100).toStringAsFixed(0)}%", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}