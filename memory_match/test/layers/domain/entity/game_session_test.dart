import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/entity/game_session.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('GameSession', () {
    test('stores all required properties', () {
      final cards = Fixtures.buildOrderedCards();
      final session = GameSession(
        cards: cards,
        moves: 7,
        matchedPairs: 3,
        elapsedSeconds: 120,
      );

      expect(session.cards, cards);
      expect(session.moves, 7);
      expect(session.matchedPairs, 3);
      expect(session.elapsedSeconds, 120);
    });

    test('accepts an empty card list', () {
      final session = GameSession(
        cards: const [],
        moves: 0,
        matchedPairs: 0,
        elapsedSeconds: 0,
      );

      expect(session.cards, isEmpty);
    });
  });
}
