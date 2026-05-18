import 'package:memory_match/layers/domain/entity/game_session.dart';
import 'package:memory_match/layers/domain/entity/memory_card.dart';
import 'package:memory_match/layers/domain/constants/card_constants.dart';

class GameSessionDto extends GameSession {
  GameSessionDto({
    required super.cards,
    required super.moves,
    required super.matchedPairs,
    required super.elapsedSeconds,
  });

  factory GameSessionDto.fromRawString(String raw) {
    try {
      final parts = raw.split('|');
      if (parts.length < 4) {
        throw FormatException('Invalid game data format');
      }

      final matchedPairs = int.parse(parts[0]);
      final moves = int.parse(parts[1]);
      final elapsedSeconds = int.parse(parts[2]);
      final cardStates = parts[3].split(',');

      final cards = <MemoryCard>[];
      for (int i = 0; i < cardStates.length; i += 3) {
        if (i + 2 < cardStates.length) {
          final value = int.parse(cardStates[i]);
          cards.add(
            MemoryCard(
              value: value,
              icon: CardConstants.getIconForValue(value),
              isMatched: cardStates[i + 1] == 'true',
              isFlipped: cardStates[i + 2] == 'true',
            ),
          );
        }
      }

      return GameSessionDto(
        cards: cards,
        moves: moves,
        matchedPairs: matchedPairs,
        elapsedSeconds: elapsedSeconds,
      );
    } catch (e) {
      rethrow;
    }
  }

  String toRawString() {
    final cardStates = cards
        .map((c) => '${c.value},${c.isMatched},${c.isFlipped}')
        .join(',');
    return '$matchedPairs|$moves|$elapsedSeconds|$cardStates';
  }

  GameSession toEntity() {
    return GameSession(
      cards: cards,
      moves: moves,
      matchedPairs: matchedPairs,
      elapsedSeconds: elapsedSeconds,
    );
  }

  static GameSessionDto fromEntity(GameSession session) {
    return GameSessionDto(
      cards: session.cards,
      moves: session.moves,
      matchedPairs: session.matchedPairs,
      elapsedSeconds: session.elapsedSeconds,
    );
  }
}
