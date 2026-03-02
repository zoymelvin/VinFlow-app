import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vinflow/providers/pocket_provider.dart';
import 'package:vinflow/providers/profile_provider.dart';
import 'firebase_options.dart'; 
import 'core/theme/app_theme.dart';
import 'providers/transaction_provider.dart';
import 'views/dashboard/dashboard_screen.dart';

void main() async {
  // Memastikan binding Flutter sudah siap sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase sesuai konfigurasi platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const VinFlowApp());
}

class VinFlowApp extends StatelessWidget {
  const VinFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider untuk manajemen transaksi
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        
        // FIX: Menambahkan cascade operator (..fetchPockets()) agar data kantong 
        // langsung ditarik secara realtime saat aplikasi pertama kali dijalankan.
        // Ini akan menyelesaikan masalah saldo Rp0 di Dashboard.
        ChangeNotifierProvider(create: (_) => PocketProvider()..fetchPockets()),
        
        // Provider untuk manajemen profil user
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: CupertinoApp(
        title: 'VinFlow',
        theme: AppTheme.iosTheme, // Menggunakan tema iOS kustom kamu
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          // Membungkus builder dengan Theme Material agar Google Fonts bisa berjalan di CupertinoApp
          return Theme(
            data: ThemeData(
              textTheme: GoogleFonts.interTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            child: child!,
          );
        },
        // Halaman awal aplikasi langsung ke Dashboard
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}