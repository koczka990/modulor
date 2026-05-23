import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/puzzle.dart';
import 'package:modulor_app/widgets/game_screen.dart';

void main() {
  Widget buildGame() {
    return const MaterialApp(home: GameScreen(puzzle: kHardcodedPuzzle));
  }

  testWidgets('MODULOR title is visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.text('MODULOR'), findsOneWidget);
  });

  testWidgets('hint button is always visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
  });

  testWidgets('settings menu button is always visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('settings menu contains Restart option', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('tapping Restart does not crash', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();
    expect(find.text('MODULOR'), findsOneWidget);
  });

  testWidgets('check button is not visible when board is empty', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.text('CHECK'), findsNothing);
  });

  testWidgets('clue strip is visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
