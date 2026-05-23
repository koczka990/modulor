import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../models/drag_data.dart';
import '../models/piece.dart';
import '../models/puzzle.dart';
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

  Widget _buildHeader() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.ink, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: AppColors.primary),
            tooltip: 'Hint',
            onPressed: null,
          ),
          Expanded(
            child: Text(
              'MODULOR',
              textAlign: TextAlign.center,
              style: GoogleFonts.archivoNarrow(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            tooltip: 'Menu',
            onSelected: (value) {
              if (value == 'restart') _reset();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'restart',
                child: Text('Restart'),
              ),
              const PopupMenuItem(
                value: 'menu',
                enabled: false,
                child: Text('Back to Menu'),
              ),
              const PopupMenuItem(
                value: 'settings',
                enabled: false,
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBoardFull = board.every((p) => p != null);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            ClueStrip(clues: widget.puzzle.clues),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: Center(
                  child: BoardGrid(
                    board: board,
                    onDrop: _onDropToBoard,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              child: Tray(
                tray: tray,
                isBoardFull: isBoardFull,
                onDropToTray: _onDropToTray,
                onCheck: _checkSolution,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
