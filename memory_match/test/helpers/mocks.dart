import 'package:mocktail/mocktail.dart';
import 'package:memory_match/layers/data/source/local/local_storage.dart';
import 'package:memory_match/layers/domain/entity/game_session.dart';
import 'package:memory_match/layers/domain/repository/game_repository.dart';
import 'package:memory_match/layers/domain/usecase/clear_best_time.dart';
import 'package:memory_match/layers/domain/usecase/delete_saved_game.dart';
import 'package:memory_match/layers/domain/usecase/generate_new_game.dart';
import 'package:memory_match/layers/domain/usecase/get_best_time.dart';
import 'package:memory_match/layers/domain/usecase/has_saved_game.dart';
import 'package:memory_match/layers/domain/usecase/load_saved_game.dart';
import 'package:memory_match/layers/domain/usecase/save_best_time.dart';
import 'package:memory_match/layers/domain/usecase/save_current_game.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

class MockGameRepository extends Mock implements GameRepository {}

class MockGenerateNewGame extends Mock implements GenerateNewGame {}

class MockGetBestTime extends Mock implements GetBestTime {}

class MockSaveBestTime extends Mock implements SaveBestTime {}

class MockClearBestTime extends Mock implements ClearBestTime {}

class MockHasSavedGame extends Mock implements HasSavedGame {}

class MockLoadSavedGame extends Mock implements LoadSavedGame {}

class MockSaveCurrentGame extends Mock implements SaveCurrentGame {}

class MockDeleteSavedGame extends Mock implements DeleteSavedGame {}

class FakeGameSession extends Fake implements GameSession {}
