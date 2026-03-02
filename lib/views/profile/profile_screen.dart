import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // AppBar transparan agar fokus ke konten
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CupertinoButton(
          child: const Icon(CupertinoIcons.back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profil Saya",
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('profile').doc('user_profile').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());
          
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final bool isAnyEmpty = data['name'] == null || data['country'] == null || data['phone'] == null || data['bio'] == null;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildProfileCard(context, data),
                if (isAnyEmpty) _buildWarningCard(),
                _buildDetailsSection(data),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // Bagian Atas: Kartu Profil Utama dengan Tombol Edit Terintegrasi
  Widget _buildProfileCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007BFF), Color(0xFF0056D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007BFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // Tombol Edit di Pojok Kanan Atas Kartu
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const EditProfileScreen())),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.pencil, color: Colors.white, size: 20),
              ),
            ),
          ),
          Column(
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFF1F5F9),
                    backgroundImage: (data['profileImageUrl'] != null && data['profileImageUrl'] != "") 
                        ? NetworkImage(data['profileImageUrl']) 
                        : null,
                    child: (data['profileImageUrl'] == null || data['profileImageUrl'] == "") 
                        ? const Icon(CupertinoIcons.person_fill, size: 50, color: Color(0xFFCBD5E1)) 
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                data['name'] ?? "User VinFlow",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data['email'] ?? "zoymelvin04@gmail.com",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Notifikasi Jika Data Belum Lengkap
  Widget _buildWarningCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.info_circle_fill, color: Color(0xFFF97316), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Profil kamu belum lengkap nih, Vin! Yuk lengkapi datanya.",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9A3412),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bagian Detail Informasi
  Widget _buildDetailsSection(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informasi Pribadi",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoTile("Negara Asal", data['country'] ?? "Belum diisi", CupertinoIcons.globe, const Color(0xFF007BFF)),
          _buildInfoTile("Nomor Telepon", data['phone'] ?? "Belum diisi", CupertinoIcons.phone_fill, const Color(0xFF10B981)),
          _buildInfoTile("Tentang Saya", data['bio'] ?? "Tulis sesuatu tentang dirimu...", CupertinoIcons.doc_plaintext, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}