import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  // Fungsi untuk mendapatkan icon berdasarkan kategori
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Belanja': return CupertinoIcons.bag_fill;
      case 'Makan': return CupertinoIcons.cart_fill;
      case 'Transport': return CupertinoIcons.bus;
      case 'Hobi': return CupertinoIcons.gamecontroller_fill;
      case 'Kuota': return CupertinoIcons.wifi;
      case 'Gaji': return CupertinoIcons.money_dollar_circle_fill;
      default: return CupertinoIcons.ellipsis_circle_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inisialisasi format mata uang dan tanggal bahasa Indonesia
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');
    
    final isIncome = transaction.type == 'income';
    final themeColor = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text("Detail Transaksi", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Header Section (Premium Visual)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  // Icon Kategori Melingkar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(transaction.category),
                      color: themeColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Badge Tipe
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isIncome ? "Pemasukan" : "Pengeluaran",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, 
                        fontSize: 11, 
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nominal Besar
                  Text(
                    "${isIncome ? '+' : '-'} ${currencyFormat.format(transaction.amount)}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 38, 
                      fontWeight: FontWeight.w900, 
                      color: const Color(0xFF0F172A),
                      letterSpacing: -1.5
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, 
                      color: const Color(0xFF64748B), 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoCard([
                    _buildInfoRow("Kategori", transaction.category, CupertinoIcons.tag_fill),
                    _buildInfoRow("Waktu", timeFormat.format(transaction.timestamp), CupertinoIcons.clock_fill),
                    _buildInfoRow("Tanggal", dateFormat.format(transaction.timestamp), CupertinoIcons.calendar),
                    _buildInfoRow("Status", "Berhasil Diterima", CupertinoIcons.check_mark_circled_solid, valueColor: const Color(0xFF10B981)),
                  ]),
                  
                  const SizedBox(height: 20),

                  // 3. Lampiran Section
                  if (transaction.imageUrl != null && transaction.imageUrl!.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: Text("Lampiran Bukti", 
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFF1E293B))),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showFullScreenImage(context, transaction.imageUrl!),
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          image: DecorationImage(
                            image: NetworkImage(transaction.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                            ),
                          ),
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.all(16),
                          child: const Icon(CupertinoIcons.fullscreen, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Empty state lampiran yang lebih manis
                    Container(
                      padding: const EdgeInsets.all(30),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        children: [
                          Icon(CupertinoIcons.photo_on_rectangle, color: Colors.grey.withValues(alpha: 0.3), size: 40),
                          const SizedBox(height: 12),
                          Text("Tidak ada lampiran foto", 
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 14),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, 
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, 
              fontWeight: FontWeight.w700, 
              color: valueColor ?? const Color(0xFF1E293B)
            )
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.black),
          ),
          Center(
            child: InteractiveViewer(
              child: Image.network(url),
            ),
          ),
          Positioned(
            top: 50, right: 20,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white, size: 35),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}