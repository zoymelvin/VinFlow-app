import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

// Model data khusus untuk Grafik Syncfusion
class WeeklyChartData {
  final String weekLabel;
  final double income;
  final double expense;

  WeeklyChartData(this.weekLabel, this.income, this.expense);
}

class ReportProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  
  double _totalIncome = 0;
  double _totalExpense = 0;
  Map<String, double> _categoryTotals = {};
  List<WeeklyChartData> _weeklyChartData = []; // Data baru untuk Bar Chart
  bool _isLoading = false;

  double _avgDailyExpense = 0;
  double _dailySpendingAdvice = 0;
  String _mostExpensiveCategory = "-";
  double _trendPercentage = 12.5;

  // Getters
  DateTimeRange get selectedDateRange => _selectedDateRange;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get netCashFlow => _totalIncome - _totalExpense;
  Map<String, double> get categoryTotals => _categoryTotals;
  List<WeeklyChartData> get weeklyChartData => _weeklyChartData;
  bool get isLoading => _isLoading;
  double get avgDailyExpense => _avgDailyExpense;
  double get dailySpendingAdvice => _dailySpendingAdvice;
  String get mostExpensiveCategory => _mostExpensiveCategory;
  double get trendPercentage => _trendPercentage;

  void updateDateRange(DateTimeRange newRange, {String? pocketId}) {
    _selectedDateRange = newRange;
    fetchReportData(pocketId: pocketId);
  }

  String _mapTitleToCategory(String title, String? existingCategory) {
    if (existingCategory != null && existingCategory != 'Lainnya' && existingCategory.isNotEmpty) {
      return existingCategory;
    }
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('makan') || lowerTitle.contains('minum') || lowerTitle.contains('nasi')) return 'Makanan';
    if (lowerTitle.contains('hobi') || lowerTitle.contains('game') || lowerTitle.contains('nonton')) return 'Hobi';
    if (lowerTitle.contains('kuota') || lowerTitle.contains('pulsa') || lowerTitle.contains('internet')) return 'Kuota';
    if (lowerTitle.contains('bensin') || lowerTitle.contains('ojek') || lowerTitle.contains('grab')) return 'Transport';
    return 'Lainnya';
  }

  Future<void> fetchReportData({String? pocketId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Query query;
      if (pocketId != null && pocketId.isNotEmpty) {
        query = _db.collection('pockets').doc(pocketId).collection('transactions');
      } else {
        query = _db.collectionGroup('transactions');
      }

      final snapshot = await query
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDateRange.start))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(_selectedDateRange.end.add(const Duration(days: 1))))
          .get();

      _totalIncome = 0;
      _totalExpense = 0;
      _categoryTotals = {};
      
      // Logika pengelompokan mingguan
      Map<int, double> weeklyIncome = {};
      Map<int, double> weeklyExpense = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final tx = TransactionModel.fromFirestore(data, doc.id);

        // Hitung minggu ke-berapa dari tanggal awal range
        int dayDiff = tx.timestamp.difference(_selectedDateRange.start).inDays;
        int weekIndex = (dayDiff / 7).floor() + 1;

        if (tx.type == 'income') {
          _totalIncome += tx.amount;
          weeklyIncome[weekIndex] = (weeklyIncome[weekIndex] ?? 0) + tx.amount;
        } else {
          _totalExpense += tx.amount;
          weeklyExpense[weekIndex] = (weeklyExpense[weekIndex] ?? 0) + tx.amount;
          
          String categoryName = _mapTitleToCategory(tx.title, data['category']);
          _categoryTotals[categoryName] = (_categoryTotals[categoryName] ?? 0) + tx.amount;
        }
      }

      // Bangun List ChartData (Maksimal 4-5 minggu sesuai range 30 hari)
      _weeklyChartData = [];
      for (int i = 1; i <= 5; i++) {
        double inc = weeklyIncome[i] ?? 0;
        double exp = weeklyExpense[i] ?? 0;
        // Hanya tambahkan jika ada data agar tidak kosong
        if (inc > 0 || exp > 0) {
          _weeklyChartData.add(WeeklyChartData("Minggu $i", inc, exp));
        }
      }

      // Kalkulasi Insight
      int totalDays = _selectedDateRange.duration.inDays + 1;
      _avgDailyExpense = _totalExpense / totalDays;

      DateTime now = DateTime.now();
      int lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      int remainingDays = (lastDayOfMonth - now.day) + 1;
      if (remainingDays <= 0) remainingDays = 1;
      _dailySpendingAdvice = netCashFlow > 0 ? netCashFlow / remainingDays : 0;

      if (_categoryTotals.isNotEmpty) {
        _mostExpensiveCategory = _categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint("Provider Error: $e");
      notifyListeners();
    }
  }
}