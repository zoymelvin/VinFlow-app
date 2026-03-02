import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction_model.dart';
import '../../transactions/transaction_detail_screen.dart';

class TransactionSection extends StatelessWidget {
  const TransactionSection({super.key});

  // Fungsi pembantu untuk mendapatkan Icon dan Warna berdasarkan Kategori atau Judul
  Map<String, dynamic> _getCategoryStyle(String categoryName, bool isIncome) {
    if (isIncome) {
      return {
        'icon': CupertinoIcons.money_dollar_circle_fill,
        'color': Colors.green,
      };
    }

    // Normalisasi nama agar pengecekan lebih akurat
    final name = categoryName.trim();

    switch (name) {
      case 'Belanja':
        return {'icon': CupertinoIcons.bag_fill, 'color': Colors.orange};
      case 'Makan':
        return {'icon': CupertinoIcons.cart_fill, 'color': Colors.red};
      case 'Transport':
        return {'icon': CupertinoIcons.bus, 'color': Colors.blue};
      case 'Hobi':
        return {'icon': CupertinoIcons.gamecontroller_fill, 'color': Colors.purple};
      case 'Kuota':
        return {'icon': CupertinoIcons.wifi, 'color': Colors.indigo};
      case 'Gaji':
        return {'icon': CupertinoIcons.money_dollar_circle_fill, 'color': Colors.green};
      default:
        // Jika tidak cocok dengan list di atas, gunakan gaya 'Lainnya'
        return {'icon': CupertinoIcons.ellipsis_circle_fill, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('transactions')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(twentyFourHoursAgo))
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Firestore Error: ${snapshot.error}");
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildErrorState(snapshot.error.toString()),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CupertinoActivityIndicator()),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final doc = snapshot.data!.docs[index];
                final trans = TransactionModel.fromFirestore(doc);
                return _buildTransactionCard(context, trans);
              },
              childCount: snapshot.data!.docs.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionModel trans) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final isIncome = trans.type == 'income';
    
    // PERBAIKAN: Gunakan trans.category jika ada, jika tidak gunakan trans.title 
    // agar sinkron dengan data di database (image_cbd31e.png)
    final displayCategory = (trans.category.isEmpty || trans.category == 'Lainnya') 
        ? trans.title 
        : trans.category;

    // Ambil gaya (ikon & warna) berdasarkan kategori yang sudah ditentukan
    final style = _getCategoryStyle(displayCategory, isIncome);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => TransactionDetailScreen(transaction: trans),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            // Ikon Kategori Dinamis
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (style['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                style['icon'] as IconData,
                color: style['color'] as Color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Konten Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trans.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700, 
                      fontSize: 15, 
                      color: const Color(0xFF0F172A)
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('HH:mm').format(trans.timestamp),
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      // Tampilkan kategori yang sudah diperbaiki
                      Text(
                        displayCategory,
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Nominal & Attachment Icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isIncome ? '+' : '-'} ${currencyFormat.format(trans.amount)}",
                  style: GoogleFonts.plusJakartaSans(
                    color: isIncome ? const Color(0xFF10B981) : Colors.redAccent,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                if (trans.imageUrl != null && trans.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.photo, size: 10, color: Color(0xFF007BFF)),
                        const SizedBox(width: 4),
                        Text("Lampiran", style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF007BFF), fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: const Icon(CupertinoIcons.doc_text_search, color: Color(0xFF94A3B8), size: 40),
          ),
          const SizedBox(height: 20),
          Text("Belum Ada Aktivitas", 
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17, color: const Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text("Transaksi 24 jam terakhir akan muncul di sini", 
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    bool isIndexError = error.contains("FAILED_PRECONDITION");
    return Center(
      child: Column(
        children: [
          const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.amber, size: 40),
          const SizedBox(height: 16),
          Text(
            isIndexError ? "Sinkronisasi Database" : "Koneksi Terputus",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            isIndexError ? "Sedang menyiapkan indeks kueri..." : "Pastikan internet kamu stabil.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}