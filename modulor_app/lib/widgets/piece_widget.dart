import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/piece.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final double size;
  final bool outlineOnly;

  const PieceWidget({
    super.key,
    required this.piece,
    required this.size,
    this.outlineOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PiecePainter(piece, outlineOnly: outlineOnly),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final Piece piece;
  final bool outlineOnly;

  _PiecePainter(this.piece, {this.outlineOnly = false});

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
        if (!outlineOnly) canvas.drawOval(rect, fill);
        canvas.drawOval(rect, stroke);
      case PieceShape.square:
        if (!outlineOnly) canvas.drawRect(rect, fill);
        canvas.drawRect(rect, stroke);
      case PieceShape.triangle:
        final path = Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
        if (!outlineOnly) canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(_PiecePainter old) =>
      old.piece != piece || old.outlineOnly != outlineOnly;
}
