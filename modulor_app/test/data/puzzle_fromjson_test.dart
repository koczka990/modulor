import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/piece.dart';
import 'package:modulor_app/models/clue.dart';
import 'package:modulor_app/models/puzzle.dart';

void main() {
  group('Piece.fromJson', () {
    test('parses red circle', () {
      final p = Piece.fromJson({'color': 'red', 'shape': 'circle'});
      expect(p.color, PieceColor.red);
      expect(p.shape, PieceShape.circle);
    });

    test('parses yellow triangle', () {
      final p = Piece.fromJson({'color': 'yellow', 'shape': 'triangle'});
      expect(p.color, PieceColor.yellow);
      expect(p.shape, PieceShape.triangle);
    });

    test('parses blue square', () {
      final p = Piece.fromJson({'color': 'blue', 'shape': 'square'});
      expect(p.color, PieceColor.blue);
      expect(p.shape, PieceShape.square);
    });
  });

  group('CellReveal.fromJson', () {
    test('parses full reveal', () {
      final cr = CellReveal.fromJson({'r': 1, 'c': 2, 'color': 'blue', 'shape': 'circle'});
      expect(cr.row, 1);
      expect(cr.col, 2);
      expect(cr.color, PieceColor.blue);
      expect(cr.shape, PieceShape.circle);
    });

    test('parses empty cell (no color or shape)', () {
      final cr = CellReveal.fromJson({'r': 0, 'c': 0});
      expect(cr.color, isNull);
      expect(cr.shape, isNull);
    });
  });

  group('Puzzle.fromJson', () {
    test('parses id, solution, and clues', () {
      final json = {
        'id': 'easy_001',
        'solution': [
          {'color': 'red',    'shape': 'circle'},
          {'color': 'blue',   'shape': 'square'},
          {'color': 'yellow', 'shape': 'triangle'},
          {'color': 'blue',   'shape': 'circle'},
          {'color': 'yellow', 'shape': 'square'},
          {'color': 'red',    'shape': 'triangle'},
          {'color': 'yellow', 'shape': 'circle'},
          {'color': 'red',    'shape': 'square'},
          {'color': 'blue',   'shape': 'triangle'},
        ],
        'clues': [
          {
            'cells': [
              {'r': 0, 'c': 0, 'color': 'red', 'shape': 'circle'},
              {'r': 0, 'c': 1},
            ]
          }
        ],
      };
      final puzzle = Puzzle.fromJson(json);
      expect(puzzle.id, 'easy_001');
      expect(puzzle.solution.length, 9);
      expect(puzzle.solution[0].color, PieceColor.red);
      expect(puzzle.clues.length, 1);
      expect(puzzle.clues[0].reveals.length, 2); // all cells kept for bounding box
      expect(puzzle.clues[0].reveals[0].color, PieceColor.red);
      expect(puzzle.clues[0].reveals[1].color, isNull);
    });
  });
}
