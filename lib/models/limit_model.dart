import 'package:cloud_firestore/cloud_firestore.dart';

class LimitModel {
  final String id;
  final String title;
  final double limitAmount;
  final double totalSpent;
  final String? targetCategory;
  final String? targetPocketId;
  final DateTime startDate;
  final DateTime endDate;
  // Penanda notifikasi agar tidak duplikat
  final bool hasSentWarning; // Untuk fase Orange (40%)
  final bool hasSentCritical; // Untuk fase Merah (15%)

  LimitModel({
    required this.id,
    required this.title,
    required this.limitAmount,
    this.totalSpent = 0,
    this.targetCategory,
    this.targetPocketId,
    required this.startDate,
    required this.endDate,
    this.hasSentWarning = false,
    this.hasSentCritical = false,
  });

  factory LimitModel.fromFirestore(Map<String, dynamic> data, String id) {
    return LimitModel(
      id: id,
      title: data['title'] ?? '',
      limitAmount: (data['limitAmount'] ?? 0).toDouble(),
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      targetCategory: data['targetCategory'],
      targetPocketId: data['targetPocketId'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      hasSentWarning: data['hasSentWarning'] ?? false,
      hasSentCritical: data['hasSentCritical'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'limitAmount': limitAmount,
      'totalSpent': totalSpent,
      'targetCategory': targetCategory,
      'targetPocketId': targetPocketId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'hasSentWarning': hasSentWarning,
      'hasSentCritical': hasSentCritical,
    };
  }
}