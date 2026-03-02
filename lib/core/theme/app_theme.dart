import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static CupertinoThemeData get iosTheme {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF007BFF),
      // Menerapkan Inter ke seluruh teks aplikasi
      textTheme: CupertinoTextThemeData(
        textStyle: GoogleFonts.inter(
          color: const Color(0xFF1E293B),
          fontSize: 16,
        ),
        navActionTextStyle: GoogleFonts.inter(
          color: const Color(0xFF007BFF),
          fontWeight: FontWeight.w600,
        ),
        navTitleTextStyle: GoogleFonts.inter(
          color: const Color(0xFF1E293B),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}