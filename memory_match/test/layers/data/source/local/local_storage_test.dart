import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/data/source/local/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageImpl storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageImpl();
    await storage.init();
  });

  group('LocalStorageImpl - high score', () {
    test('returns 0 when no high score saved', () async {
      expect(await storage.loadHighScore(), 0);
    });

    test('persists and reads back a high score', () async {
      await storage.saveHighScore(150);
      expect(await storage.loadHighScore(), 150);
    });

    test('deleteHighScore resets to 0', () async {
      await storage.saveHighScore(99);
      await storage.deleteHighScore();
      expect(await storage.loadHighScore(), 0);
    });
  });

  group('LocalStorageImpl - best time', () {
    test('returns 0 when no best time saved', () async {
      expect(await storage.loadBestTime(), 0);
    });

    test('persists and reads back a best time', () async {
      await storage.saveBestTime(45);
      expect(await storage.loadBestTime(), 45);
    });

    test('deleteBestTime resets to 0', () async {
      await storage.saveBestTime(60);
      await storage.deleteBestTime();
      expect(await storage.loadBestTime(), 0);
    });

    test('overwrites existing best time on save', () async {
      await storage.saveBestTime(100);
      await storage.saveBestTime(50);
      expect(await storage.loadBestTime(), 50);
    });
  });

  group('LocalStorageImpl - saved game', () {
    test('hasSavedGame is false initially', () async {
      expect(await storage.hasSavedGame(), isFalse);
    });

    test('loadRawGame returns null initially', () async {
      expect(await storage.loadRawGame(), isNull);
    });

    test('saveRawGame then hasSavedGame is true', () async {
      await storage.saveRawGame('0|0|0|');
      expect(await storage.hasSavedGame(), isTrue);
    });

    test('saveRawGame then loadRawGame returns same string', () async {
      const raw = '2|5|45|0,true,true';
      await storage.saveRawGame(raw);
      expect(await storage.loadRawGame(), raw);
    });

    test('deleteSavedGame removes the saved game', () async {
      await storage.saveRawGame('abc');
      await storage.deleteSavedGame();
      expect(await storage.hasSavedGame(), isFalse);
      expect(await storage.loadRawGame(), isNull);
    });
  });
}
