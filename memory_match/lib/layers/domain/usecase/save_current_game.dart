import '../entity/game_session.dart';
import '../repository/game_repository.dart';

class SaveCurrentGame {
  final GameRepository _repository;

  SaveCurrentGame({required GameRepository repository}) : _repository = repository;

  Future<void> call(GameSession session) {
    return _repository.saveCurrentGame(session);
  }
}
