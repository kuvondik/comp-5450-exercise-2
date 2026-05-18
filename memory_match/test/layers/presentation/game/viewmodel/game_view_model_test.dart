import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/domain/entity/game_session.dart';
import 'package:memory_match/layers/presentation/game/viewmodel/game_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGameSession());
  });

  late MockGenerateNewGame generateNewGame;
  late MockSaveCurrentGame saveCurrentGame;
  late MockGetBestTime getBestTime;
  late MockSaveBestTime saveBestTime;

  GameViewModel buildViewModel() {
    return GameViewModel(
      generateNewGame: generateNewGame,
      saveCurrentGame: saveCurrentGame,
      getBestTime: getBestTime,
      saveBestTime: saveBestTime,
    );
  }

  setUp(() {
    generateNewGame = MockGenerateNewGame();
    saveCurrentGame = MockSaveCurrentGame();
    getBestTime = MockGetBestTime();
    saveBestTime = MockSaveBestTime();

    when(() => generateNewGame(any())).thenReturn(Fixtures.buildGameSession());
    when(() => saveCurrentGame(any())).thenAnswer((_) async {});
    when(() => getBestTime()).thenAnswer((_) async => 0);
    when(() => saveBestTime(any())).thenAnswer((_) async {});
  });

  group('GameViewModel - initial / grid configuration', () {
    test('grid is 6x4 with 12 total pairs', () {
      final vm = buildViewModel();
      addTearDown(vm.dispose);

      expect(vm.gridRows, 6);
      expect(vm.gridCols, 4);
      expect(vm.totalPairs, 12);
    });

    test('is not initialized until initGame is called', () {
      final vm = buildViewModel();
      addTearDown(vm.dispose);

      expect(vm.isInitialized, isFalse);
    });
  });

  group('GameViewModel.initGame', () {
    test('with null session, generates a new game with grid-sized cards', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);

        vm.initGame(null);
        async.flushMicrotasks();

        expect(vm.isInitialized, isTrue);
        expect(vm.cards, hasLength(24));
        expect(vm.moves, 0);
        expect(vm.matchedPairs, 0);
        verify(() => generateNewGame(24)).called(1);
      });
    });

    test('with provided session, loads its cards and stats', () {
      fakeAsync((async) {
        final session = Fixtures.buildGameSession(
          moves: 5,
          matchedPairs: 2,
          elapsedSeconds: 30,
        );
        final vm = buildViewModel();
        addTearDown(vm.dispose);

        vm.initGame(session);
        async.flushMicrotasks();

        expect(vm.cards, session.cards);
        expect(vm.moves, 5);
        expect(vm.matchedPairs, 2);
        expect(vm.elapsedSeconds, 30);
        verifyNever(() => generateNewGame(any()));
      });
    });

    test('starts the timer after loading the game', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);

        vm.initGame(null);
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 3));
        expect(vm.elapsedSeconds, 3);
      });
    });
  });

  group('GameViewModel.flipCard - single card', () {
    test('marks card as flipped and notifies listeners', () {
      fakeAsync((async) {
        // Use deterministic ordered cards so we can predict pairings.
        when(() => generateNewGame(any()))
            .thenReturn(Fixtures.buildGameSession());
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        int notifyCount = 0;
        vm.addListener(() => notifyCount++);

        vm.flipCard(0);

        expect(vm.cards[0].isFlipped, isTrue);
        expect(notifyCount, greaterThanOrEqualTo(1));
        expect(vm.moves, 0); // moves only increment after the 2nd card
      });
    });

    test('ignores tap when card is already flipped', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        vm.flipCard(0);
        vm.flipCard(0); // duplicate tap

        expect(vm.moves, 0);
        expect(vm.cards[0].isFlipped, isTrue);
      });
    });

    test('ignores tap when card is already matched', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        vm.cards[0].isMatched = true;
        vm.flipCard(0);

        expect(vm.cards[0].isFlipped, isFalse);
      });
    });
  });

  group('GameViewModel.flipCard - matching pairs', () {
    test('two cards with the same value stay flipped and matched', () {
      fakeAsync((async) {
        // Ordered fixture: indices 0 and 1 both have value=0.
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        vm.flipCard(0);
        vm.flipCard(1);

        // Wait for the 400ms match-check delay.
        async.elapse(const Duration(milliseconds: 400));

        expect(vm.cards[0].isMatched, isTrue);
        expect(vm.cards[1].isMatched, isTrue);
        expect(vm.cards[0].isFlipped, isTrue);
        expect(vm.cards[1].isFlipped, isTrue);
        expect(vm.matchedPairs, 1);
        expect(vm.moves, 1);
      });
    });

    test('non-matching cards flip back after the match-check delay', () {
      fakeAsync((async) {
        // Ordered fixture: indices 0 (value 0) and 2 (value 1) do not match.
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        vm.flipCard(0);
        vm.flipCard(2);

        async.elapse(const Duration(milliseconds: 400));

        expect(vm.cards[0].isFlipped, isFalse);
        expect(vm.cards[2].isFlipped, isFalse);
        expect(vm.matchedPairs, 0);
        expect(vm.moves, 1);
      });
    });

    test('isProcessing flips during the match-check delay', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        vm.flipCard(0);
        vm.flipCard(1);

        expect(vm.isProcessing, isTrue);
        async.elapse(const Duration(milliseconds: 400));
        expect(vm.isProcessing, isFalse);
      });
    });
  });

  group('GameViewModel - win condition', () {
    test('sets isGameOver after all pairs are matched', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        // Flip every pair in the ordered fixture: (0,1), (2,3), ..., (22,23).
        for (int i = 0; i < 24; i += 2) {
          vm.flipCard(i);
          vm.flipCard(i + 1);
          async.elapse(const Duration(milliseconds: 400));
        }

        expect(vm.matchedPairs, 12);
        expect(vm.isGameOver, isTrue);
      });
    });

    test('writes a new best time when current record is 0', () {
      fakeAsync((async) {
        when(() => getBestTime()).thenAnswer((_) async => 0);
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        for (int i = 0; i < 24; i += 2) {
          vm.flipCard(i);
          vm.flipCard(i + 1);
          async.elapse(const Duration(milliseconds: 400));
        }
        async.flushMicrotasks();

        verify(() => saveBestTime(any())).called(1);
      });
    });

    test('does not overwrite a faster best time', () {
      fakeAsync((async) {
        when(() => getBestTime()).thenAnswer((_) async => 1);
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        for (int i = 0; i < 24; i += 2) {
          vm.flipCard(i);
          vm.flipCard(i + 1);
          async.elapse(const Duration(milliseconds: 400));
        }
        async.flushMicrotasks();

        verifyNever(() => saveBestTime(any()));
      });
    });

    test('stops the timer on win', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        for (int i = 0; i < 24; i += 2) {
          vm.flipCard(i);
          vm.flipCard(i + 1);
          async.elapse(const Duration(milliseconds: 400));
        }

        expect(vm.timerNotifier.isRunning, isFalse);
      });
    });
  });

  group('GameViewModel.pauseGame / resumeGame', () {
    test('pauseGame pauses the underlying timer', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 2));
        vm.pauseGame();
        async.elapse(const Duration(seconds: 3));

        expect(vm.timerNotifier.isRunning, isFalse);
        expect(vm.elapsedSeconds, 2);
      });
    });

    test('resumeGame restarts the timer from the same point', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 2));
        vm.pauseGame();
        async.elapse(const Duration(seconds: 5));
        vm.resumeGame();
        async.elapse(const Duration(seconds: 1));

        expect(vm.elapsedSeconds, 3);
      });
    });
  });

  group('GameViewModel.saveGame', () {
    test('forwards a session built from the current state', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 4));
        vm.flipCard(0);
        vm.flipCard(1);
        async.elapse(const Duration(milliseconds: 400));

        vm.saveGame();
        async.flushMicrotasks();

        final captured =
            verify(() => saveCurrentGame(captureAny())).captured.single
                as GameSession;
        expect(captured.moves, 1);
        expect(captured.matchedPairs, 1);
        expect(captured.elapsedSeconds, 4);
        expect(captured.cards, vm.cards);
      });
    });
  });

  group('GameViewModel.resetGame', () {
    test('generates a fresh game and resets the timer', () {
      fakeAsync((async) {
        final vm = buildViewModel();
        addTearDown(vm.dispose);
        vm.initGame(null);
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 5));
        vm.flipCard(0);
        vm.flipCard(1);
        async.elapse(const Duration(milliseconds: 400));
        expect(vm.matchedPairs, 1);
        expect(vm.moves, 1);

        // Provide a fresh ordered session for the reset call.
        when(() => generateNewGame(any()))
            .thenReturn(Fixtures.buildGameSession());

        vm.resetGame();
        async.flushMicrotasks();

        expect(vm.moves, 0);
        expect(vm.matchedPairs, 0);
        expect(vm.elapsedSeconds, 0);
        expect(vm.timerNotifier.isRunning, isTrue);
      });
    });
  });
}
