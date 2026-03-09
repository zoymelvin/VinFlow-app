import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vinflow/providers/limit_provider.dart';
import 'package:vinflow/providers/pocket_provider.dart';
import 'package:vinflow/providers/profile_provider.dart';
import 'package:vinflow/providers/report_provider.dart';
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
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => PocketProvider()..fetchPockets()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => LimitProvider()),
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