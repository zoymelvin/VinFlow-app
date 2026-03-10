import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vinflow/providers/bill_provider.dart';
import 'package:vinflow/providers/history_provider.dart';
import 'package:vinflow/providers/limit_provider.dart';
import 'package:vinflow/providers/pocket_provider.dart';
import 'package:vinflow/providers/profile_provider.dart';
import 'package:vinflow/providers/report_provider.dart';
import 'package:vinflow/providers/target_provider.dart';
import 'package:vinflow/providers/transaction_provider.dart';
import 'firebase_options.dart'; 
import 'core/theme/app_theme.dart';
import 'views/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('id_ID', null);
  
  runApp(const VinFlowApp());
}

class VinFlowApp extends StatelessWidget {
  const VinFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        // PENTING: PocketProvider memanggil fetchPockets di awal
        ChangeNotifierProvider(create: (_) => PocketProvider()..fetchPockets()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => LimitProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => TargetProvider()),
      ],
      child: CupertinoApp(
        title: 'VinFlow',
        theme: AppTheme.iosTheme, 
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        builder: (context, child) {
          return Theme(
            data: ThemeData(
              useMaterial3: true,
              textTheme: GoogleFonts.interTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            child: child!,
          );
        },
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}