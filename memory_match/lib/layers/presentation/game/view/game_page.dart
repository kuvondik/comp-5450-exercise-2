import 'package:flutter/material.dart';
import 'package:memory_match/layers/domain/repository/game_repository.dart';
import 'package:memory_match/layers/presentation/injector.dart';
import 'package:memory_match/layers/presentation/main_menu/view/main_menu_page.dart';
import 'package:memory_match/layers/presentation/shared/card_widget.dart';
import 'package:memory_match/layers/presentation/shared/hud_bar.dart';
import '../viewmodel/game_view_model.dart';

class GamePage extends StatefulWidget {
  final String? savedGame;

  const GamePage({super.key, this.savedGame});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<GameViewModel>();
    Future.microtask(() async {
      if (savedGame == 'load') {
        final repo = getIt<GameRepository>();
        final session = await repo.loadSavedGame();
        if (mounted) {
          _viewModel.initGame(session);
        }
      } else {
        _viewModel.initGame(null);
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  String? get savedGame => widget.savedGame;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _showGameMenu();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Memory Match Game',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal.shade600,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: _showGameMenu,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.teal.shade200,
                Colors.teal.shade600,
              ],
            ),
          ),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.isGameOver) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showGameOverDialog();
                });
              }
              return _viewModel.isInitialized
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            ListenableBuilder(
                              listenable: _viewModel.timerNotifier,
                              builder: (context, _) {
                                return HudBar(
                                  moves: _viewModel.moves,
                                  matchedPairs: _viewModel.matchedPairs,
                                  totalPairs: _viewModel.totalPairs,
                                  formattedTime: _viewModel.formattedTime,
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _viewModel.gridCols,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                                itemCount: _viewModel.cards.length,
                                itemBuilder: (context, index) {
                                  return CardWidget(
                                    card: _viewModel.cards[index],
                                    onTap: () =>
                                        _viewModel.flipCard(index),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Loading game...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  void _showGameMenu() {
    _viewModel.pauseGame();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.pause_circle, color: Colors.teal.shade600, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Game Paused',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.touch_app, color: Colors.teal.shade600, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                '${_viewModel.moves}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Moves', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                '${_viewModel.matchedPairs}/${_viewModel.totalPairs}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Matched', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.schedule, color: Colors.orange.shade600, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                _viewModel.formattedTime,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'What would you like to do?',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                _viewModel.resumeGame();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal.shade600,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await _viewModel.saveGame();
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainMenuPage()),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Save & Exit'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade600,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainMenuPage()),
                );
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Exit'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade600,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade600, size: 32),
              const SizedBox(width: 12),
              const Text(
                'Victory!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.amber.shade50,
                        Colors.teal.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Amazing job!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.touch_app, color: Colors.teal.shade600, size: 24),
                              const SizedBox(height: 8),
                              const Text(
                                'Moves',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_viewModel.moves}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 70,
                            color: Colors.grey.shade300,
                          ),
                          Column(
                            children: [
                              Icon(Icons.schedule, color: Colors.orange.shade600, size: 24),
                              const SizedBox(height: 8),
                              const Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _viewModel.formattedTime,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _viewModel.resetGame();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Play Again'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal.shade600,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainMenuPage()),
                );
              },
              icon: const Icon(Icons.home),
              label: const Text('Main Menu'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal.shade600,
              ),
            ),
          ],
        );
      },
    );
  }
}
