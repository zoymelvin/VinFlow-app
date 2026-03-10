import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vinflow/views/limits/limit_screen.dart';
import 'package:vinflow/views/pockets/pocket_list_screen.dart';
import 'package:vinflow/views/reports/report_screen.dart';
import 'package:vinflow/views/targets/target_screen.dart';
import 'package:vinflow/views/transactions/transaction_screen.dart';
import 'package:vinflow/views/bills/bill_screen.dart';
import 'package:vinflow/views/history/history_screen.dart'; 

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
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const TransactionScreen()),
            );
          }),
          _buildMenu(context, CupertinoIcons.creditcard_fill, "Kantong", Colors.deepOrangeAccent, () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const PocketListScreen()),
            );
          }),
          _buildMenu(context, CupertinoIcons.graph_circle_fill, "Limit", Colors.red, () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const LimitScreen()),
            );
          }),
          
          _buildMenu(context, CupertinoIcons.time_solid, "Riwayat", Colors.green, () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const HistoryScreen()),
            );
          }),
          
          _buildMenu(context, CupertinoIcons.doc_text_fill, "Laporan", Colors.purple, () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const ReportScreen()),
            );
          }),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bills')
                .where('isPaid', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int pendingBills = snapshot.data?.docs.length ?? 0;
              return _buildMenu(
                context, 
                CupertinoIcons.bell_fill, 
                "Tagihan", 
                Colors.amber, 
                () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const BillScreen()),
                  );
                },
                badgeCount: pendingBills,
              );
            },
          ),
          
          _buildMenu(context, CupertinoIcons.scope, "Target", Colors.teal, () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const TargetScreen()),
            );
          }),
          _buildMenu(context, CupertinoIcons.ellipsis_circle_fill, "Lainnya", Colors.blueGrey, () {}),
        ]),
      ),
    );
  }

  Widget _buildMenu(
    BuildContext context, 
    IconData icon, 
    String label, 
    Color color, 
    VoidCallback onTap, 
    {int badgeCount = 0}
  ) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
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
              if (badgeCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF43F5E), 
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 9 ? "9+" : "$badgeCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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