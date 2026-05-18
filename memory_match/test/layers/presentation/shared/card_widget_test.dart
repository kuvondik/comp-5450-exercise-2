import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/presentation/shared/card_widget.dart';

import '../../../helpers/fixtures.dart';

Future<void> _pumpCard(
  WidgetTester tester, {
  required bool isFlipped,
  required bool isMatched,
  required VoidCallback onTap,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 80,
          height: 80,
          child: CardWidget(
            card: Fixtures.buildCard(
              value: 0,
              icon: Icons.star,
              isFlipped: isFlipped,
              isMatched: isMatched,
            ),
            onTap: onTap,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('CardWidget', () {
    testWidgets('invokes onTap when card is closed', (tester) async {
      int tapCount = 0;
      await _pumpCard(
        tester,
        isFlipped: false,
        isMatched: false,
        onTap: () => tapCount++,
      );

      await tester.tap(find.byType(CardWidget));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('does not invoke onTap when already flipped', (tester) async {
      int tapCount = 0;
      await _pumpCard(
        tester,
        isFlipped: true,
        isMatched: false,
        onTap: () => tapCount++,
      );
      // Let the flip animation settle so the front face is rendered.
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CardWidget));
      await tester.pump();

      expect(tapCount, 0);
    });

    testWidgets('does not invoke onTap when matched', (tester) async {
      int tapCount = 0;
      await _pumpCard(
        tester,
        isFlipped: false,
        isMatched: true,
        onTap: () => tapCount++,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CardWidget));
      await tester.pump();

      expect(tapCount, 0);
    });

    testWidgets('reveals the icon after flipping', (tester) async {
      await _pumpCard(
        tester,
        isFlipped: true,
        isMatched: false,
        onTap: () {},
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows help icon on the back when closed', (tester) async {
      await _pumpCard(
        tester,
        isFlipped: false,
        isMatched: false,
        onTap: () {},
      );

      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('is wrapped in a RepaintBoundary for GPU optimization',
        (tester) async {
      await _pumpCard(
        tester,
        isFlipped: false,
        isMatched: false,
        onTap: () {},
      );

      expect(
        find.descendant(
          of: find.byType(CardWidget),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );
    });
  });
}
