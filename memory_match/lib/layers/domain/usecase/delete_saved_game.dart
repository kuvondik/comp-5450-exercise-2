import '../repository/game_repository.dart';

class DeleteSavedGame {
  final GameRepository _repository;

  DeleteSavedGame({required GameRepository repository}) : _repository = repository;

  Future<void> call() {
    return _repository.deleteSavedGame();
  }
}
