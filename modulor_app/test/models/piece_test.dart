import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/piece.dart';

void main() {
  group('Piece', () {
    test('equality is value-based', () {
      expect(
        Piece(color: PieceColor.red, shape: PieceShape.circle),
        equals(Piece(color: PieceColor.red, shape: PieceShape.circle)),
      );
      expect(
        Piece(color: PieceColor.red, shape: PieceShape.circle),
        isNot(equals(Piece(color: PieceColor.blue, shape: PieceShape.circle))),
      );
    });

    test('hashCode is consistent with equality', () {
      final a = Piece(color: PieceColor.red, shape: PieceShape.circle);
      final b = Piece(color: PieceColor.red, shape: PieceShape.circle);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('all 9 color-shape combinations are distinct', () {
      final pieces = [
        for (final color in PieceColor.values)
          for (final shape in PieceShape.values)
            Piece(color: color, shape: shape),
      ];
      expect(pieces.toSet().length, equals(9));
    });
  });
}
