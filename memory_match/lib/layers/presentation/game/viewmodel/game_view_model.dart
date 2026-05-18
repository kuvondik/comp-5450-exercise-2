import 'package:flutter/material.dart';
import 'package:memory_match/layers/domain/entity/game_session.dart';
import 'package:memory_match/layers/domain/entity/memory_card.dart';
import 'package:memory_match/layers/domain/usecase/generate_new_game.dart';
import 'package:memory_match/layers/domain/usecase/get_best_time.dart';
import 'package:memory_match/layers/domain/usecase/save_best_time.dart';
import 'package:memory_match/layers/domain/usecase/save_current_game.dart';
import 'package:memory_match/layers/presentation/shared/game_timer_notifier.dart';

class GameViewModel extends ChangeNotifier {
  final GenerateNewGame _generateNewGame;
  final SaveCurrentGame _saveCurrentGame;
  final GetBestTime _getBestTime;
  final SaveBestTime _saveBestTime;
  final GameTimerNotifier timerNotifier = GameTimerNotifier();

  late List<MemoryCard> _cards;
  int? _firstCardIndex;
  int? _secondCardIndex;
  int _matchedPairs = 0;
  int _moves = 0;
  bool _isProcessing = false;
  bool _isInitialized = false;
  bool _isGameOver = false;
  final int _gridRows = 6;
  final int _gridCols = 4;

  GameViewModel({
    required GenerateNewGame generateNewGame,
    required SaveCurrentGame saveCurrentGame,
    required GetBestTime getBestTime,
    required SaveBestTime saveBestTime,
  })  : _generateNewGame = generateNewGame,
        _saveCurrentGame = saveCurrentGame,
        _getBestTime = getBestTime,
        _saveBestTime = saveBestTime;

  List<MemoryCard> get cards => _cards;
  int get matchedPairs => _matchedPairs;
  int get moves => _moves;
  int get elapsedSeconds => timerNotifier.elapsedSeconds;
  bool get isProcessing => _isProcessing;
  bool get isInitialized => _isInitialized;
  bool get isGameOver => _isGameOver;
  int get gridRows => _gridRows;
  int get gridCols => _gridCols;
  int get totalPairs => (_gridRows * _gridCols) ~/ 2;

  String get formattedTime => timerNotifier.formattedTime;

  Future<void> initGame(GameSession? savedGame) async {
    try {
      if (savedGame != null) {
        _loadGameState(savedGame);
      } else {
        final session = _generateNewGame(_gridRows * _gridCols);
        _loadGameState(session);
      }
      _isInitialized = true;
      _startTimer();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing game: $e');
      final session = _generateNewGame(_gridRows * _gridCols);
      _loadGameState(session);
      _isInitialized = true;
      _startTimer();
      notifyListeners();
    }
  }

  void _loadGameState(GameSession session) {
    _cards = session.cards;
    _moves = session.moves;
    _matchedPairs = session.matchedPairs;
    timerNotifier.setElapsedSeconds(session.elapsedSeconds);
    _firstCardIndex = null;
    _secondCardIndex = null;
    _isProcessing = false;
    _isGameOver = false;
  }

  void flipCard(int index) {
    if (_isProcessing ||
        _cards[index].isMatched ||
        _cards[index].isFlipped ||
        _firstCardIndex == index) {
      return;
    }

    _cards[index].isFlipped = true;
    notifyListeners();

    if (_firstCardIndex == null) {
      _firstCardIndex = index;
    } else {
      _secondCardIndex = index;
      _isProcessing = true;
      _moves++;
      notifyListeners();

      _checkMatch();
    }
  }

  void _checkMatch() {
    Future.delayed(const Duration(milliseconds: 400), () {
      final firstCard = _cards[_firstCardIndex!];
      final secondCard = _cards[_secondCardIndex!];

      if (firstCard.value == secondCard.value) {
        firstCard.isMatched = true;
        secondCard.isMatched = true;
        _matchedPairs++;

        if (_matchedPairs == totalPairs) {
          _isGameOver = true;
          _stopTimer();
          _updateBestTime();
          notifyListeners();
        }
      } else {
        firstCard.isFlipped = false;
        secondCard.isFlipped = false;
        notifyListeners();
      }

      _firstCardIndex = null;
      _secondCardIndex = null;
      _isProcessing = false;
      notifyListeners();
    });
  }

  void _startTimer() {
    timerNotifier.start();
  }

  void _stopTimer() {
    timerNotifier.stop();
  }

  void pauseGame() {
    timerNotifier.pause();
  }

  void resumeGame() {
    timerNotifier.resume();
  }

  Future<void> saveGame() async {
    try {
      final session = GameSession(
        cards: _cards,
        moves: _moves,
        matchedPairs: _matchedPairs,
        elapsedSeconds: timerNotifier.elapsedSeconds,
      );
      await _saveCurrentGame(session);
    } catch (e) {
      debugPrint('Error saving game: $e');
    }
  }

  void resetGame() {
    _stopTimer();
    final session = _generateNewGame(_gridRows * _gridCols);
    _loadGameState(session);
    timerNotifier.reset();
    _startTimer();
    notifyListeners();
  }

  Future<void> _updateBestTime() async {
    try {
      final currentBestTime = await _getBestTime();
      if (currentBestTime == 0 || timerNotifier.elapsedSeconds < currentBestTime) {
        await _saveBestTime(timerNotifier.elapsedSeconds);
      }
    } catch (e) {
      debugPrint('Error updating best time: $e');
    }
  }

  @override
  void dispose() {
    timerNotifier.dispose();
    super.dispose();
  }
}
