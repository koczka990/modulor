import 'piece.dart';
import 'clue.dart';

class Puzzle {
  final List<Piece> solution;
  final List<Clue> clues;

  const Puzzle({required this.solution, required this.clues});
}

const kHardcodedPuzzle = Puzzle(
  solution: [
    Piece(color: PieceColor.red,   shape: PieceShape.circle),    // (0,0)
    Piece(color: PieceColor.blue,  shape: PieceShape.square),    // (0,1)
    Piece(color: PieceColor.green, shape: PieceShape.triangle),  // (0,2)
    Piece(color: PieceColor.blue,  shape: PieceShape.circle),    // (1,0)
    Piece(color: PieceColor.green, shape: PieceShape.square),    // (1,1)
    Piece(color: PieceColor.red,   shape: PieceShape.triangle),  // (1,2)
    Piece(color: PieceColor.green, shape: PieceShape.circle),    // (2,0)
    Piece(color: PieceColor.red,   shape: PieceShape.square),    // (2,1)
    Piece(color: PieceColor.blue,  shape: PieceShape.triangle),  // (2,2)
  ],
  clues: [
    Clue(reveals: [
      CellReveal(row: 0, col: 0, color: PieceColor.red,   shape: PieceShape.circle),
      CellReveal(row: 0, col: 1, color: PieceColor.blue,  shape: PieceShape.square),
    ]),
    Clue(reveals: [
      CellReveal(row: 0, col: 2, color: PieceColor.green, shape: PieceShape.triangle),
      CellReveal(row: 1, col: 2, color: PieceColor.red,   shape: PieceShape.triangle),
      CellReveal(row: 2, col: 2, color: PieceColor.blue,  shape: PieceShape.triangle),
    ]),
    Clue(reveals: [
      CellReveal(row: 1, col: 0, color: PieceColor.blue,  shape: PieceShape.circle),
      CellReveal(row: 1, col: 1, color: PieceColor.green, shape: PieceShape.square),
    ]),
    Clue(reveals: [
      CellReveal(row: 2, col: 0, color: PieceColor.green, shape: PieceShape.circle),
      CellReveal(row: 2, col: 1, color: PieceColor.red,   shape: PieceShape.square),
    ]),
  ],
);
