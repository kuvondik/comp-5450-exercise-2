import 'memory_card.dart';

class GameSession {
  final List<MemoryCard> cards;
  final int moves;
  final int matchedPairs;
  final int elapsedSeconds;

  GameSession({
    required this.cards,
    required this.moves,
    required this.matchedPairs,
    required this.elapsedSeconds,
  });
}
