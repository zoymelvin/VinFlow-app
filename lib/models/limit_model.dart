import 'package:cloud_firestore/cloud_firestore.dart';

class LimitModel {
  final String id;
  final String title;
  final double limitAmount;
  final String? targetCategory;
  final String? targetPocketId;
  final DateTime startDate;
  final DateTime endDate;

  LimitModel({
    required this.id,
    required this.title,
    required this.limitAmount,
    this.targetCategory,
    this.targetPocketId,
    required this.startDate,
    required this.endDate,
  });

  factory LimitModel.fromFirestore(Map<String, dynamic> data, String id) {
    return LimitModel(
      id: id,
      title: data['title'] ?? '',
      limitAmount: (data['limitAmount'] ?? 0).toDouble(),
      targetCategory: data['targetCategory'],
      targetPocketId: data['targetPocketId'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'limitAmount': limitAmount,
      'targetCategory': targetCategory,
      'targetPocketId': targetPocketId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
}