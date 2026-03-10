import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/bill_provider.dart';
import '../../providers/pocket_provider.dart';
import '../../models/bill_model.dart';
import '../../utils/formatters.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});
  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // watch akan mendeteksi notifyListeners() dan updateTick
    final billProv = context.watch<BillProvider>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text("Manajemen Tagihan", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF0F172A))),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 54,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      blurRadius: 10, offset: const Offset(0, 4),
                    )
                  ],
                ),
                labelColor: const Color(0xFF4F46E5),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [Tab(text: "Berlangsung"), Tab(text: "Riwayat")],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            // KEY ADALAH KUNCI: Setiap updateTick naik, widget TabBarView akan dibuat ulang secara paksa
            child: TabBarView(
              key: ValueKey("bill_view_${billProv.updateTick}"), 
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildBillList(billProv.activeBills, false, currency),
                _buildBillList(billProv.historyBills, true, currency),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildAddButton(),
    );
  }

  // --- UI COMPONENTS TETAP SAMA ---
  Widget _buildBillList(List<BillModel> list, bool isHistory, NumberFormat currency) {
    if (list.isEmpty) return _buildEmptyState();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) => _BillCard(bill: list[index], isHistory: isHistory, currency: currency),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: double.infinity, height: 58, margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () => _showAddBillSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 20, 53, 129),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8, shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text("Tambah Tagihan Baru", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _showAddBillSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final intervalCtrl = TextEditingController(text: "30");
    DateTime selectedDate = DateTime.now();
    bool isRecurring = false;
    bool isIntervalMode = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 24, right: 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              Text("Buat Tagihan Baru", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              TextField(controller: titleCtrl, decoration: _inputDeco("Nama Tagihan", CupertinoIcons.tag)),
              const SizedBox(height: 16),
              TextField(controller: amountCtrl, keyboardType: TextInputType.number, inputFormatters: [ThousandsSeparatorInputFormatter()], decoration: _inputDeco("Nominal", CupertinoIcons.money_dollar)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tipe Jatuh Tempo", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                  CupertinoSlidingSegmentedControl<bool>(
                    groupValue: isIntervalMode,
                    children: const {
                      false: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("📅 Tanggal")),
                      true: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("🔢 Hari")),
                    },
                    onValueChanged: (val) => setModalState(() => isIntervalMode = val!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isIntervalMode)
                TextField(controller: intervalCtrl, keyboardType: TextInputType.number, decoration: _inputDeco("Setiap berapa hari?", CupertinoIcons.refresh))
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(CupertinoIcons.calendar, color: Color(0xFF4F46E5)),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
                    if (d != null) setModalState(() => selectedDate = d);
                  },
                ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Aktifkan Berulang?", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                  Switch.adaptive(value: isRecurring, activeColor: const Color(0xFF4F46E5), onChanged: (v) => setModalState(() => isRecurring = v)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if(titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                    final b = BillModel(
                      id: '', title: titleCtrl.text, 
                      amount: double.parse(amountCtrl.text.replaceAll('.', '')),
                      category: 'Lainnya', dueDate: selectedDate,
                      isRecurring: isRecurring, isIntervalMode: isIntervalMode,
                      intervalDays: int.tryParse(intervalCtrl.text) ?? 30,
                    );
                    await context.read<BillProvider>().addBill(b);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text("Simpan Tagihan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String h, IconData i) => InputDecoration(
    hintText: h, prefixIcon: Icon(i, size: 18, color: const Color(0xFF4F46E5)), 
    filled: true, fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.all(16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
  );

  Widget _buildEmptyState() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(CupertinoIcons.doc_text_search, size: 50, color: Colors.grey[300]),
      const SizedBox(height: 12),
      Text("Data tidak ditemukan", style: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontWeight: FontWeight.w500)),
    ],
  ));
}

class _BillCard extends StatelessWidget {
  final BillModel bill;
  final bool isHistory;
  final NumberFormat currency;
  const _BillCard({required this.bill, required this.isHistory, required this.currency});

  void _showPocketSelector(BuildContext context) {
    final pockets = context.read<PocketProvider>().pockets;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Center(child: Text("Bayar Menggunakan", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18))),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: pockets.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.transparent, height: 1),
            itemBuilder: (context, index) {
              final p = pockets[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: p.color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(p.icon, color: p.color, size: 20),
                ),
                title: Text(p.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                onTap: () {
                  context.read<BillProvider>().processPayment(bill, p.name);
                  Navigator.pop(context); 
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showBillDetailDialog(BuildContext context) {
    final bool isOverdue = bill.dueDate.isBefore(DateTime.now()) && !isHistory;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: isOverdue ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF4F46E5).withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(bill.isRecurring ? CupertinoIcons.repeat : CupertinoIcons.doc_text_fill, color: isOverdue ? Colors.red : const Color(0xFF4F46E5), size: 40),
              ),
              const SizedBox(height: 24),
              Text(bill.title, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(currency.format(bill.amount), style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF4F46E5))),
              const SizedBox(height: 32),
              _infoTile(CupertinoIcons.calendar, "Jatuh Tempo", DateFormat('dd MMMM yyyy', 'id_ID').format(bill.dueDate)),
              _infoTile(CupertinoIcons.info_circle, "Status", isHistory ? "Sudah Dibayar" : (isOverdue ? "Terlambat" : "Menunggu")),
              if (isHistory) _infoTile(CupertinoIcons.creditcard, "Metode Bayar", bill.paidWithPocket ?? "-"),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () {
                        context.read<BillProvider>().deleteBill(bill.id, isHistory);
                        Navigator.pop(context);
                      },
                      child: const Icon(CupertinoIcons.trash, color: Color(0xFFF43F5E), size: 22),
                    ),
                  ),
                  if (!isHistory) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); 
                          _showPocketSelector(context); 
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                        child: Text("Bayar Sekarang", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                  ]
                ],
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Tutup", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.w700))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF0F172A), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = bill.dueDate.isBefore(DateTime.now()) && !isHistory;
    return GestureDetector(
      onTap: () => _showBillDetailDialog(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: isOverdue ? Colors.red.withValues(alpha: 0.08) : const Color(0xFFF8FAFC), shape: BoxShape.circle),
              child: Icon(bill.isRecurring ? CupertinoIcons.repeat : CupertinoIcons.doc_text, color: isOverdue ? Colors.red : const Color(0xFF4F46E5), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(isHistory ? "💰 Selesai" : "⏰ Tempo: ${DateFormat('dd MMM').format(bill.dueDate)}", style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isOverdue ? Colors.red : const Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text(currency.format(bill.amount), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16, color: const Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }
}