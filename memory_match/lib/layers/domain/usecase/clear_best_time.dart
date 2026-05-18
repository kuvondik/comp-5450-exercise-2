import '../repository/game_repository.dart';

class ClearBestTime {
  final GameRepository _repository;

  ClearBestTime({required GameRepository repository}) : _repository = repository;

  Future<void> call() {
    return _repository.deleteBestTime();
  }
}
