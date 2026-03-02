import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final isIncome = transaction.type == 'income';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CupertinoNavigationBar(
        middle: Text("Detail Transaksi", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Nominal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Text(transaction.category, 
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Text(
                    "${isIncome ? '+' : '-'} ${currencyFormat.format(transaction.amount)}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 36, 
                      fontWeight: FontWeight.w800, 
                      color: isIncome ? const Color(0xFF10B981) : Colors.red,
                      letterSpacing: -1
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(DateFormat('EEEE, dd MMMM yyyy - HH:mm').format(transaction.timestamp),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. Info Detail
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Catatan", transaction.title),
                  const Divider(height: 32, color: Color(0xFFF1F5F9)),
                  _buildDetailRow("Status", "Berhasil"),
                  const SizedBox(height: 32),

                  // 3. Lampiran Foto (Jika Ada)
                  if (transaction.imageUrl != null && transaction.imageUrl!.isNotEmpty) ...[
                    Text("Lampiran Foto", 
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _showFullScreenImage(context, transaction.imageUrl!),
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            transaction.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CupertinoActivityIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) => 
                              const Center(child: Icon(CupertinoIcons.photo, color: Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Tampilan jika tidak ada foto
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          const Icon(CupertinoIcons.photo, color: Colors.grey, size: 32),
                          const SizedBox(height: 8),
                          Text("Tidak ada lampiran foto", 
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
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

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
      ],
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
            child: Container(color: Colors.black.withValues(alpha: 0.9)),
          ),
          Center(
            child: InteractiveViewer(
              child: Image.network(url),
            ),
          ),
          Positioned(
            top: 40, right: 20,
            child: CupertinoButton(
              child: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}