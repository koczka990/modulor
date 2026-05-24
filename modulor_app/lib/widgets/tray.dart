import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/drag_data.dart';
import '../models/piece.dart';
import 'piece_widget.dart';

class Tray extends StatelessWidget {
  final List<Piece?> tray;
  final bool isBoardFull;
  final void Function(DragData data) onDropToTray;
  final VoidCallback onCheck;

  const Tray({
    super.key,
    required this.tray,
    required this.isBoardFull,
    required this.onDropToTray,
    required this.onCheck,
  });

  static const _spacing = 8.0;
  static const _padding = 12.0;
  static const _borderWidth = 4.0;
  static const _itemsPerRow = 5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        DragTarget<DragData>(
          onAcceptWithDetails: (details) => onDropToTray(details.data),
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.ink, width: _borderWidth),
                color: candidateData.isNotEmpty
                    ? AppColors.secondaryContainer.withOpacity(0.2)
                    : AppColors.surfaceContainer,
              ),
              padding: const EdgeInsets.all(_padding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pieceSize = (constraints.maxWidth -
                          _spacing * (_itemsPerRow - 1)) /
                      _itemsPerRow;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TrayRow(tray: tray, start: 0, count: 5, pieceSize: pieceSize),
                      const SizedBox(height: _spacing),
                      _TrayRow(tray: tray, start: 5, count: 4, pieceSize: pieceSize),
                    ],
                  );
                },
              ),
            );
          },
        ),
        if (isBoardFull)
          ElevatedButton(
            onPressed: onCheck,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero),
            ),
            child: const Text(
              'CHECK',
              style: TextStyle(fontSize: 18, letterSpacing: 3),
            ),
          ),
      ],
    );
  }
}

class _TrayRow extends StatelessWidget {
  final List<Piece?> tray;
  final int start;
  final int count;
  final double pieceSize;

  const _TrayRow({
    required this.tray,
    required this.start,
    required this.count,
    required this.pieceSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final index = start + i;
        final piece = tray[index];
        final isLast = i == count - 1;
        Widget slot;
        if (piece == null) {
          slot = SizedBox(width: pieceSize, height: pieceSize);
        } else {
          slot = Draggable<DragData>(
            data: DragData(piece: piece, fromTray: true, sourceIndex: index),
            feedback: Material(
              color: Colors.transparent,
              child: _PieceBox(piece: piece, size: pieceSize),
            ),
            childWhenDragging: SizedBox(width: pieceSize, height: pieceSize),
            child: _PieceBox(piece: piece, size: pieceSize),
          );
        }
        return Padding(
          padding: EdgeInsets.only(right: isLast ? 0 : 8),
          child: slot,
        );
      }),
    );
  }
}

class _PieceBox extends StatelessWidget {
  final Piece piece;
  final double size;

  const _PieceBox({required this.piece, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ink, width: 2),
        color: AppColors.background,
      ),
      child: PieceWidget(piece: piece, size: size),
    );
  }
}
