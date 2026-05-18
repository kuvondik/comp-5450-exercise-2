import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/data/dto/game_session_dto.dart';
import 'package:memory_match/layers/data/game_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockLocalStorage storage;
  late GameRepositoryImpl repository;

  setUp(() {
    storage = MockLocalStorage();
    repository = GameRepositoryImpl(localStorage: storage);
  });

  group('GameRepositoryImpl - simple delegations', () {
    test('getHighScore forwards to LocalStorage.loadHighScore', () async {
      when(() => storage.loadHighScore()).thenAnswer((_) async => 50);
      expect(await repository.getHighScore(), 50);
      verify(() => storage.loadHighScore()).called(1);
    });

    test('saveHighScore forwards to LocalStorage.saveHighScore', () async {
      when(() => storage.saveHighScore(any())).thenAnswer((_) async {});
      await repository.saveHighScore(123);
      verify(() => storage.saveHighScore(123)).called(1);
    });

    test('getBestTime forwards to LocalStorage.loadBestTime', () async {
      when(() => storage.loadBestTime()).thenAnswer((_) async => 60);
      expect(await repository.getBestTime(), 60);
      verify(() => storage.loadBestTime()).called(1);
    });

    test('saveBestTime forwards to LocalStorage.saveBestTime', () async {
      when(() => storage.saveBestTime(any())).thenAnswer((_) async {});
      await repository.saveBestTime(45);
      verify(() => storage.saveBestTime(45)).called(1);
    });

    test('deleteBestTime forwards to LocalStorage.deleteBestTime', () async {
      when(() => storage.deleteBestTime()).thenAnswer((_) async {});
      await repository.deleteBestTime();
      verify(() => storage.deleteBestTime()).called(1);
    });

    test('hasSavedGame forwards to LocalStorage.hasSavedGame', () async {
      when(() => storage.hasSavedGame()).thenAnswer((_) async => true);
      expect(await repository.hasSavedGame(), isTrue);
      verify(() => storage.hasSavedGame()).called(1);
    });

    test('deleteHighScore forwards to LocalStorage.deleteHighScore', () async {
      when(() => storage.deleteHighScore()).thenAnswer((_) async {});
      await repository.deleteHighScore();
      verify(() => storage.deleteHighScore()).called(1);
    });

    test('deleteSavedGame forwards to LocalStorage.deleteSavedGame', () async {
      when(() => storage.deleteSavedGame()).thenAnswer((_) async {});
      await repository.deleteSavedGame();
      verify(() => storage.deleteSavedGame()).called(1);
    });
  });

  group('GameRepositoryImpl - loadSavedGame', () {
    test('returns null when LocalStorage has no raw game', () async {
      when(() => storage.loadRawGame()).thenAnswer((_) async => null);

      expect(await repository.loadSavedGame(), isNull);
    });

    test('returns parsed entity when raw string is valid', () async {
      when(() => storage.loadRawGame())
          .thenAnswer((_) async => Fixtures.validRawGameString);

      final session = await repository.loadSavedGame();

      expect(session, isNotNull);
      expect(session!.matchedPairs, 2);
      expect(session.moves, 5);
      expect(session.elapsedSeconds, 45);
      expect(session.cards, hasLength(24));
    });

    test('returns null when raw string is malformed', () async {
      when(() => storage.loadRawGame())
          .thenAnswer((_) async => Fixtures.invalidRawGameMissingParts);

      expect(await repository.loadSavedGame(), isNull);
    });
  });

  group('GameRepositoryImpl - saveCurrentGame', () {
    test('serializes the session via DTO and forwards to LocalStorage',
        () async {
      when(() => storage.saveRawGame(any())).thenAnswer((_) async {});
      final session = Fixtures.buildGameSession(
        moves: 4,
        matchedPairs: 1,
        elapsedSeconds: 20,
      );
      final expectedRaw = GameSessionDto.fromEntity(session).toRawString();

      await repository.saveCurrentGame(session);

      verify(() => storage.saveRawGame(expectedRaw)).called(1);
    });
  });
}
