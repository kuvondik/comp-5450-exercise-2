import 'package:flutter/material.dart';
import 'package:memory_match/layers/domain/constants/card_constants.dart';
import 'package:memory_match/layers/domain/entity/game_session.dart';
import 'package:memory_match/layers/domain/entity/memory_card.dart';

/// Common test fixtures used across the test suite.
class Fixtures {
  /// Builds a single test card with the given value, defaulting to unflipped
  /// and unmatched.
  static MemoryCard buildCard({
    required int value,
    IconData? icon,
    bool isFlipped = false,
    bool isMatched = false,
  }) {
    return MemoryCard(
      value: value,
      icon: icon ?? CardConstants.getIconForValue(value),
      isFlipped: isFlipped,
      isMatched: isMatched,
    );
  }

  /// Builds a deterministic list of 24 cards in pair order
  /// (0,0,1,1,...,11,11) so tests can predict matches and indices.
  static List<MemoryCard> buildOrderedCards({int totalCards = 24}) {
    final cards = <MemoryCard>[];
    for (int i = 0; i < totalCards; i++) {
      cards.add(buildCard(value: i ~/ 2));
    }
    return cards;
  }

  /// Builds a fresh game session with the given cards (or default 24 cards).
  static GameSession buildGameSession({
    List<MemoryCard>? cards,
    int moves = 0,
    int matchedPairs = 0,
    int elapsedSeconds = 0,
  }) {
    return GameSession(
      cards: cards ?? buildOrderedCards(),
      moves: moves,
      matchedPairs: matchedPairs,
      elapsedSeconds: elapsedSeconds,
    );
  }

  /// Sample serialized game string matching GameSessionDto format:
  ///   "matchedPairs|moves|elapsedSeconds|value,isMatched,isFlipped,..."
  static const String validRawGameString =
      '2|5|45|0,true,true,0,true,true,1,false,false,1,false,false,'
      '2,false,false,2,false,false,3,false,false,3,false,false,'
      '4,false,false,4,false,false,5,false,false,5,false,false,'
      '6,false,false,6,false,false,7,false,false,7,false,false,'
      '8,false,false,8,false,false,9,false,false,9,false,false,'
      '10,false,false,10,false,false,11,false,false,11,false,false';

  /// Invalid raw strings used to verify DTO error handling.
  static const String invalidRawGameMissingParts = '2|5';
  static const String invalidRawGameNonNumeric = 'abc|5|45|0,true,true';
}
