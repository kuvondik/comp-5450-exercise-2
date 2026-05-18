import '../repository/game_repository.dart';

class GetHighScore {
  final GameRepository _repository;

  GetHighScore({required GameRepository repository}) : _repository = repository;

  Future<int> call() {
    return _repository.getHighScore();
  }
}
