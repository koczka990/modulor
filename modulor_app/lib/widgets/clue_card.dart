import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../models/clue.dart';
import '../models/piece.dart';
import 'piece_widget.dart';

class ClueCard extends StatelessWidget {
  final Clue clue;
  final int index;
  final double cellSize;

  const ClueCard({
    super.key,
    required this.clue,
    required this.index,
    this.cellSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (clue.reveals.isEmpty) return const SizedBox.shrink();

    final minRow = clue.reveals.map((r) => r.row).reduce(min);
    final maxRow = clue.reveals.map((r) => r.row).reduce(max);
    final minCol = clue.reveals.map((r) => r.col).reduce(min);
    final maxCol = clue.reveals.map((r) => r.col).reduce(max);
    final rows = maxRow - minRow + 1;
    final cols = maxCol - minCol + 1;

    final revealMap = {
      for (final r in clue.reveals)
        (r.row - minRow) * cols + (r.col - minCol): r,
    };

    final headerBg =
        AppColors.clueHeaderBg[index % AppColors.clueHeaderBg.length];
    final headerFg =
        AppColors.clueHeaderFg[index % AppColors.clueHeaderFg.length];
    final label = 'CLUE ${String.fromCharCode(65 + index)}';

    return IntrinsicWidth(
      child: Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: headerBg,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: headerFg,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.ink, width: 2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(rows, (row) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(cols, (col) {
                    final reveal = revealMap[row * cols + col];
                    return Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.ink, width: 1),
                        color: AppColors.background,
                      ),
                      child: reveal == null ? null : _buildReveal(reveal),
                    );
                  }),
                );
              }),
            ),
          ),
        ],
      ),
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
      return _ColorSwatch(color: reveal.color!, size: cellSize);
    }
    if (reveal.shape != null) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: PieceWidget(
          piece: Piece(color: PieceColor.red, shape: reveal.shape!),
          size: cellSize,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ColorSwatch extends StatelessWidget {
  final PieceColor color;
  final double size;

  const _ColorSwatch({required this.color, required this.size});

  static const _colors = {
    PieceColor.red:   AppColors.pieceRed,
    PieceColor.blue:  AppColors.pieceBlue,
    PieceColor.green: AppColors.pieceYellow,
  };

  @override
  Widget build(BuildContext context) {
    final pad = size * 0.15;
    return CustomPaint(
      size: Size(size, size),
      painter: _SwatchPainter(_colors[color]!, pad),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  final Color color;
  final double pad;
  _SwatchPainter(this.color, this.pad);

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Rect.fromLTWH(pad, pad, size.width - 2 * pad, size.height - 2 * pad);
    canvas.drawRect(rect, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawRect(
      rect,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.color != color;
}
