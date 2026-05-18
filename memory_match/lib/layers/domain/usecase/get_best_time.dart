import '../repository/game_repository.dart';

class GetBestTime {
  final GameRepository _repository;

  GetBestTime({required GameRepository repository}) : _repository = repository;

  Future<int> call() {
    return _repository.getBestTime();
  }
}
