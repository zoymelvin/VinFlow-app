import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/report_provider.dart';
import '../../providers/pocket_provider.dart';

// Import widgets modular
import 'widgets/pocket_selector_pill.dart';
import 'widgets/date_banner.dart';
import 'widgets/finance_summary_cards.dart';
import 'widgets/distribution_card.dart';
import 'widgets/visual_trend_card.dart';
import 'widgets/intelligent_insight_card.dart';
import 'widgets/filter_dropdown_overlay.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedPocketId;
  String _activeRangeLabel = "Bulan Ini";
  bool _isFilterOpen = false;

  @override
  void initState() {
    super.initState();
    // Memuat data awal saat halaman dibuka
    Future.microtask(() => context.read<ReportProvider>().fetchReportData(pocketId: _selectedPocketId));
  }

  // FUNGSI PEMANGGIL POP-UP PEMILIHAN KANTONG
  void _showPocketGridPicker(BuildContext context, PocketProvider pocketProv) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0), 
                borderRadius: BorderRadius.circular(2)
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Pilih Kantong Laporan", 
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, 
                fontWeight: FontWeight.w800, 
                color: const Color(0xFF0F172A)
              )
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pocketProv.pockets.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, 
                mainAxisSpacing: 16, 
                crossAxisSpacing: 16, 
                childAspectRatio: 0.85
              ),
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final pocket = isAll ? null : pocketProv.pockets[index - 1];
                final isSelected = isAll 
                    ? _selectedPocketId == null 
                    : _selectedPocketId == pocket?.id;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedPocketId = isAll ? null : pocket?.id);
                    context.read<ReportProvider>().fetchReportData(pocketId: _selectedPocketId);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          boxShadow: isSelected 
                              ? [BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.3), blurRadius: 10)] 
                              : [],
                        ),
                        child: Icon(
                          isAll ? CupertinoIcons.square_grid_2x2_fill : pocket!.icon, 
                          color: isSelected ? Colors.white : const Color(0xFF64748B), 
                          size: 24
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAll ? "Semua" : pocket!.name, 
                        textAlign: TextAlign.center, 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, 
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                        )
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // FUNGSI PEMILIH TANGGAL CUSTOM (KALENDER)
  Future<void> _pickCustomRange() async {
    final reportProv = context.read<ReportProvider>();
    final picked = await showDateRangePicker(
      context: context, 
      initialDateRange: reportProv.selectedDateRange, 
      firstDate: DateTime(2022), 
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F46E5),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && mounted) {
      setState(() => _activeRangeLabel = "Kustom");
      reportProv.updateDateRange(picked, pocketId: _selectedPocketId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProv = context.watch<ReportProvider>();
    final pocketProv = context.watch<PocketProvider>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text(
          "Analisis Laporan", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17)
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      body: Stack(
        children: [
          reportProv.isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // 1. POCKET SELECTOR (Glassmorphism Floating Pill Biru)
                      PocketSelectorPill(
                        selectedPocketId: _selectedPocketId,
                        pocketProv: pocketProv,
                        onTap: () => _showPocketGridPicker(context, pocketProv),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 2. INFORMATIVE DATE BANNER
                      DateBanner(
                        prov: reportProv,
                        isFilterOpen: _isFilterOpen,
                        onToggleFilter: () => setState(() => _isFilterOpen = !_isFilterOpen),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 3. FINANCE SUMMARY CARDS (Pemasukan & Pengeluaran)
                      FinanceSummaryCards(prov: reportProv, currency: currency),
                      
                      const SizedBox(height: 24),
                      
                      // 4. DISTRIBUTION LIST (Per Kategori)
                      DistributionCard(prov: reportProv, currency: currency),
                      
                      const SizedBox(height: 24),
                      
                      // 5. VISUAL TREND CARD (Line Chart)
                      VisualTrendCard(prov: reportProv, currency: currency),
                      
                      const SizedBox(height: 24),
                      
                      // 6. INTELLIGENT INSIGHT CARD (Kategori Terboros & Kuota)
                      IntelligentInsightCard(prov: reportProv, formattedCurrency: "Rp"),
                      
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
          
          // 7. FLOATING DROPDOWN OVERLAY (Pop-over Menu Filter)
          if (_isFilterOpen) 
            FilterDropdownOverlay(
              activeLabel: _activeRangeLabel,
              onSelect: (label, start) {
                setState(() { 
                  _activeRangeLabel = label; 
                  _isFilterOpen = false; 
                });
                reportProv.updateDateRange(
                  DateTimeRange(start: start, end: DateTime.now()), 
                  pocketId: _selectedPocketId
                );
              },
              onCustomTap: () { 
                setState(() => _isFilterOpen = false); 
                _pickCustomRange(); 
              },
            ),
        ],
      ),
    );
  }
}