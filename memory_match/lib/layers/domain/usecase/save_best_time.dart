import '../repository/game_repository.dart';

class SaveBestTime {
  final GameRepository _repository;

  SaveBestTime({required GameRepository repository}) : _repository = repository;

  Future<void> call(int seconds) {
    return _repository.saveBestTime(seconds);
  }
}
