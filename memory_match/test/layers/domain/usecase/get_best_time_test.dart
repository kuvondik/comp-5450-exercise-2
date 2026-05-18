import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/usecase/get_best_time.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  group('GetBestTime', () {
    late MockGameRepository repository;
    late GetBestTime useCase;

    setUp(() {
      repository = MockGameRepository();
      useCase = GetBestTime(repository: repository);
    });

    test('delegates to repository.getBestTime', () async {
      when(() => repository.getBestTime()).thenAnswer((_) async => 42);

      final result = await useCase();

      expect(result, 42);
      verify(() => repository.getBestTime()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('returns 0 when no record exists', () async {
      when(() => repository.getBestTime()).thenAnswer((_) async => 0);

      expect(await useCase(), 0);
    });
  });
}
