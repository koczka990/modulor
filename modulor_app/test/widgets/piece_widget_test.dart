import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/piece.dart';
import 'package:modulor_app/widgets/piece_widget.dart';

void main() {
  testWidgets('PieceWidget renders all 9 pieces without error', (tester) async {
    for (final color in PieceColor.values) {
      for (final shape in PieceShape.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PieceWidget(
                piece: Piece(color: color, shape: shape),
                size: 48,
              ),
            ),
          ),
        );
        expect(find.byType(PieceWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
