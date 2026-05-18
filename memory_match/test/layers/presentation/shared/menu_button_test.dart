import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/presentation/shared/menu_button.dart';

void main() {
  group('MenuButton', () {
    testWidgets('renders the provided label and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuButton(
              label: 'New Game',
              icon: Icons.play_arrow,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('New Game'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('invokes onPressed when tapped', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuButton(
              label: 'Continue',
              icon: Icons.restore,
              onPressed: () => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MenuButton));
      await tester.pump();

      expect(tapCount, 1);
    });
  });
}
