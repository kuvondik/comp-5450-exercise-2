import 'package:flutter/material.dart';
import 'dart:math';
import 'package:memory_match/layers/domain/entity/memory_card.dart';

class CardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;

  const CardWidget({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late CurvedAnimation _curvedAnimation;
  late Animation<double> _flipAnimation;
  bool _lastFlipState = false;
  static const double _perspective = 0.001;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _curvedAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_curvedAnimation);

    _lastFlipState = false;
    _checkFlipState();
  }

  @override
  void didUpdateWidget(CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkFlipState();
  }

  void _checkFlipState() {
    final currentFlipState = widget.card.isFlipped || widget.card.isMatched;

    if (currentFlipState != _lastFlipState) {
      _lastFlipState = currentFlipState;

      if (currentFlipState) {
        if (_flipController.isDismissed) {
          _flipController.forward();
        }
      } else {
        if (_flipController.isCompleted || _flipController.isAnimating) {
          _flipController.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.card.isMatched || widget.card.isFlipped ? null : widget.onTap,
        child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateY(angle);

          final isBack = _flipAnimation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Container(
              decoration: BoxDecoration(
                color: isBack ? Colors.teal.shade400 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.card.isMatched ? Colors.green : Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isBack
                  ? const Center(
                      child: Icon(
                        Icons.help,
                        size: 50,
                        color: Colors.white,
                      ),
                    )
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: Center(
                        child: widget.card.icon != null
                            ? Icon(
                                widget.card.icon,
                                size: 60,
                                color: widget.card.isMatched
                                    ? Colors.green
                                    : Colors.teal,
                              )
                            : Text(
                                '${widget.card.value + 1}',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: widget.card.isMatched
                                      ? Colors.green
                                      : Colors.teal,
                                ),
                              ),
                      ),
                    ),
            ),
          );
        },
      ),
    ),
    );
  }
}
