import '../repository/game_repository.dart';

class HasSavedGame {
  final GameRepository _repository;

  HasSavedGame({required GameRepository repository}) : _repository = repository;

  Future<bool> call() {
    return _repository.hasSavedGame();
  }
}
