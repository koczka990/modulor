import 'package:flutter/material.dart';
import '../app_theme.dart';
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

  static const _fillColors = {
    PieceColor.red:    AppColors.pieceRed,
    PieceColor.blue:   AppColors.pieceBlue,
    PieceColor.yellow: AppColors.pieceYellow,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = _fillColors[piece.color]!
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final pad = size.width * 0.1;
    final rect = Rect.fromLTWH(pad, pad, size.width - 2 * pad, size.height - 2 * pad);

    switch (piece.shape) {
      case PieceShape.circle:
        canvas.drawOval(rect, fill);
        canvas.drawOval(rect, stroke);
      case PieceShape.square:
        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, stroke);
      case PieceShape.triangle:
        final path = Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(_PiecePainter old) => old.piece != piece;
}
