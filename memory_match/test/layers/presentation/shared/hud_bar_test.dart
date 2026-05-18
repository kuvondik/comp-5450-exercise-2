import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_match/layers/presentation/shared/hud_bar.dart';

Future<void> _pumpHudBar(
  WidgetTester tester, {
  required int moves,
  required int matchedPairs,
  required int totalPairs,
  required String formattedTime,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HudBar(
          moves: moves,
          matchedPairs: matchedPairs,
          totalPairs: totalPairs,
          formattedTime: formattedTime,
        ),
      ),
    ),
  );
}

void main() {
  group('HudBar', () {
    testWidgets('renders all three stat labels', (tester) async {
      await _pumpHudBar(
        tester,
        moves: 0,
        matchedPairs: 0,
        totalPairs: 12,
        formattedTime: '00s',
      );

      expect(find.text('Moves'), findsOneWidget);
      expect(find.text('Matched'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
    });

    testWidgets('renders moves count', (tester) async {
      await _pumpHudBar(
        tester,
        moves: 7,
        matchedPairs: 3,
        totalPairs: 12,
        formattedTime: '01m:23s',
      );

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('renders matched as "n/total"', (tester) async {
      await _pumpHudBar(
        tester,
        moves: 4,
        matchedPairs: 3,
        totalPairs: 12,
        formattedTime: '00s',
      );

      expect(find.text('3/12'), findsOneWidget);
    });

    testWidgets('renders the provided formattedTime verbatim', (tester) async {
      await _pumpHudBar(
        tester,
        moves: 0,
        matchedPairs: 0,
        totalPairs: 12,
        formattedTime: '01h:02m:05s',
      );

      expect(find.text('01h:02m:05s'), findsOneWidget);
    });
  });
}
