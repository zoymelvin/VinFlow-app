import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/pocket_provider.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final pocketProvider = Provider.of<PocketProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: Stack(
          children: [
            // Dekorasi Background Mewah
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: const Color(0xFF007BFF).withValues(alpha: 0.04),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -40,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange.withValues(alpha: 0.03),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007BFF).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(CupertinoIcons.shield_fill, color: Color(0xFF007BFF), size: 14),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Total Saldo VinFlow",
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                        child: Icon(
                          _isBalanceVisible ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                          color: const Color(0xFF94A3B8),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isBalanceVisible ? currencyFormat.format(pocketProvider.totalBalance) : "••••••••",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Ringkasan Harian (Pemasukan & Pengeluaran)
                  Row(
                    children: [
                      _buildDailyInfo(
                        label: "Pemasukan",
                        amount: pocketProvider.todayIncome,
                        color: const Color(0xFF10B981),
                        icon: CupertinoIcons.arrow_down_left,
                        isIncome: true,
                        visible: _isBalanceVisible,
                      ),
                      Container(width: 1, height: 30, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(horizontal: 16)),
                      _buildDailyInfo(
                        label: "Pengeluaran",
                        amount: pocketProvider.todayExpense,
                        color: Colors.redAccent,
                        icon: CupertinoIcons.arrow_up_right,
                        isIncome: false,
                        visible: _isBalanceVisible,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer Kantong
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.layers_fill, color: Color(0xFF007BFF), size: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Terbagi di ${pocketProvider.pockets.length} Kantong Aktif",
                            style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF475569),
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyInfo({
    required String label, 
    required double amount, 
    required Color color, 
    required IconData icon, 
    required bool isIncome,
    required bool visible
  }) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            visible ? "${isIncome ? '+' : '-'} ${fmt.format(amount)}" : "••••",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, 
              fontWeight: FontWeight.w700, 
              color: color
            ),
          ),
        ],
      ),
    );
  }
}