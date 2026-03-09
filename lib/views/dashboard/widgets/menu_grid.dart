import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vinflow/views/limits/limit_screen.dart';
import 'package:vinflow/views/pockets/pocket_list_screen.dart';
import 'package:vinflow/views/reports/report_screen.dart';
import 'package:vinflow/views/transactions/transaction_screen.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildListDelegate([
          _buildMenu(context, CupertinoIcons.add_circled_solid, "Transaksi", Colors.blue, () {
            // Navigasi ke Daftar Transaksi
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const TransactionScreen()),
            );
            // Aksi untuk Tambah
          }),
          _buildMenu(context, CupertinoIcons.creditcard_fill, "Kantong", Colors.deepOrangeAccent, () {
            // Navigasi ke Daftar Kantong
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const PocketListScreen()),
            );
          }),
          _buildMenu(context, CupertinoIcons.graph_circle_fill, "Limit", Colors.red, () {
            // Navigasi ke Limit
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const LimitScreen()),
            );
          }),
          
          _buildMenu(context, CupertinoIcons.time_solid, "Riwayat", Colors.green, () {}),
          _buildMenu(context, CupertinoIcons.doc_text_fill, "Laporan", Colors.purple, () {
            // Navigasi ke Laporan
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const ReportScreen()),
            );
          }),
          _buildMenu(context, CupertinoIcons.bell_fill, "Tagihan", Colors.amber, () {}),
          _buildMenu(context, CupertinoIcons.scope, "Target", Colors.teal, () {}),
          _buildMenu(context, CupertinoIcons.ellipsis_circle_fill, "Lainnya", Colors.blueGrey, () {}),
        ]),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}