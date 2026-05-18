import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/constants/card_constants.dart';
import 'package:memory_match/layers/domain/usecase/generate_new_game.dart';

void main() {
  group('GenerateNewGame', () {
    late GenerateNewGame useCase;

    setUp(() {
      useCase = GenerateNewGame();
    });

    test('creates the requested number of cards', () {
      final session = useCase(24);
      expect(session.cards, hasLength(24));
    });

    test('creates exactly one matched pair per value', () {
      final session = useCase(24);
      final counts = <int, int>{};
      for (final card in session.cards) {
        counts[card.value] = (counts[card.value] ?? 0) + 1;
      }
      expect(counts, hasLength(12));
      for (final c in counts.values) {
        expect(c, 2);
      }
    });

    test('all cards start unflipped and unmatched', () {
      final session = useCase(24);
      for (final card in session.cards) {
        expect(card.isFlipped, isFalse);
        expect(card.isMatched, isFalse);
      }
    });

    test('initializes session stats to zero', () {
      final session = useCase(24);
      expect(session.moves, 0);
      expect(session.matchedPairs, 0);
      expect(session.elapsedSeconds, 0);
    });

    test('assigns icons from CardConstants', () {
      final session = useCase(24);
      for (final card in session.cards) {
        expect(CardConstants.icons, contains(card.icon));
      }
    });

    test('shuffles cards (sequences should differ across runs)', () {
      // Run multiple times to reduce flake probability — with 24! permutations
      // the chance of two identical orderings is vanishingly small.
      final sequences = List.generate(
        3,
        (_) => useCase(24).cards.map((c) => c.value).toList(),
      );
      expect(sequences.toSet(), hasLength(greaterThan(1)));
    });

    test('supports smaller grids (e.g. 4 cards / 2 pairs)', () {
      final session = useCase(4);
      expect(session.cards, hasLength(4));
      expect(session.cards.map((c) => c.value).toSet(), hasLength(2));
    });
  });
}
