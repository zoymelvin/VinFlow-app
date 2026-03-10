import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime dueDate;
  final bool isPaid;
  final bool isRecurring;
  final bool isIntervalMode;
  final int intervalDays;
  final String? paidWithPocket;

  BillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.dueDate,
    this.isPaid = false,
    this.isRecurring = false,
    this.isIntervalMode = false,
    this.intervalDays = 30,
    this.paidWithPocket,
  });

  factory BillModel.fromFirestore(Map<String, dynamic> data, String id) {
    // LOGIKA PERBAIKAN: Penanganan Timestamp Null di Web
    DateTime parsedDate;
    if (data['dueDate'] == null) {
      parsedDate = DateTime.now(); // Default sementara jika server belum respon
    } else if (data['dueDate'] is Timestamp) {
      parsedDate = (data['dueDate'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return BillModel(
      id: id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'Lainnya',
      dueDate: parsedDate,
      isPaid: data['isPaid'] ?? false,
      isRecurring: data['isRecurring'] ?? false,
      isIntervalMode: data['isIntervalMode'] ?? false,
      intervalDays: data['intervalDays'] ?? 30,
      paidWithPocket: data['paidWithPocket'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'isRecurring': isRecurring,
      'isIntervalMode': isIntervalMode,
      'intervalDays': intervalDays,
      'paidWithPocket': paidWithPocket,
      // Penting: Selalu kirim server timestamp untuk audit
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}