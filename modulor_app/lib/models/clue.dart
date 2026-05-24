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

  factory CellReveal.fromJson(Map<String, dynamic> json) {
    return CellReveal(
      row: json['r'] as int,
      col: json['c'] as int,
      color: json['color'] != null
          ? Piece.colorFromJson(json['color'] as String)
          : null,
      shape: json['shape'] != null
          ? Piece.shapeFromJson(json['shape'] as String)
          : null,
    );
  }
}

class Clue {
  final List<CellReveal> reveals;
  const Clue({required this.reveals});

  factory Clue.fromJson(Map<String, dynamic> json) {
    final cells = (json['cells'] as List)
        .map((c) => CellReveal.fromJson(c as Map<String, dynamic>))
        .toList();
    return Clue(reveals: cells);
  }
}
