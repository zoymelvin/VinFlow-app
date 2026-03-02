import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/pocket_provider.dart';
import 'widgets_list/pocket_card.dart';
import 'widgets_list/add_pocket_popup.dart';

class PocketListScreen extends StatefulWidget {
  const PocketListScreen({super.key});

  @override
  State<PocketListScreen> createState() => _PocketListScreenState();
}

class _PocketListScreenState extends State<PocketListScreen> {
  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Baris fetchPockets dihapus dari sini karena sudah dipanggil 
    // secara global di main.dart menggunakan operator cascade (..fetchPockets()).
    // Ini mencegah pemborosan kuota read Firebase dan tabrakan data.
  }

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan data dari PocketProvider secara realtime.
    final pocketProvider = Provider.of<PocketProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text(
          "Daftar Kantong",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, 
            fontSize: 17,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 0.5,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Memberikan jarak aman di bagian atas daftar
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pocket = pocketProvider.pockets[index];
                  // Menampilkan kartu kantong berdasarkan data dari Firestore.
                  return PocketCard(pocket: pocket);
                },
                childCount: pocketProvider.pockets.length,
              ),
            ),
          ),

          // Tombol untuk menambah kantong baru
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => AddPocketPopup.show(context),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.add_circled_solid,
                        color: Color(0xFF475569),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Tambah Kantong Baru",
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Memberikan padding bawah ekstra agar konten tidak terpotong navbar
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}