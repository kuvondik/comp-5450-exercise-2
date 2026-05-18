import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/data/dto/game_session_dto.dart';
import 'package:memory_match/layers/domain/constants/card_constants.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('GameSessionDto.fromRawString', () {
    test('parses a valid raw string into a GameSessionDto', () {
      final dto = GameSessionDto.fromRawString(Fixtures.validRawGameString);

      expect(dto.matchedPairs, 2);
      expect(dto.moves, 5);
      expect(dto.elapsedSeconds, 45);
      expect(dto.cards, hasLength(24));
    });

    test('reconstructs card values, isMatched, isFlipped from the string', () {
      final dto = GameSessionDto.fromRawString(Fixtures.validRawGameString);

      // First two cards in fixture are value=0, isMatched=true, isFlipped=true.
      expect(dto.cards[0].value, 0);
      expect(dto.cards[0].isMatched, isTrue);
      expect(dto.cards[0].isFlipped, isTrue);

      // Third card is value=1, isMatched=false, isFlipped=false.
      expect(dto.cards[2].value, 1);
      expect(dto.cards[2].isMatched, isFalse);
      expect(dto.cards[2].isFlipped, isFalse);
    });

    test('icons are looked up from CardConstants by value', () {
      final dto = GameSessionDto.fromRawString(Fixtures.validRawGameString);

      for (final card in dto.cards) {
        expect(card.icon, CardConstants.getIconForValue(card.value));
      }
    });

    test('throws FormatException when fewer than 4 parts are present', () {
      expect(
        () => GameSessionDto.fromRawString(Fixtures.invalidRawGameMissingParts),
        throwsA(isA<FormatException>()),
      );
    });

    test('rethrows when numeric fields are not parseable', () {
      expect(
        () => GameSessionDto.fromRawString(Fixtures.invalidRawGameNonNumeric),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('GameSessionDto.toRawString', () {
    test('serializes a session into the expected pipe-delimited format', () {
      final cards = [
        Fixtures.buildCard(value: 0, isMatched: true, isFlipped: true),
        Fixtures.buildCard(value: 0, isMatched: true, isFlipped: true),
        Fixtures.buildCard(value: 1, isMatched: false, isFlipped: false),
      ];
      final dto = GameSessionDto(
        cards: cards,
        moves: 5,
        matchedPairs: 1,
        elapsedSeconds: 30,
      );

      expect(
        dto.toRawString(),
        '1|5|30|0,true,true,0,true,true,1,false,false',
      );
    });

    test('round-trips: toRawString → fromRawString reproduces fields', () {
      final original = GameSessionDto.fromEntity(
        Fixtures.buildGameSession(
          moves: 7,
          matchedPairs: 1,
          elapsedSeconds: 12,
        ),
      );

      final reparsed = GameSessionDto.fromRawString(original.toRawString());

      expect(reparsed.matchedPairs, original.matchedPairs);
      expect(reparsed.moves, original.moves);
      expect(reparsed.elapsedSeconds, original.elapsedSeconds);
      expect(reparsed.cards, hasLength(original.cards.length));
      for (int i = 0; i < original.cards.length; i++) {
        expect(reparsed.cards[i].value, original.cards[i].value);
        expect(reparsed.cards[i].isMatched, original.cards[i].isMatched);
        expect(reparsed.cards[i].isFlipped, original.cards[i].isFlipped);
      }
    });
  });

  group('GameSessionDto conversions', () {
    test('fromEntity copies all fields', () {
      final session = Fixtures.buildGameSession(
        moves: 3,
        matchedPairs: 1,
        elapsedSeconds: 20,
      );

      final dto = GameSessionDto.fromEntity(session);

      expect(dto.cards, session.cards);
      expect(dto.moves, session.moves);
      expect(dto.matchedPairs, session.matchedPairs);
      expect(dto.elapsedSeconds, session.elapsedSeconds);
    });

    test('toEntity returns equivalent GameSession', () {
      final dto = GameSessionDto(
        cards: Fixtures.buildOrderedCards(totalCards: 4),
        moves: 2,
        matchedPairs: 1,
        elapsedSeconds: 5,
      );

      final entity = dto.toEntity();

      expect(entity.cards, dto.cards);
      expect(entity.moves, dto.moves);
      expect(entity.matchedPairs, dto.matchedPairs);
      expect(entity.elapsedSeconds, dto.elapsedSeconds);
    });
  });
}
