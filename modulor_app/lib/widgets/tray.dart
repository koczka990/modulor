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
  final double pieceSize;

  const Tray({
    super.key,
    required this.tray,
    required this.isBoardFull,
    required this.onDropToTray,
    required this.onCheck,
    this.pieceSize = 56,
  });

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
                border: Border.all(color: AppColors.ink, width: 4),
                color: candidateData.isNotEmpty
                    ? AppColors.secondaryContainer.withOpacity(0.2)
                    : AppColors.surfaceContainer,
              ),
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < tray.length; i++)
                    if (tray[i] != null)
                      Draggable<DragData>(
                        data: DragData(
                          piece: tray[i]!,
                          fromTray: true,
                          sourceIndex: i,
                        ),
                        feedback: Material(
                          color: Colors.transparent,
                          child: _PieceBox(piece: tray[i]!, size: pieceSize),
                        ),
                        childWhenDragging: SizedBox(
                          width: pieceSize,
                          height: pieceSize,
                        ),
                        child: _PieceBox(piece: tray[i]!, size: pieceSize),
                      ),
                ],
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
