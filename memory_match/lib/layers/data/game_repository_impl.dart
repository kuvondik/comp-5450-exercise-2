import 'package:memory_match/layers/domain/entity/game_session.dart';
import 'package:memory_match/layers/domain/repository/game_repository.dart';
import 'dto/game_session_dto.dart';
import 'source/local/local_storage.dart';

class GameRepositoryImpl implements GameRepository {
  final LocalStorage _localStorage;

  GameRepositoryImpl({required LocalStorage localStorage})
      : _localStorage = localStorage;

  @override
  Future<int> getHighScore() {
    return _localStorage.loadHighScore();
  }

  @override
  Future<void> saveHighScore(int score) {
    return _localStorage.saveHighScore(score);
  }

  @override
  Future<int> getBestTime() {
    return _localStorage.loadBestTime();
  }

  @override
  Future<void> saveBestTime(int seconds) {
    return _localStorage.saveBestTime(seconds);
  }

  @override
  Future<void> deleteBestTime() {
    return _localStorage.deleteBestTime();
  }

  @override
  Future<bool> hasSavedGame() {
    return _localStorage.hasSavedGame();
  }

  @override
  Future<GameSession?> loadSavedGame() async {
    final raw = await _localStorage.loadRawGame();
    if (raw == null) return null;
    try {
      return GameSessionDto.fromRawString(raw).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveCurrentGame(GameSession session) async {
    final dto = GameSessionDto.fromEntity(session);
    await _localStorage.saveRawGame(dto.toRawString());
  }

  @override
  Future<void> deleteHighScore() {
    return _localStorage.deleteHighScore();
  }

  @override
  Future<void> deleteSavedGame() {
    return _localStorage.deleteSavedGame();
  }
}
