import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CupertinoNavigationBar(
        middle: Text("Pusat Bantuan", 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- HEADER SEARCH PLACEHOLDER ---
            _buildHelpHeader(),

            const SizedBox(height: 10),

            // --- FAQ LIST ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Pertanyaan Populer"),
                  _buildFAQItem(
                    icon: CupertinoIcons.question_circle_fill,
                    color: Colors.blue,
                    question: "Apa itu VinFlow?",
                    answer: "VinFlow adalah aplikasi manajemen keuangan pribadi yang membantu Anda melacak transaksi, mengelola kantong saldo, menetapkan limit pengeluaran, dan memantau target impian Anda secara realtime.",
                  ),
                  _buildFAQItem(
                    icon: CupertinoIcons.creditcard_fill,
                    color: Colors.orange,
                    question: "Bagaimana cara menambah saldo kantong?",
                    answer: "Anda dapat menambah saldo dengan mencatat transaksi baru tipe 'Pemasukan' di halaman Transaksi, lalu pilih kantong tujuan yang ingin Anda tambahkan saldonya.",
                  ),
                  _buildFAQItem(
                    icon: CupertinoIcons.shield_fill,
                    color: Colors.green,
                    question: "Apakah data keuangan saya aman?",
                    answer: "Ya, VinFlow menggunakan Firebase dengan enkripsi tingkat tinggi. Selain itu, Anda dapat mengaktifkan fitur Biometrik (Face ID/Fingerprint) di menu Keamanan untuk perlindungan ekstra.",
                  ),
                  _buildFAQItem(
                    icon: CupertinoIcons.bell_fill,
                    color: Colors.redAccent,
                    question: "Kenapa saya tidak mendapat notifikasi tagihan?",
                    answer: "Pastikan Anda sudah memberikan izin notifikasi pada pengaturan perangkat Anda dan sudah mengisi tanggal jatuh tempo dengan benar pada fitur Manajemen Tagihan.",
                  ),
                  
                  const SizedBox(height: 20),
                  _buildSectionTitle("Manajemen Akun"),
                  _buildFAQItem(
                    icon: CupertinoIcons.person_crop_circle_fill,
                    color: Colors.purple,
                    question: "Cara mengubah foto profil?",
                    answer: "Buka menu Side Menu, lalu tekan bagian profil Anda atau buka halaman Akun. Di sana Anda dapat mengunggah foto profil baru dari galeri ponsel Anda.",
                  ),
                  _buildFAQItem(
                    icon: CupertinoIcons.refresh_bold,
                    color: Colors.teal,
                    question: "Data tidak sinkron, apa yang harus dilakukan?",
                    answer: "Pastikan koneksi internet Anda stabil. Jika data masih belum muncul, coba lakukan 'Pull-to-refresh' di halaman Dashboard atau mulai ulang aplikasi (Restart).",
                  ),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Target & Limit"),
                  _buildFAQItem(
                    icon: Icons.tablet,
                    color: Colors.indigo,
                    question: "Bagaimana cara kerja fitur Target?",
                    answer: "Fitur Target memantau saldo dari kantong yang Anda hubungkan. Progres akan otomatis bertambah jika saldo di kantong tersebut naik mendekati nominal target yang Anda buat.",
                  ),
                  _buildFAQItem(
                    icon: CupertinoIcons.chart_bar_fill,
                    color: Colors.pink,
                    question: "Apa yang terjadi jika pengeluaran melebihi limit?",
                    answer: "VinFlow akan memberikan peringatan visual pada halaman Limit dan mengirimkan notifikasi agar Anda lebih berhati-hati dalam melakukan pengeluaran berikutnya.",
                  ),
                ],
              ),
            ),

            // --- FOOTER CONTACT ---
            _buildContactSupport(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Text("Ada yang bisa kami bantu?", 
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 22, color: const Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Text("Cari jawaban dari pertanyaan Anda di bawah ini atau hubungi tim dukungan kami.", 
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 10),
      child: Text(title, 
        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
    );
  }

  Widget _buildFAQItem({
    required IconData icon, 
    required Color color, 
    required String question, 
    required String answer
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(question, 
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF1E293B))),
          iconColor: const Color(0xFF4F46E5),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text(answer, 
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), height: 1.5, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupport() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text("Masih butuh bantuan?", 
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Text("Hubungi kami melalui email atau chat jika masalah Anda belum teratasi.", 
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: const Text("Hubungi CS", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}