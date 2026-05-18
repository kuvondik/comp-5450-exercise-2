import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/constants/card_constants.dart';

void main() {
  group('CardConstants', () {
    test('exposes exactly 12 icons', () {
      expect(CardConstants.icons, hasLength(12));
    });

    test('all icons are unique', () {
      expect(CardConstants.icons.toSet(), hasLength(CardConstants.icons.length));
    });

    test('contains every expected Material icon', () {
      const expected = <IconData>[
        Icons.star,
        Icons.heart_broken,
        Icons.favorite,
        Icons.pets,
        Icons.beach_access,
        Icons.wb_sunny,
        Icons.cloud,
        Icons.water_drop,
        Icons.flight,
        Icons.train,
        Icons.directions_bike,
        Icons.local_pizza,
      ];
      for (final icon in expected) {
        expect(CardConstants.icons, contains(icon));
      }
    });

    group('getIconForValue', () {
      test('returns the icon at the given index for in-range values', () {
        for (int i = 0; i < CardConstants.icons.length; i++) {
          expect(
            CardConstants.getIconForValue(i),
            CardConstants.icons[i],
          );
        }
      });

      test('wraps using modulo for out-of-range values', () {
        expect(
          CardConstants.getIconForValue(12),
          CardConstants.getIconForValue(0),
        );
        expect(
          CardConstants.getIconForValue(25),
          CardConstants.getIconForValue(1),
        );
      });
    });

    test('has enough icons for a 6x4 grid', () {
      // 6x4 grid needs (6*4)/2 = 12 unique icons.
      expect(CardConstants.icons.length, greaterThanOrEqualTo(12));
    });
  });
}
