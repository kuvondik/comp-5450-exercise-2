import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<int> loadHighScore();
  Future<void> saveHighScore(int score);
  Future<int> loadBestTime();
  Future<void> saveBestTime(int seconds);
  Future<void> deleteBestTime();
  Future<bool> hasSavedGame();
  Future<String?> loadRawGame();
  Future<void> saveRawGame(String raw);
  Future<void> deleteHighScore();
  Future<void> deleteSavedGame();
}

class LocalStorageImpl implements LocalStorage {
  static const String _highScoreKey = 'highScore';
  static const String _bestTimeKey = 'bestTime';
  static const String _savedGameKey = 'savedGame';
  late final SharedPreferences _prefs;

  LocalStorageImpl();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<int> loadHighScore() async {
    return _prefs.getInt(_highScoreKey) ?? 0;
  }

  @override
  Future<void> saveHighScore(int score) async {
    await _prefs.setInt(_highScoreKey, score);
  }

  @override
  Future<int> loadBestTime() async {
    return _prefs.getInt(_bestTimeKey) ?? 0;
  }

  @override
  Future<void> saveBestTime(int seconds) async {
    await _prefs.setInt(_bestTimeKey, seconds);
  }

  @override
  Future<void> deleteBestTime() async {
    await _prefs.remove(_bestTimeKey);
  }

  @override
  Future<bool> hasSavedGame() async {
    return _prefs.containsKey(_savedGameKey);
  }

  @override
  Future<String?> loadRawGame() async {
    return _prefs.getString(_savedGameKey);
  }

  @override
  Future<void> saveRawGame(String raw) async {
    await _prefs.setString(_savedGameKey, raw);
  }

  @override
  Future<void> deleteHighScore() async {
    await _prefs.remove(_highScoreKey);
  }

  @override
  Future<void> deleteSavedGame() async {
    await _prefs.remove(_savedGameKey);
  }
}
