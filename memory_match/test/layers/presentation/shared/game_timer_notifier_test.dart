import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/presentation/shared/game_timer_notifier.dart';

void main() {
  group('GameTimerNotifier - initial state', () {
    test('starts at 0 seconds, not running', () {
      final timer = GameTimerNotifier();
      addTearDown(timer.dispose);

      expect(timer.elapsedSeconds, 0);
      expect(timer.isRunning, isFalse);
    });

    test('formattedTime initial value is "00s"', () {
      final timer = GameTimerNotifier();
      addTearDown(timer.dispose);

      expect(timer.formattedTime, '00s');
    });
  });

  group('GameTimerNotifier - formattedTime', () {
    test('formats seconds-only (<1m) as "ssS"', () {
      final timer = GameTimerNotifier();
      addTearDown(timer.dispose);

      timer.setElapsedSeconds(45);
      expect(timer.formattedTime, '45s');
    });

    test('formats minutes (<1h) as "mm:ssM:S"', () {
      final timer = GameTimerNotifier();
      addTearDown(timer.dispose);

      timer.setElapsedSeconds(90); // 1 minute 30 seconds
      expect(timer.formattedTime, '01m:30s');
    });

    test('formats hours as "hh:mm:ssH:M:S"', () {
      final timer = GameTimerNotifier();
      addTearDown(timer.dispose);

      timer.setElapsedSeconds(3725); // 1h 2m 5s
      expect(timer.formattedTime, '01h:02m:05s');
    });
  });

  group('GameTimerNotifier - start / pause / resume', () {
    test('start ticks elapsedSeconds once per second', () {
      fakeAsync((async) {
        final timer = GameTimerNotifier();
        addTearDown(timer.dispose);

        timer.start();
        expect(timer.isRunning, isTrue);

        async.elapse(const Duration(seconds: 3));
        expect(timer.elapsedSeconds, 3);
      });
    });

    test('calling start twice does not double-tick', () {
      fakeAsync((async) {
        final timer = GameTimerNotifier();
        addTearDown(timer.dispose);

        timer.start();
        timer.start();
        async.elapse(const Duration(seconds: 5));

        expect(timer.elapsedSeconds, 5);
      });
    });

    test('pause stops ticks; resume continues from same point', () {
      fakeAsync((async) {
        final timer = GameTimerNotifier();
        addTearDown(timer.dispose);

        timer.start();
        async.elapse(const Duration(seconds: 2));
        timer.pause();
        expect(timer.isRunning, isFalse);

        async.elapse(const Duration(seconds: 3));
        expect(timer.elapsedSeconds, 2); // unchanged while paused

        timer.resume();
        expect(timer.isRunning, isTrue);
        async.elapse(const Duration(seconds: 2));
        expect(timer.elapsedSeconds, 4);
      });
    });

    test('pause is a no-op when not running', () {
      final timer = GameTimerNotifier();
      addTearDown(timer.dispose);

      timer.pause();
      expect(timer.isRunning, isFalse);
    });

    test('resume is a no-op when already running', () {
      fakeAsync((async) {
        final timer = GameTimerNotifier();
        addTearDown(timer.dispose);

        timer.start();
        timer.resume();
        async.elapse(const Duration(seconds: 2));
        expect(timer.elapsedSeconds, 2);
      });
    });
  });

  group('GameTimerNotifier - reset / stop', () {
    test('reset clears elapsedSeconds and stops the timer', () {
      fakeAsync((async) {
        final timer = GameTimerNotifier();
        addTearDown(timer.dispose);

        timer.start();
        async.elapse(const Duration(seconds: 5));
        timer.reset();

        expect(timer.elapsedSeconds, 0);
        expect(timer.isRunning, isFalse);

        async.elapse(const Duration(seconds: 3));
        expect(timer.elapsedSeconds, 0); // still 0 after reset
      });
    });

    test('stop halts ticks without resetting elapsedSeconds', () {
      fakeAsync((async) {
        final timer = GameTimerNotifier();
        addTearDown(timer.dispose);

        timer.start();
        async.elapse(const Duration(seconds: 4));
        timer.stop();

        expect(timer.isRunning, isFalse);
        expect(timer.elapsedSeconds, 4);
      });
    });
  });

  group('GameTimerNotifier - setElapsedSeconds', () {
    test('updates the value and notifies listeners', () {
      final timer = GameTimerNotifier();
      addTearDown(timer.dispose);

      int notifyCount = 0;
      timer.addListener(() => notifyCount++);

      timer.setElapsedSeconds(120);
      expect(timer.elapsedSeconds, 120);
      expect(notifyCount, 1);
    });
  });

  group('GameTimerNotifier - listeners', () {
    test('notifies listeners each tick', () {
      fakeAsync((async) {
        final timer = GameTimerNotifier();
        addTearDown(timer.dispose);

        int notifyCount = 0;
        timer.addListener(() => notifyCount++);

        timer.start();
        async.elapse(const Duration(seconds: 3));
        expect(notifyCount, 3);
      });
    });
  });

  group('GameTimerNotifier - dispose', () {
    test('dispose stops the timer', () {
      fakeAsync((async) {
        final timer = GameTimerNotifier();
        timer.start();
        async.elapse(const Duration(seconds: 1));
        timer.dispose();

        // No further ticks should fire after dispose; no exceptions thrown.
        async.elapse(const Duration(seconds: 5));
        // We don't read elapsedSeconds after dispose because listeners are
        // cleared — but the absence of exceptions confirms cleanup.
      });
    });
  });
}
