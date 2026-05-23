import 'piece.dart';

class CellReveal {
  final int row;
  final int col;
  final PieceColor? color;
  final PieceShape? shape;

  const CellReveal({
    required this.row,
    required this.col,
    this.color,
    this.shape,
  });
}

class Clue {
  final List<CellReveal> reveals;
  const Clue({required this.reveals});
}
