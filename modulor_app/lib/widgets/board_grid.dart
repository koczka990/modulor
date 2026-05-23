import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/drag_data.dart';
import '../models/piece.dart';
import 'piece_widget.dart';

class BoardGrid extends StatelessWidget {
  final List<Piece?> board;
  final void Function(DragData data, int targetIndex) onDrop;

  const BoardGrid({
    super.key,
    required this.board,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const borderWidth = 4.0;
        final gridSize = constraints.maxHeight.isFinite
            ? constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight
            : constraints.maxWidth;
        final cellSize = (gridSize - 2 * borderWidth) / 3;
        return Container(
          width: gridSize,
          height: gridSize,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.ink, width: 4),
          ),
          child: Column(
            children: List.generate(3, (row) {
              return Row(
                children: List.generate(3, (col) {
                  final index = row * 3 + col;
                  final piece = board[index];
                  return DragTarget<DragData>(
                    onAcceptWithDetails: (details) =>
                        onDrop(details.data, index),
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.ink, width: 2),
                          color: candidateData.isNotEmpty
                              ? AppColors.secondaryContainer.withOpacity(0.3)
                              : AppColors.background,
                        ),
                        child: piece == null
                            ? null
                            : Draggable<DragData>(
                                data: DragData(
                                  piece: piece,
                                  fromTray: false,
                                  sourceIndex: index,
                                ),
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: PieceWidget(
                                      piece: piece, size: cellSize),
                                ),
                                childWhenDragging: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  color: AppColors.surfaceContainer,
                                ),
                                child:
                                    PieceWidget(piece: piece, size: cellSize),
                              ),
                      );
                    },
                  );
                }),
              );
            }),
          ),
        );
      },
    );
  }
}
