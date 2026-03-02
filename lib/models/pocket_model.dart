import 'package:flutter/cupertino.dart';

class Pocket {
  final String id;
  final String name;
  final double balance;
  final IconData icon;
  final Color color;

  Pocket({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
    required this.color,
  });
}