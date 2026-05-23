import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/puzzle.dart';
import '../models/drag_data.dart';
import 'board_grid.dart';
import 'clue_strip.dart';
import 'tray.dart';

class GameScreen extends StatefulWidget {
  final Puzzle puzzle;

  const GameScreen({super.key, required this.puzzle});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<Piece?> board;
  late List<Piece?> tray;

  @override
  void initState() {
    super.initState();
    board = List<Piece?>.filled(9, null, growable: false);
    tray = List<Piece?>.from(widget.puzzle.solution);
  }

  void _reset() {
    setState(() {
      board = List<Piece?>.filled(9, null, growable: false);
      tray = List<Piece?>.from(widget.puzzle.solution);
    });
  }

  void _onDropToBoard(DragData data, int targetIndex) {
    setState(() {
      final Piece? displaced = board[targetIndex];
      board[targetIndex] = data.piece;
      if (data.fromTray) {
        tray[data.sourceIndex] = displaced;
      } else {
        board[data.sourceIndex] = displaced;
      }
    });
  }

  void _onDropToTray(DragData data) {
    if (data.fromTray) return;
    setState(() {
      final firstEmpty = tray.indexWhere((p) => p == null);
      if (firstEmpty == -1) return;
      board[data.sourceIndex] = null;
      tray[firstEmpty] = data.piece;
    });
  }

  void _checkSolution() {
    final solution = widget.puzzle.solution;
    final correct =
        List.generate(9, (i) => board[i] == solution[i]).every((b) => b);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(correct ? 'Correct!' : 'Not quite, keep trying.'),
        backgroundColor:
            correct ? Colors.green.shade700 : Colors.red.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBoardFull = board.every((p) => p != null);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _reset,
                    tooltip: 'Reset',
                  ),
                ],
              ),
            ),
            ClueStrip(clues: widget.puzzle.clues),
            Expanded(
              child: Center(
                child: BoardGrid(
                  board: board,
                  onDrop: _onDropToBoard,
                ),
              ),
            ),
            Tray(
              tray: tray,
              isBoardFull: isBoardFull,
              onDropToTray: _onDropToTray,
              onCheck: _checkSolution,
            ),
          ],
        ),
      ),
    );
  }
}
