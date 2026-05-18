import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/usecase/clear_best_time.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  group('ClearBestTime', () {
    late MockGameRepository repository;
    late ClearBestTime useCase;

    setUp(() {
      repository = MockGameRepository();
      useCase = ClearBestTime(repository: repository);
    });

    test('delegates to repository.deleteBestTime', () async {
      when(() => repository.deleteBestTime()).thenAnswer((_) async {});

      await useCase();

      verify(() => repository.deleteBestTime()).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
