import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/drag_data.dart';
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
              color: candidateData.isNotEmpty
                  ? Colors.amber.withOpacity(0.15)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                          child: PieceWidget(piece: tray[i]!, size: pieceSize),
                        ),
                        childWhenDragging: SizedBox(
                          width: pieceSize,
                          height: pieceSize,
                        ),
                        child: SizedBox(
                          width: pieceSize,
                          height: pieceSize,
                          child: PieceWidget(piece: tray[i]!, size: pieceSize),
                        ),
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
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
