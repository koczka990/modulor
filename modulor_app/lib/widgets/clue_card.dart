import 'package:flutter/material.dart';
import '../models/clue.dart';
import '../models/piece.dart';
import 'piece_widget.dart';

class ClueCard extends StatelessWidget {
  final Clue clue;
  final double cellSize;

  const ClueCard({super.key, required this.clue, this.cellSize = 28});

  @override
  Widget build(BuildContext context) {
    final revealMap = {
      for (final r in clue.reveals) r.row * 3 + r.col: r,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (col) {
              final reveal = revealMap[row * 3 + col];
              return Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26, width: 0.5),
                  color: Colors.grey.shade100,
                ),
                child: reveal == null ? null : _buildReveal(reveal),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildReveal(CellReveal reveal) {
    if (reveal.color != null && reveal.shape != null) {
      return PieceWidget(
        piece: Piece(color: reveal.color!, shape: reveal.shape!),
        size: cellSize,
      );
    }
    if (reveal.color != null) {
      return _ColorOnlyWidget(color: reveal.color!, size: cellSize);
    }
    // Shape only: reuse PieceWidget with grey tint via ColorFiltered
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
      child: PieceWidget(
        piece: Piece(color: PieceColor.red, shape: reveal.shape!),
        size: cellSize,
      ),
    );
  }
}

class _ColorOnlyWidget extends StatelessWidget {
  final PieceColor color;
  final double size;

  const _ColorOnlyWidget({required this.color, required this.size});

  static const _colors = {
    PieceColor.red:   Color(0xFFCC0000),
    PieceColor.blue:  Color(0xFF0055BB),
    PieceColor.green: Color(0xFF007700),
  };

  @override
  Widget build(BuildContext context) {
    final pad = size * 0.1;
    return CustomPaint(
      size: Size(size, size),
      painter: _RectPainter(_colors[color]!, pad),
    );
  }
}

class _RectPainter extends CustomPainter {
  final Color color;
  final double pad;
  _RectPainter(this.color, this.pad);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(pad, pad, size.width - 2 * pad, size.height - 2 * pad),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_RectPainter old) => old.color != color;
}
