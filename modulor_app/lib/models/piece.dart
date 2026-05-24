enum PieceColor { red, blue, yellow }
enum PieceShape { circle, square, triangle }

class Piece {
  final PieceColor color;
  final PieceShape shape;

  const Piece({required this.color, required this.shape});

  static PieceColor colorFromJson(String s) => switch (s) {
        'red'    => PieceColor.red,
        'blue'   => PieceColor.blue,
        'yellow' => PieceColor.yellow,
        _        => throw ArgumentError('Unknown color: $s'),
      };

  static PieceShape shapeFromJson(String s) => switch (s) {
        'circle'   => PieceShape.circle,
        'square'   => PieceShape.square,
        'triangle' => PieceShape.triangle,
        _          => throw ArgumentError('Unknown shape: $s'),
      };

  factory Piece.fromJson(Map<String, dynamic> json) {
    return Piece(
      color: colorFromJson(json['color'] as String),
      shape: shapeFromJson(json['shape'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Piece && other.color == color && other.shape == shape;

  @override
  int get hashCode => Object.hash(color, shape);
}
