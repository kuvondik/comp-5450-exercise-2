import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/usecase/delete_saved_game.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  group('DeleteSavedGame', () {
    late MockGameRepository repository;
    late DeleteSavedGame useCase;

    setUp(() {
      repository = MockGameRepository();
      useCase = DeleteSavedGame(repository: repository);
    });

    test('delegates to repository.deleteSavedGame', () async {
      when(() => repository.deleteSavedGame()).thenAnswer((_) async {});

      await useCase();

      verify(() => repository.deleteSavedGame()).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
