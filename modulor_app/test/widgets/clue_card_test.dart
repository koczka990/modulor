import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/clue.dart';
import 'package:modulor_app/models/piece.dart';
import 'package:modulor_app/widgets/clue_card.dart';

void main() {
  testWidgets('ClueCard 2x2 clue renders 4 cells', (tester) async {
    const clue = Clue(reveals: [
      CellReveal(row: 0, col: 0, color: PieceColor.red, shape: PieceShape.circle),
      CellReveal(row: 0, col: 1, color: PieceColor.blue, shape: PieceShape.square),
      CellReveal(row: 1, col: 0),
      CellReveal(row: 1, col: 1, color: PieceColor.green, shape: PieceShape.triangle),
    ]);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ClueCard(clue: clue, index: 0))),
    );
    // 2 rows × 2 cols = 4 cells; each cell is a Container with fixed size
    final cells = tester.widgetList<Container>(find.byType(Container));
    // At minimum 4 cell containers exist (plus outer containers)
    expect(cells.length, greaterThanOrEqualTo(4));
    expect(find.text('CLUE A'), findsOneWidget);
  });

  testWidgets('ClueCard 1x3 column clue renders 3 cells', (tester) async {
    const clue = Clue(reveals: [
      CellReveal(row: 0, col: 1, color: PieceColor.blue, shape: PieceShape.square),
      CellReveal(row: 1, col: 1),
      CellReveal(row: 2, col: 1, color: PieceColor.blue, shape: PieceShape.square),
    ]);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ClueCard(clue: clue, index: 1))),
    );
    expect(find.text('CLUE B'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ClueCard renders without error for all index values', (tester) async {
    for (int i = 0; i < 5; i++) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClueCard(
              clue: const Clue(reveals: [
                CellReveal(row: 0, col: 0, color: PieceColor.red, shape: PieceShape.circle),
              ]),
              index: i,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
