import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class HistoryProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  
  String _selectedType = 'Semua'; 
  String _selectedCategory = 'Semua';
  DateTimeRange? _selectedDateRange;
  bool _isDescending = true;

  List<TransactionModel> get filteredTransactions => _filteredTransactions;
  String get selectedType => _selectedType;
  String get selectedCategory => _selectedCategory;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  bool get isDescending => _isDescending;

  HistoryProvider() {
    _listenToAllTransactions();
  }

  void _listenToAllTransactions() {
    _db.collectionGroup('transactions').snapshots().listen((snap) {
      _allTransactions = snap.docs.map((doc) => 
        TransactionModel.fromFirestore(doc.data(), doc.id)).toList();
      applyFilters();
    });
  }

  void applyFilters() {
    List<TransactionModel> temp = List.from(_allTransactions);

    if (_selectedType != 'Semua') {
      String typeKey = _selectedType == 'Pemasukan' ? 'income' : 'expense';
      temp = temp.where((t) => t.type == typeKey).toList();
    }

    if (_selectedCategory != 'Semua') {
      temp = temp.where((t) => t.category == _selectedCategory).toList();
    }

    if (_selectedDateRange != null) {
      temp = temp.where((t) {
        return t.timestamp.isAfter(_selectedDateRange!.start) && 
               t.timestamp.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    temp.sort((a, b) => _isDescending 
      ? b.timestamp.compareTo(a.timestamp) 
      : a.timestamp.compareTo(b.timestamp));

    _filteredTransactions = temp;
    notifyListeners();
  }

  void setType(String v) { _selectedType = v; applyFilters(); }
  void setCategory(String v) { _selectedCategory = v; applyFilters(); }
  void setDateRange(DateTimeRange? r) { _selectedDateRange = r; applyFilters(); }
  void toggleSort() { _isDescending = !_isDescending; applyFilters(); }
  
  void resetFilters() {
    _selectedType = 'Semua';
    _selectedCategory = 'Semua';
    _selectedDateRange = null;
    applyFilters();
  }

  void setQuickDate(int days) {
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1)),
      end: now
    );
    applyFilters();
  }
}