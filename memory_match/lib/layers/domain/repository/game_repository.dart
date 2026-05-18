import '../entity/game_session.dart';

abstract class GameRepository {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
  Future<int> getBestTime();
  Future<void> saveBestTime(int seconds);
  Future<void> deleteBestTime();
  Future<bool> hasSavedGame();
  Future<GameSession?> loadSavedGame();
  Future<void> saveCurrentGame(GameSession session);
  Future<void> deleteHighScore();
  Future<void> deleteSavedGame();
}
