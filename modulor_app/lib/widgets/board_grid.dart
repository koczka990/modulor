import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/drag_data.dart';
import 'piece_widget.dart';

class BoardGrid extends StatelessWidget {
  final List<Piece?> board;
  final void Function(DragData data, int targetIndex) onDrop;
  final double cellSize;

  const BoardGrid({
    super.key,
    required this.board,
    required this.onDrop,
    this.cellSize = 88,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (col) {
            final index = row * 3 + col;
            final piece = board[index];
            return DragTarget<DragData>(
              onAcceptWithDetails: (details) => onDrop(details.data, index),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54, width: 1.5),
                    color: candidateData.isNotEmpty
                        ? Colors.amber.withOpacity(0.3)
                        : Colors.grey.shade100,
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
                            child: PieceWidget(piece: piece, size: cellSize),
                          ),
                          childWhenDragging: Container(
                            width: cellSize,
                            height: cellSize,
                            color: Colors.grey.shade200,
                          ),
                          child: PieceWidget(piece: piece, size: cellSize),
                        ),
                );
              },
            );
          }),
        );
      }),
    );
  }
}
