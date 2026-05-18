import '../entity/game_session.dart';
import '../repository/game_repository.dart';

class LoadSavedGame {
  final GameRepository _repository;

  LoadSavedGame({required GameRepository repository}) : _repository = repository;

  Future<GameSession?> call() {
    return _repository.loadSavedGame();
  }
}
