import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income' atau 'expense'
  final String category;
  final String? imageUrl;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.imageUrl,
    required this.timestamp,
  });

  // Perbaikan factory untuk mendukung pengambilan data dari DocumentSnapshot atau Map mentah
  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? 'expense',
      category: data['category'] ?? 'Lainnya',
      imageUrl: data['imageUrl'],
      // Mengamankan konversi timestamp jika field null di database
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
}