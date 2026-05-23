import 'package:flutter/material.dart';
import '../models/piece.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final double size;

  const PieceWidget({super.key, required this.piece, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PiecePainter(piece),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final Piece piece;
  _PiecePainter(this.piece);

  static const _colors = {
    PieceColor.red:   Color(0xFFCC0000),
    PieceColor.blue:  Color(0xFF0055BB),
    PieceColor.green: Color(0xFF007700),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _colors[piece.color]!
      ..style = PaintingStyle.fill;

    final pad = size.width * 0.1;
    final rect = Rect.fromLTWH(
      pad, pad, size.width - 2 * pad, size.height - 2 * pad,
    );

    switch (piece.shape) {
      case PieceShape.circle:
        canvas.drawOval(rect, paint);
      case PieceShape.square:
        canvas.drawRect(rect, paint);
      case PieceShape.triangle:
        canvas.drawPath(
          Path()
            ..moveTo(rect.center.dx, rect.top)
            ..lineTo(rect.right, rect.bottom)
            ..lineTo(rect.left, rect.bottom)
            ..close(),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_PiecePainter old) => old.piece != piece;
}
