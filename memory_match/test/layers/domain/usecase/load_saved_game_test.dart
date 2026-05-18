import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/usecase/load_saved_game.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  group('LoadSavedGame', () {
    late MockGameRepository repository;
    late LoadSavedGame useCase;

    setUp(() {
      repository = MockGameRepository();
      useCase = LoadSavedGame(repository: repository);
    });

    test('returns session from repository when one exists', () async {
      final session = Fixtures.buildGameSession(moves: 4);
      when(() => repository.loadSavedGame()).thenAnswer((_) async => session);

      final result = await useCase();

      expect(result, session);
      verify(() => repository.loadSavedGame()).called(1);
    });

    test('returns null when repository has no saved game', () async {
      when(() => repository.loadSavedGame()).thenAnswer((_) async => null);

      expect(await useCase(), isNull);
    });
  });
}
