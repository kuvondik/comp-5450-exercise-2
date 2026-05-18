import '../entity/memory_card.dart';
import '../entity/game_session.dart';
import '../constants/card_constants.dart';

class GenerateNewGame {
  GameSession call(int totalCards) {
    final numPairs = totalCards ~/ 2;
    final values = List.generate(numPairs, (i) => i);
    final allCards = [...values, ...values];
    allCards.shuffle();

    final cards = allCards
        .map((value) => MemoryCard(
          value: value,
          icon: CardConstants.getIconForValue(value),
          isMatched: false,
          isFlipped: false,
        ))
        .toList();

    return GameSession(
      cards: cards,
      moves: 0,
      matchedPairs: 0,
      elapsedSeconds: 0,
    );
  }
}
