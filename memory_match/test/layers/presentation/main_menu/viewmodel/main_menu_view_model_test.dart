import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/presentation/main_menu/viewmodel/main_menu_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockHasSavedGame hasSavedGame;
  late MockGetBestTime getBestTime;
  late MockDeleteSavedGame deleteSavedGame;
  late MockClearBestTime clearBestTime;
  late MainMenuViewModel viewModel;

  setUp(() {
    hasSavedGame = MockHasSavedGame();
    getBestTime = MockGetBestTime();
    deleteSavedGame = MockDeleteSavedGame();
    clearBestTime = MockClearBestTime();
    viewModel = MainMenuViewModel(
      hasSavedGame: hasSavedGame,
      deleteSavedGame: deleteSavedGame,
      getBestTime: getBestTime,
      clearBestTime: clearBestTime,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('MainMenuViewModel - initial state', () {
    test('starts loading, with no saved game and zero best time', () {
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.hasSavedGame, isFalse);
      expect(viewModel.bestTime, 0);
    });
  });

  group('MainMenuViewModel - formattedBestTime', () {
    test('renders seconds when under one minute', () async {
      when(() => hasSavedGame()).thenAnswer((_) async => false);
      when(() => getBestTime()).thenAnswer((_) async => 45);

      await viewModel.loadData();

      expect(viewModel.formattedBestTime, '45s');
    });

    test('renders minutes:seconds when under one hour', () async {
      when(() => hasSavedGame()).thenAnswer((_) async => false);
      when(() => getBestTime()).thenAnswer((_) async => 150);

      await viewModel.loadData();

      expect(viewModel.formattedBestTime, '02m:30s');
    });

    test('renders hours:minutes:seconds when at least one hour', () async {
      when(() => hasSavedGame()).thenAnswer((_) async => false);
      when(() => getBestTime()).thenAnswer((_) async => 3725);

      await viewModel.loadData();

      expect(viewModel.formattedBestTime, '01h:02m:05s');
    });
  });

  group('MainMenuViewModel.loadData', () {
    test('populates hasSavedGame and bestTime, then clears loading', () async {
      when(() => hasSavedGame()).thenAnswer((_) async => true);
      when(() => getBestTime()).thenAnswer((_) async => 90);

      await viewModel.loadData();

      expect(viewModel.hasSavedGame, isTrue);
      expect(viewModel.bestTime, 90);
      expect(viewModel.isLoading, isFalse);
    });

    test('notifies listeners at least twice (loading on, then off)', () async {
      when(() => hasSavedGame()).thenAnswer((_) async => true);
      when(() => getBestTime()).thenAnswer((_) async => 12);

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.loadData();

      expect(notifyCount, greaterThanOrEqualTo(2));
    });

    test('stops loading even when a use case throws', () async {
      when(() => hasSavedGame()).thenThrow(Exception('boom'));
      when(() => getBestTime()).thenAnswer((_) async => 0);

      await viewModel.loadData();

      expect(viewModel.isLoading, isFalse);
    });
  });

  group('MainMenuViewModel.clearSavedGame', () {
    test('flips hasSavedGame to false and notifies', () async {
      when(() => hasSavedGame()).thenAnswer((_) async => true);
      when(() => getBestTime()).thenAnswer((_) async => 0);
      when(() => deleteSavedGame()).thenAnswer((_) async {});
      await viewModel.loadData();
      expect(viewModel.hasSavedGame, isTrue);

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.clearSavedGame();

      expect(viewModel.hasSavedGame, isFalse);
      expect(notifyCount, 1);
      verify(() => deleteSavedGame()).called(1);
    });

    test('swallows errors and leaves state unchanged on failure', () async {
      when(() => hasSavedGame()).thenAnswer((_) async => true);
      when(() => getBestTime()).thenAnswer((_) async => 0);
      when(() => deleteSavedGame()).thenThrow(Exception('boom'));
      await viewModel.loadData();

      await viewModel.clearSavedGame();

      expect(viewModel.hasSavedGame, isTrue);
    });
  });

  group('MainMenuViewModel.clearBestTime', () {
    test('resets bestTime to 0 and notifies', () async {
      when(() => hasSavedGame()).thenAnswer((_) async => false);
      when(() => getBestTime()).thenAnswer((_) async => 50);
      when(() => clearBestTime()).thenAnswer((_) async {});
      await viewModel.loadData();
      expect(viewModel.bestTime, 50);

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.clearBestTime();

      expect(viewModel.bestTime, 0);
      expect(notifyCount, 1);
      verify(() => clearBestTime()).called(1);
    });

    test('swallows errors and leaves bestTime unchanged on failure', () async {
      when(() => hasSavedGame()).thenAnswer((_) async => false);
      when(() => getBestTime()).thenAnswer((_) async => 99);
      when(() => clearBestTime()).thenThrow(Exception('boom'));
      await viewModel.loadData();

      await viewModel.clearBestTime();

      expect(viewModel.bestTime, 99);
    });
  });
}
