import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/entity/memory_card.dart';

void main() {
  group('MemoryCard', () {
    test('stores its required properties', () {
      final card = MemoryCard(
        value: 3,
        icon: Icons.star,
        isMatched: false,
        isFlipped: false,
      );

      expect(card.value, 3);
      expect(card.icon, Icons.star);
      expect(card.isMatched, isFalse);
      expect(card.isFlipped, isFalse);
    });

    test('accepts a null icon', () {
      final card = MemoryCard(
        value: 0,
        isMatched: false,
        isFlipped: false,
      );

      expect(card.icon, isNull);
    });

    test('isFlipped is mutable', () {
      final card = MemoryCard(
        value: 0,
        isMatched: false,
        isFlipped: false,
      );

      card.isFlipped = true;
      expect(card.isFlipped, isTrue);
    });

    test('isMatched is mutable', () {
      final card = MemoryCard(
        value: 0,
        isMatched: false,
        isFlipped: false,
      );

      card.isMatched = true;
      expect(card.isMatched, isTrue);
    });
  });
}
