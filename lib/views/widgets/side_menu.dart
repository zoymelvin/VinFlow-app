import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vinflow/help/help_center_screen.dart';
import 'package:vinflow/views/security/security_screen.dart';
import '../profile/profile_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // LOGIKA BARU: RepaintBoundary memaksa GPU merender layer ini secara mandiri
    return RepaintBoundary(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.80,
        decoration: BoxDecoration(
          // Menggunakan warna putih dengan opacity 0.99 (Trik paksa GPU)
          color: Colors.white.withOpacity(0.99), 
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              Expanded(
                child: _buildMenuList(context),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('profile')
          .doc('user_profile')
          .snapshots(),
      builder: (context, snapshot) {
        String name = "User VinFlow";
        String email = "zoymelvin04@gmail.com"; 
        String? profileUrl;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? name;
          email = data['email'] ?? email;
          profileUrl = data['profileImageUrl'];
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: const Color(0xFF00509E),
                backgroundImage: (profileUrl != null && profileUrl.isNotEmpty)
                    ? NetworkImage(profileUrl)
                    : null,
                child: (profileUrl == null || profileUrl.isEmpty)
                    ? const Icon(CupertinoIcons.person_fill, color: Colors.white, size: 40)
                    : null,
              ),
              const SizedBox(height: 20),
              Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text(email, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF64748B))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      children: [
        _drawerItem(context, CupertinoIcons.house_fill, "Beranda", true, () => Navigator.pop(context)),
        _drawerItem(context, CupertinoIcons.person_crop_circle_fill, "Akun", false, () {
          Navigator.pop(context);
          Navigator.push(context, CupertinoPageRoute(builder: (context) => const ProfileScreen()));
        }),
        _drawerItem(context, CupertinoIcons.shield_fill, "Keamanan", false, () {
          Navigator.pop(context);
          Navigator.push(context, CupertinoPageRoute(builder: (context) => const SecurityScreen()));
        }),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Text("LAINNYA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 1.2)),
        ),
        _drawerItem(context, CupertinoIcons.question_circle_fill, "Pusat Bantuan", false, () {
          Navigator.pop(context);
          Navigator.push(context, CupertinoPageRoute(builder: (context) => const HelpCenterScreen()));
        }),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: const Text("VinFlow v1.0.0", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          ),
          const SizedBox(height: 8),
          const Text("© 2026 Joy Melvin. All rights reserved.", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, bool isSelected, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF007BFF) : const Color(0xFF475569), size: 24),
            const SizedBox(width: 16),
            Text(title, style: GoogleFonts.plusJakartaSans(color: isSelected ? const Color(0xFF007BFF) : const Color(0xFF1E293B), fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}