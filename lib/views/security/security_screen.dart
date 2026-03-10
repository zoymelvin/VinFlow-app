import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isBiometricActive = true;
  bool _isTwoFactorActive = false;
  bool _isHideBalanceActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CupertinoNavigationBar(
        middle: Text("Keamanan Akun", 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER STATUS KEAMANAN ---
            _buildSecurityStatusHeader(),

            const SizedBox(height: 10),

            // --- SECTION: AUTHENTICATION ---
            _buildSectionTitle("Autentikasi"),
            _buildSecurityCard([
              _buildSecurityTile(
                icon: CupertinoIcons.lock_shield_fill,
                color: Colors.blue,
                title: "Ubah PIN Transaksi",
                subtitle: "Terakhir diubah 2 bulan lalu",
                onTap: () {},
              ),
              _buildSecurityTile(
                icon: CupertinoIcons.lock_fill,
                color: Colors.indigo,
                title: "Ubah Kata Sandi",
                subtitle: "Amankan akun dengan sandi baru",
                onTap: () {},
              ),
              _buildSwitchTile(
                icon: CupertinoIcons.viewfinder,
                color: Colors.purple,
                title: "Biometrik (Face ID / Fingerprint)",
                value: _isBiometricActive,
                onChanged: (val) => setState(() => _isBiometricActive = val),
              ),
            ]),

            // --- SECTION: PRIVACY ---
            _buildSectionTitle("Privasi & Akses"),
            _buildSecurityCard([
              _buildSwitchTile(
                icon: CupertinoIcons.eye_slash_fill,
                color: Colors.orange,
                title: "Sembunyikan Saldo",
                value: _isHideBalanceActive,
                onChanged: (val) => setState(() => _isHideBalanceActive = val),
              ),
              _buildSwitchTile(
                icon: CupertinoIcons.shield_lefthalf_fill,
                color: Colors.teal,
                title: "Autentikasi Dua Faktor (2FA)",
                value: _isTwoFactorActive,
                onChanged: (val) => setState(() => _isTwoFactorActive = val),
              ),
            ]),

            // --- SECTION: LOG LOGIN ---
            _buildSectionTitle("Perangkat & Sesi"),
            _buildSecurityCard([
              _buildSecurityTile(
                icon: CupertinoIcons.device_phone_portrait,
                color: Colors.grey,
                title: "Sesi Aktif",
                subtitle: "3 perangkat sedang login",
                onTap: () => _showActiveSessions(context),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text("Aman", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),

            const SizedBox(height: 40),
            
            // Tombol Hapus Akun (Opsi Keamanan Terakhir)
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text("Tutup Akun VinFlow", 
                  style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.shield_fill, color: Color(0xFF4F46E5), size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Skor Keamanan: 85%", 
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text("Akun Anda terlindungi dengan sangat baik. Aktifkan 2FA untuk mencapai 100%.", 
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(title.toUpperCase(), 
        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1.2)),
    );
  }

  Widget _buildSecurityCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSecurityTile({
    required IconData icon, 
    required Color color, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF1E293B))),
      subtitle: Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(CupertinoIcons.chevron_right, size: 14, color: Colors.grey),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon, 
    required Color color, 
    required String title, 
    required bool value, 
    required Function(bool) onChanged
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF1E293B))),
      trailing: CupertinoSwitch(
        activeColor: const Color(0xFF4F46E5),
        value: value, 
        onChanged: onChanged,
      ),
    );
  }

  void _showActiveSessions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Sesi Login Aktif"),
        message: const Text("Gunakan fitur ini untuk logout dari perangkat lain jika Anda merasa ada aktivitas mencurig."),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("iPhone 15 Pro (Perangkat Ini)"),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("Logout dari MacBook Air"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text("Tutup"),
        ),
      ),
    );
  }
}