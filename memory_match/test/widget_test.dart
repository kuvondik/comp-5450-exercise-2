import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/usecase/generate_new_game.dart';
import 'package:memory_match/layers/domain/constants/card_constants.dart';

void main() {
  group('Memory Match Game Tests', () {
    group('Domain Layer - GenerateNewGame UseCase', () {
      test('generates game session with 24 cards', () {
        final useCase = GenerateNewGame();
        final gameSession = useCase(24);

        expect(gameSession.cards, hasLength(24));
        expect(gameSession.moves, equals(0));
        expect(gameSession.matchedPairs, equals(0));
        expect(gameSession.elapsedSeconds, equals(0));
      });

      test('creates matching pairs of cards', () {
        final useCase = GenerateNewGame();
        final gameSession = useCase(24);

        // Count pairs: each value should appear exactly twice
        final valueCounts = <int, int>{};
        for (final card in gameSession.cards) {
          valueCounts[card.value] = (valueCounts[card.value] ?? 0) + 1;
        }

        // Each value should appear exactly twice
        for (final count in valueCounts.values) {
          expect(count, equals(2));
        }
      });

      test('assigns icons from CardConstants', () {
        final useCase = GenerateNewGame();
        final gameSession = useCase(24);

        for (final card in gameSession.cards) {
          expect(
            CardConstants.icons.contains(card.icon),
            isTrue,
            reason:
                'Card icon should be from CardConstants.icons list',
          );
        }
      });

      test('all cards start unflipped and unmatched', () {
        final useCase = GenerateNewGame();
        final gameSession = useCase(24);

        for (final card in gameSession.cards) {
          expect(card.isFlipped, isFalse);
          expect(card.isMatched, isFalse);
        }
      });

      test('cards are properly shuffled', () {
        final useCase = GenerateNewGame();

        // Generate multiple games and check they're not identical
        final game1 = useCase(24);
        final game2 = useCase(24);

        // Extract card sequences (values and order)
        final sequence1 = game1.cards.map((c) => c.value).toList();
        final sequence2 = game2.cards.map((c) => c.value).toList();

        // Very unlikely that two shuffled sequences are identical
        // (though not mathematically impossible, probability is extremely low)
        expect(sequence1, isNotEmpty);
        expect(sequence2, isNotEmpty);
        // If they're different in any position, shuffle is working
        expect(sequence1 != sequence2, isTrue);
      });

      test('generates correct number of pairs for grid size', () {
        final useCase = GenerateNewGame();
        final gameSession = useCase(24);

        // For 24 cards, we should have 12 unique values
        final uniqueValues = gameSession.cards.map((c) => c.value).toSet();
        expect(uniqueValues, hasLength(12));
      });
    });

    group('Domain Layer - CardConstants', () {
      test('has exactly 12 unique icons', () {
        expect(CardConstants.icons, hasLength(12));
      });

      test('contains expected Material Design icons', () {
        expect(CardConstants.icons, contains(Icons.star));
        expect(CardConstants.icons, contains(Icons.favorite));
        expect(CardConstants.icons, contains(Icons.pets));
        expect(CardConstants.icons, contains(Icons.beach_access));
        expect(CardConstants.icons, contains(Icons.wb_sunny));
        expect(CardConstants.icons, contains(Icons.cloud));
        expect(CardConstants.icons, contains(Icons.water_drop));
        expect(CardConstants.icons, contains(Icons.flight));
        expect(CardConstants.icons, contains(Icons.train));
        expect(CardConstants.icons, contains(Icons.directions_bike));
        expect(CardConstants.icons, contains(Icons.local_pizza));
      });

      test('getIconForValue returns valid icons for all values', () {
        // Test values 0-23 (covering 12 pairs)
        for (int i = 0; i < 24; i++) {
          final icon = CardConstants.getIconForValue(i);
          expect(
            CardConstants.icons.contains(icon),
            isTrue,
            reason: 'Icon for value $i should be in the constants list',
          );
        }
      });

      test('getIconForValue uses modulo arithmetic for wrapping', () {
        // Value 0 should map to icons[0]
        // Value 12 should also map to icons[0] (12 % 12 = 0)
        final icon0 = CardConstants.getIconForValue(0);
        final icon12 = CardConstants.getIconForValue(12);
        expect(icon0, equals(icon12));

        // Value 1 and 13 should map to same icon
        final icon1 = CardConstants.getIconForValue(1);
        final icon13 = CardConstants.getIconForValue(13);
        expect(icon1, equals(icon13));
      });

      test('all icons in list are unique', () {
        final iconSet = <IconData>{};
        for (final icon in CardConstants.icons) {
          expect(
            iconSet.add(icon),
            isTrue,
            reason: 'Icon $icon should only appear once in the list',
          );
        }
      });
    });

    group('Game Logic Tests', () {
      test('generated game has correct grid dimensions', () {
        final useCase = GenerateNewGame();
        final gameSession = useCase(24);

        // 6x4 grid = 24 cards
        expect(gameSession.cards.length, equals(24));
      });

      test('game session initialized with zero stats', () {
        final useCase = GenerateNewGame();
        final gameSession = useCase(24);

        expect(gameSession.moves, equals(0));
        expect(gameSession.matchedPairs, equals(0));
        expect(gameSession.elapsedSeconds, equals(0));
      });

      test('all cards have valid properties', () {
        final useCase = GenerateNewGame();
        final gameSession = useCase(24);

        for (int i = 0; i < gameSession.cards.length; i++) {
          final card = gameSession.cards[i];

          // Value should be 0-11 (12 pairs)
          expect(card.value, greaterThanOrEqualTo(0));
          expect(card.value, lessThan(12));

          // Icon should be valid
          expect(card.icon, isNotNull);

          // State should be unflipped and unmatched
          expect(card.isFlipped, isFalse);
          expect(card.isMatched, isFalse);
        }
      });

      test('verify exact pair distribution', () {
        final useCase = GenerateNewGame();
        final gameSession = useCase(24);

        // Count occurrences of each value
        final valueCounts = <int, int>{};
        for (final card in gameSession.cards) {
          valueCounts[card.value] = (valueCounts[card.value] ?? 0) + 1;
        }

        // Should have exactly 12 values
        expect(valueCounts.length, equals(12));

        // Each value should appear exactly twice
        valueCounts.forEach((value, count) {
          expect(
            count,
            equals(2),
            reason: 'Value $value should appear exactly 2 times, but appears $count times',
          );
        });
      });
    });

    group('CardConstants Consistency Tests', () {
      test('CardConstants icons list matches expected count for 6x4 grid', () {
        // 6x4 grid = 24 cards = 12 pairs
        // CardConstants should have at least 12 icons
        expect(CardConstants.icons.length, greaterThanOrEqualTo(12));
      });

      test('CardConstants provides sufficient icons for game', () {
        final useCase = GenerateNewGame();
        final gameSession = useCase(24);

        // All cards should be able to get valid icons
        for (final card in gameSession.cards) {
          final icon = CardConstants.getIconForValue(card.value);
          expect(icon, isNotNull);
          expect(CardConstants.icons.contains(icon), isTrue);
        }
      });

      test('CardConstants is single source of truth for icons', () {
        // Verify the list hasn't been accidentally modified
        final originalLength = CardConstants.icons.length;
        expect(originalLength, equals(12));

        // Verify specific icons are present
        expect(CardConstants.icons.isNotEmpty, isTrue);
        expect(CardConstants.icons.first, isNotNull);
      });
    });
  });
}
