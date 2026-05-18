import 'dart:async';
import 'package:flutter/foundation.dart';

class GameTimerNotifier extends ChangeNotifier {
  int _elapsedSeconds = 0;
  Timer? _gameTimer;
  bool _isRunning = false;

  int get elapsedSeconds => _elapsedSeconds;
  bool get isRunning => _isRunning;

  String get formattedTime {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}h:${minutes.toString().padLeft(2, '0')}m:${seconds.toString().padLeft(2, '0')}s';
    } else if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}m:${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds.toString().padLeft(2, '0')}s';
    }
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void pause() {
    if (!_isRunning) return;
    _isRunning = false;
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void resume() {
    if (_isRunning) return;
    start();
  }

  void reset() {
    stop();
    _elapsedSeconds = 0;
    notifyListeners();
  }

  void stop() {
    _isRunning = false;
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void setElapsedSeconds(int seconds) {
    _elapsedSeconds = seconds;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
