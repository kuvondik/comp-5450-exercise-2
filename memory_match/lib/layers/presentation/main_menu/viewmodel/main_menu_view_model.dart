import 'package:flutter/material.dart';
import 'package:memory_match/layers/domain/usecase/clear_best_time.dart';
import 'package:memory_match/layers/domain/usecase/delete_saved_game.dart';
import 'package:memory_match/layers/domain/usecase/get_best_time.dart';
import 'package:memory_match/layers/domain/usecase/has_saved_game.dart';

class MainMenuViewModel extends ChangeNotifier {
  final HasSavedGame _hasSavedGameUseCase;
  final DeleteSavedGame _deleteSavedGame;
  final GetBestTime _getBestTime;
  final ClearBestTime _clearBestTime;

  bool _hasSavedGame = false;
  int _bestTime = 0;
  bool _isLoading = true;

  MainMenuViewModel({
    required HasSavedGame hasSavedGame,
    required DeleteSavedGame deleteSavedGame,
    required GetBestTime getBestTime,
    required ClearBestTime clearBestTime,
  })  : _hasSavedGameUseCase = hasSavedGame,
        _deleteSavedGame = deleteSavedGame,
        _getBestTime = getBestTime,
        _clearBestTime = clearBestTime;

  bool get hasSavedGame => _hasSavedGame;
  int get bestTime => _bestTime;
  bool get isLoading => _isLoading;

  String get formattedBestTime {
    final hours = _bestTime ~/ 3600;
    final minutes = (_bestTime % 3600) ~/ 60;
    final seconds = _bestTime % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}h:${minutes.toString().padLeft(2, '0')}m:${seconds.toString().padLeft(2, '0')}s';
    } else if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}m:${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds.toString().padLeft(2, '0')}s';
    }
  }

  Future<void> loadData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final hasSaved = await _hasSavedGameUseCase();
      final bestTime = await _getBestTime();

      _hasSavedGame = hasSaved;
      _bestTime = bestTime;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearSavedGame() async {
    try {
      await _deleteSavedGame();
      _hasSavedGame = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing saved game: $e');
    }
  }

  Future<void> clearBestTime() async {
    try {
      await _clearBestTime();
      _bestTime = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing best time: $e');
    }
  }
}
