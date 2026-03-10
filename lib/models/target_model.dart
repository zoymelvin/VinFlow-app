class TargetModel {
  final String id;
  final String title;
  final double targetAmount;
  final String pocketId;
  final String pocketName;
  final String icon;

  TargetModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.pocketId,
    required this.pocketName,
    required this.icon,
  });

  factory TargetModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TargetModel(
      id: id,
      title: data['title'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      pocketId: data['pocketId'] ?? '',
      pocketName: data['pocketName'] ?? '',
      icon: data['icon'] ?? '🎯',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'pocketId': pocketId,
      'pocketName': pocketName,
      'icon': icon,
    };
  }
}