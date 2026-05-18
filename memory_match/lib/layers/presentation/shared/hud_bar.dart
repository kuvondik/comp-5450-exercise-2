import 'package:flutter/material.dart';

class HudBar extends StatelessWidget {
  final int moves;
  final int matchedPairs;
  final int totalPairs;
  final String formattedTime;

  const HudBar({
    super.key,
    required this.moves,
    required this.matchedPairs,
    required this.totalPairs,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Moves',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '$moves',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                'Matched',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '$matchedPairs/$totalPairs',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                'Time',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
