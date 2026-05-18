import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/usecase/save_best_time.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  group('SaveBestTime', () {
    late MockGameRepository repository;
    late SaveBestTime useCase;

    setUp(() {
      repository = MockGameRepository();
      useCase = SaveBestTime(repository: repository);
    });

    test('forwards seconds to repository.saveBestTime', () async {
      when(() => repository.saveBestTime(any())).thenAnswer((_) async {});

      await useCase(90);

      verify(() => repository.saveBestTime(90)).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
