import 'package:get_it/get_it.dart';
import 'package:memory_match/layers/data/game_repository_impl.dart';
import 'package:memory_match/layers/data/source/local/local_storage.dart';
import 'package:memory_match/layers/domain/repository/game_repository.dart';
import 'package:memory_match/layers/domain/usecase/clear_best_time.dart';
import 'package:memory_match/layers/domain/usecase/delete_saved_game.dart';
import 'package:memory_match/layers/domain/usecase/generate_new_game.dart';
import 'package:memory_match/layers/domain/usecase/get_best_time.dart';
import 'package:memory_match/layers/domain/usecase/has_saved_game.dart';
import 'package:memory_match/layers/domain/usecase/load_saved_game.dart';
import 'package:memory_match/layers/domain/usecase/save_best_time.dart';
import 'package:memory_match/layers/domain/usecase/save_current_game.dart';
import 'game/viewmodel/game_view_model.dart';
import 'main_menu/viewmodel/main_menu_view_model.dart';

final getIt = GetIt.instance;

Future<void> initGetIt() async {
  // DATA
  final localStorage = LocalStorageImpl();
  await localStorage.init();
  getIt.registerSingleton<LocalStorage>(localStorage);

  getIt.registerSingleton<GameRepository>(
    GameRepositoryImpl(localStorage: getIt()),
  );

  // DOMAIN - USE CASES
  getIt.registerFactory(() => GenerateNewGame());
  getIt.registerFactory(() => GetBestTime(repository: getIt()));
  getIt.registerFactory(() => SaveBestTime(repository: getIt()));
  getIt.registerFactory(() => ClearBestTime(repository: getIt()));
  getIt.registerFactory(() => HasSavedGame(repository: getIt()));
  getIt.registerFactory(() => LoadSavedGame(repository: getIt()));
  getIt.registerFactory(() => SaveCurrentGame(repository: getIt()));
  getIt.registerFactory(() => DeleteSavedGame(repository: getIt()));

  // PRESENTATION - VIEWMODELS
  getIt.registerFactory(
    () => MainMenuViewModel(
      hasSavedGame: getIt(),
      deleteSavedGame: getIt(),
      getBestTime: getIt(),
      clearBestTime: getIt(),
    ),
  );

  getIt.registerFactory(
    () => GameViewModel(
      generateNewGame: getIt(),
      saveCurrentGame: getIt(),
      getBestTime: getIt(),
      saveBestTime: getIt(),
    ),
  );
}
