import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/usecase/has_saved_game.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  group('HasSavedGame', () {
    late MockGameRepository repository;
    late HasSavedGame useCase;

    setUp(() {
      repository = MockGameRepository();
      useCase = HasSavedGame(repository: repository);
    });

    test('returns true when repository reports a saved game', () async {
      when(() => repository.hasSavedGame()).thenAnswer((_) async => true);

      expect(await useCase(), isTrue);
      verify(() => repository.hasSavedGame()).called(1);
    });

    test('returns false when no saved game exists', () async {
      when(() => repository.hasSavedGame()).thenAnswer((_) async => false);

      expect(await useCase(), isFalse);
    });
  });
}
