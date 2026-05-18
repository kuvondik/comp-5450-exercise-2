import '../repository/game_repository.dart';

class SaveHighScore {
  final GameRepository _repository;

  SaveHighScore({required GameRepository repository}) : _repository = repository;

  Future<void> call(int score) {
    return _repository.saveHighScore(score);
  }
}
