import '../repository/game_repository.dart';

class DeleteHighScore {
  final GameRepository _repository;

  DeleteHighScore({required GameRepository repository}) : _repository = repository;

  Future<void> call() {
    return _repository.deleteHighScore();
  }
}
