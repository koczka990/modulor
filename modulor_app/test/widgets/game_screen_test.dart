import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/puzzle.dart';
import 'package:modulor_app/widgets/game_screen.dart';

void main() {
  Widget buildGame() {
    return const MaterialApp(home: GameScreen(puzzle: kHardcodedPuzzle));
  }

  testWidgets('reset button is always visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('check button is not visible when board is empty', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.text('CHECK'), findsNothing);
  });

  testWidgets('tapping reset does not crash', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('clue strip is visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
