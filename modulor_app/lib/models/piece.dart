enum PieceColor { red, blue, green }
enum PieceShape { circle, square, triangle }

class Piece {
  final PieceColor color;
  final PieceShape shape;

  const Piece({required this.color, required this.shape});

  @override
  bool operator ==(Object other) =>
      other is Piece && other.color == color && other.shape == shape;

  @override
  int get hashCode => Object.hash(color, shape);
}
