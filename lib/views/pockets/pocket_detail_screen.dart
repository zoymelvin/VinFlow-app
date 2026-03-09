import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vinflow/views/pockets/transfer_screen.dart';
import 'package:vinflow/views/transactions/transaction_detail_screen.dart'; // Import Halaman Detail
import '../../models/pocket_model.dart';
import '../../models/transaction_model.dart'; // Import Model Transaksi
import '../../providers/pocket_provider.dart';
import 'widgets_detail/action_button.dart';
import 'widgets_detail/transaction_popup.dart';

class PocketDetailScreen extends StatelessWidget {
  final Pocket pocket;
  const PocketDetailScreen({super.key, required this.pocket});

  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text("Hapus Kantong?", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: const Text("Data saldo dan semua riwayat transaksi akan dihapus permanen."),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await Provider.of<PocketProvider>(context, listen: false).deletePocket(pocket.id);
              if (context.mounted) {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              }
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPocket = context.watch<PocketProvider>().pockets.firstWhere(
          (p) => p.id == pocket.id,
          orElse: () => pocket,
        );
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text("Detail Kantong", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _confirmDelete(context),
          child: const Icon(CupertinoIcons.trash, color: Colors.red, size: 22),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // HEADER KANTONG
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: currentPocket.id,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: currentPocket.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(currentPocket.icon, color: currentPocket.color, size: 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentPocket.name,
                    style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 24),
                  Text("Total Saldo", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    currencyFormat.format(currentPocket.balance),
                    style: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), letterSpacing: -1),
                  ),
                ],
              ),
            ),
          ),

          // ACTION BUTTONS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                children: [
                  DetailActionBtn(
                    icon: CupertinoIcons.paperplane_fill,
                    label: "Transfer Dana",
                    color: const Color(0xFF007BFF),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => TransferScreen(sourcePocket: currentPocket),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DetailActionBtn(
                          icon: CupertinoIcons.add_circled_solid,
                          label: "Isi Saldo",
                          color: const Color(0xFF10B981),
                          onTap: () => TransactionPopup.show(context, currentPocket, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DetailActionBtn(
                          icon: CupertinoIcons.minus_circle_fill,
                          label: "Kurangi",
                          color: Colors.orange,
                          onTap: () => TransactionPopup.show(context, currentPocket, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Text("Riwayat Transaksi", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),

          // LIST RIWAYAT TRANSAKSI
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pockets')
                .doc(currentPocket.id)
                .collection('transactions')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const SliverToBoxAdapter(child: Center(child: Text("Error memuat riwayat")));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text("Belum ada aktivitas", style: GoogleFonts.plusJakartaSans(color: Colors.grey))),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = snapshot.data!.docs[index];
                      // Konversi Firestore Doc ke TransactionModel
                      final trans = TransactionModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                      final isIncome = trans.type == 'income';

                      return GestureDetector(
                        onTap: () {
                          // NAVIGASI KE HALAMAN DETAIL BARU
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => TransactionDetailScreen(transaction: trans),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isIncome ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isIncome ? CupertinoIcons.arrow_down_left : CupertinoIcons.arrow_up_right,
                                  size: 18,
                                  color: isIncome ? Colors.green : Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trans.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    Text(
                                      DateFormat('dd MMM yyyy, HH:mm').format(trans.timestamp),
                                      style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${isIncome ? '+' : '-'} ${currencyFormat.format(trans.amount)}",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      color: isIncome ? const Color(0xFF10B981) : Colors.red,
                                    ),
                                  ),
                                  if (trans.imageUrl != null && trans.imageUrl!.isNotEmpty)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Icon(CupertinoIcons.photo, size: 12, color: Colors.blue),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}