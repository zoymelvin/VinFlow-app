import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/history_provider.dart';
import '../../models/transaction_model.dart';
import '../transactions/transaction_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProv = context.watch<HistoryProvider>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text("Riwayat Transaksi", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      body: Column(
        children: [
          // 1. Perbaikan Filter Indicator Card (Lebih Mewah)
          _buildPremiumIndicator(context, historyProv),

          Expanded(
            child: historyProv.filteredTransactions.isEmpty 
              ? _buildEmptyState()
              : _buildGroupedList(historyProv.filteredTransactions, currency),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterDialog(context),
        backgroundColor: const Color(0xFF4F46E5),
        elevation: 8,
        child: const Icon(CupertinoIcons.slider_horizontal_3, color: Colors.white),
      ),
    );
  }

  Widget _buildPremiumIndicator(BuildContext context, HistoryProvider prov) {
    String dateRange = prov.selectedDateRange == null ? "Semua Waktu" : 
      "${DateFormat('dd MMM').format(prov.selectedDateRange!.start)} - ${DateFormat('dd MMM').format(prov.selectedDateRange!.end)}";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
          begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Penyaringan Aktif", style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text("${prov.selectedType} • ${prov.selectedCategory}", 
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
              ),
              // Ikon Sort Terintegrasi
              GestureDetector(
                onTap: () => prov.toggleSort(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15)),
                  child: Icon(prov.isDescending ? CupertinoIcons.sort_down : CupertinoIcons.sort_up, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Colors.white24, height: 1)),
          Row(
            children: [
              const Icon(CupertinoIcons.calendar, color: Colors.white70, size: 14),
              const SizedBox(width: 8),
              Text(dateRange, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              const Spacer(),
              GestureDetector(
                onTap: () => prov.resetFilters(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text("Reset", style: GoogleFonts.plusJakartaSans(color: const Color(0xFF4F46E5), fontWeight: FontWeight.w800, fontSize: 10)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGroupedList(List<TransactionModel> list, NumberFormat currency) {
    Map<String, List<TransactionModel>> grouped = {};
    for (var t in list) {
      String date = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(t.timestamp);
      if (grouped[date] == null) grouped[date] = [];
      grouped[date]!.add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        String dateKey = grouped.keys.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 12, left: 4),
              child: Text(dateKey, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF94A3B8))),
            ),
            ...grouped[dateKey]!.map((item) => _TransactionCard(trans: item, currency: currency)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() => Center(child: Text("Tidak ada transaksi", style: GoogleFonts.plusJakartaSans(color: Colors.grey)));

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: FilterHistoryDialog(),
      ),
    );
  }
}

class FilterHistoryDialog extends StatelessWidget {
  const FilterHistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<HistoryProvider>();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)]
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Center(child: Text("Filter Transaksi", style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800))),
            const SizedBox(height: 32),
            
            _sectionHeader(CupertinoIcons.layers_alt, "Tipe Transaksi"),
            _buildModernChips(['Semua', 'Pemasukan', 'Pengeluaran'], prov.selectedType, (v) => prov.setType(v)),
            
            const SizedBox(height: 24),
            _sectionHeader(CupertinoIcons.tag, "Kategori"),
            _buildModernChips(['Semua', 'Makan', 'Transport', 'Belanja', 'Hobi', 'Kuota', 'Gaji'], prov.selectedCategory, (v) => prov.setCategory(v)),

            const SizedBox(height: 24),
            _sectionHeader(CupertinoIcons.time_solid, "Rentang Waktu Cepat"),
            _buildModernChips(['Hari Ini', '7 Hari', '30 Hari'], "Custom", (v) {
              if(v == 'Hari Ini') prov.setQuickDate(1);
              if(v == '7 Hari') prov.setQuickDate(7);
              if(v == '30 Hari') prov.setQuickDate(30);
            }),

            const SizedBox(height: 24),
            InkWell(
              onTap: () async {
                final range = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
                if (range != null) prov.setDateRange(range);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(CupertinoIcons.calendar, size: 20, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 12),
                  Text(prov.selectedDateRange == null ? "Pilih Kalender Kustom" : "Tanggal Terpilih ✅", 
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF1E293B))),
                  const Spacer(),
                  const Icon(CupertinoIcons.chevron_right, size: 14, color: Colors.grey),
                ]),
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0
                ),
                child: Text("Terapkan Filter", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildModernChips(List<String> options, String current, Function(String) onSelect) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: options.map((opt) {
        bool isSelected = current == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(opt, style: GoogleFonts.plusJakartaSans(
              color: isSelected ? Colors.white : const Color(0xFF475569),
              fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel trans;
  final NumberFormat currency;
  const _TransactionCard({required this.trans, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isIncome = trans.type == 'income';
    return GestureDetector(
      onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => TransactionDetailScreen(transaction: trans))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(isIncome ? CupertinoIcons.arrow_down_left : CupertinoIcons.arrow_up_right, color: isIncome ? Colors.green : Colors.red, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(trans.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFF1E293B))),
                Text(trans.category, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              ]),
            ),
            Text("${isIncome ? '+' : '-'} ${currency.format(trans.amount)}", 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: 15)),
          ],
        ),
      ),
    );
  }
}