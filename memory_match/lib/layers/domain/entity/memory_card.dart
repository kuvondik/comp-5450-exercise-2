import 'package:flutter/material.dart';

class MemoryCard {
  final int value;
  final IconData? icon;
  bool isMatched;
  bool isFlipped;

  MemoryCard({
    required this.value,
    this.icon,
    required this.isMatched,
    required this.isFlipped,
  });
}
