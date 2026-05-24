import 'piece.dart';
import 'clue.dart';

class Puzzle {
  final String id;
  final List<Piece> solution;
  final List<Clue> clues;

  const Puzzle({required this.id, required this.solution, required this.clues});

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'] as String,
      solution: (json['solution'] as List)
          .map((p) => Piece.fromJson(p as Map<String, dynamic>))
          .toList(),
      clues: (json['clues'] as List)
          .map((c) => Clue.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

const kHardcodedPuzzle = Puzzle(
  id: 'hardcoded_001',
  solution: [
    Piece(color: PieceColor.red,    shape: PieceShape.circle),
    Piece(color: PieceColor.blue,   shape: PieceShape.square),
    Piece(color: PieceColor.yellow, shape: PieceShape.triangle),
    Piece(color: PieceColor.blue,   shape: PieceShape.circle),
    Piece(color: PieceColor.yellow, shape: PieceShape.square),
    Piece(color: PieceColor.red,    shape: PieceShape.triangle),
    Piece(color: PieceColor.yellow, shape: PieceShape.circle),
    Piece(color: PieceColor.red,    shape: PieceShape.square),
    Piece(color: PieceColor.blue,   shape: PieceShape.triangle),
  ],
  clues: [
    Clue(reveals: [
      CellReveal(row: 0, col: 0, color: PieceColor.red,    shape: PieceShape.circle),
      CellReveal(row: 0, col: 1, color: PieceColor.blue,   shape: PieceShape.square),
    ]),
    Clue(reveals: [
      CellReveal(row: 0, col: 2, color: PieceColor.yellow, shape: PieceShape.triangle),
      CellReveal(row: 1, col: 2, color: PieceColor.red,    shape: PieceShape.triangle),
      CellReveal(row: 2, col: 2, color: PieceColor.blue,   shape: PieceShape.triangle),
    ]),
    Clue(reveals: [
      CellReveal(row: 1, col: 0, color: PieceColor.blue,   shape: PieceShape.circle),
      CellReveal(row: 1, col: 1, color: PieceColor.yellow, shape: PieceShape.square),
    ]),
    Clue(reveals: [
      CellReveal(row: 2, col: 0, color: PieceColor.yellow, shape: PieceShape.circle),
      CellReveal(row: 2, col: 1, color: PieceColor.red,    shape: PieceShape.square),
    ]),
  ],
);
