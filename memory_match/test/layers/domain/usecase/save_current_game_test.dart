import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/entity/game_session.dart';
import 'package:memory_match/layers/domain/usecase/save_current_game.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGameSession());
  });

  group('SaveCurrentGame', () {
    late MockGameRepository repository;
    late SaveCurrentGame useCase;

    setUp(() {
      repository = MockGameRepository();
      useCase = SaveCurrentGame(repository: repository);
    });

    test('forwards session to repository.saveCurrentGame', () async {
      when(() => repository.saveCurrentGame(any<GameSession>()))
          .thenAnswer((_) async {});
      final session = Fixtures.buildGameSession(moves: 3, elapsedSeconds: 10);

      await useCase(session);

      verify(() => repository.saveCurrentGame(session)).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
