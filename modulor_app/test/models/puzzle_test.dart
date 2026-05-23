import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/piece.dart';
import 'package:modulor_app/models/puzzle.dart';

void main() {
  group('kHardcodedPuzzle', () {
    test('solution has exactly 9 pieces', () {
      expect(kHardcodedPuzzle.solution.length, equals(9));
    });

    test('all 9 solution pieces are unique', () {
      expect(kHardcodedPuzzle.solution.toSet().length, equals(9));
    });

    test('solution covers every color-shape combination', () {
      final expected = {
        for (final color in PieceColor.values)
          for (final shape in PieceShape.values)
            Piece(color: color, shape: shape),
      };
      expect(kHardcodedPuzzle.solution.toSet(), equals(expected));
    });

    test('has at least one clue', () {
      expect(kHardcodedPuzzle.clues, isNotEmpty);
    });

    test('all clue reveals reference valid 3x3 cells', () {
      for (final clue in kHardcodedPuzzle.clues) {
        for (final reveal in clue.reveals) {
          expect(reveal.row, inInclusiveRange(0, 2));
          expect(reveal.col, inInclusiveRange(0, 2));
        }
      }
    });
  });
}
