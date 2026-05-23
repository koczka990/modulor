# Modulor App Styling Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the Modulor Flutter app to match the provided design — new color palette, Archivo Narrow / JetBrains Mono fonts, styled top app bar, compact clue cards with colored headers, thick-bordered board, and styled tray. No game logic changes.

**Architecture:** Introduce a single `app_theme.dart` constants file as the source of truth for all colors. Each widget file is updated independently. The `ClueCard` compact-grid logic is self-contained within `clue_card.dart`.

**Tech Stack:** Flutter, `google_fonts` package (Archivo Narrow, JetBrains Mono), Material 3 theme.

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `pubspec.yaml` | Modify | Add `google_fonts` dependency |
| `lib/app_theme.dart` | Create | Color constants (`AppColors`) |
| `lib/main.dart` | Modify | Use `AppColors` in `MaterialApp` theme |
| `lib/widgets/piece_widget.dart` | Modify | New fill colors + 2px ink outline stroke |
| `lib/widgets/clue_card.dart` | Modify | Compact bounding-box grid, colored header label |
| `lib/widgets/clue_strip.dart` | Modify | Pass `index` to each `ClueCard` |
| `lib/widgets/board_grid.dart` | Modify | Full-width via `LayoutBuilder`, 4px outer / 2px inner borders |
| `lib/widgets/tray.dart` | Modify | `#edeeef` bg, 4px border, bordered piece boxes |
| `lib/widgets/game_screen.dart` | Modify | Custom header with hint icon, MODULOR title, settings popup |
| `test/widgets/game_screen_test.dart` | Modify | Update assertions for new header |

---

## Task 1: Add google_fonts dependency

**Files:**
- Modify: `modulor_app/pubspec.yaml`

- [ ] **Step 1: Add google_fonts to pubspec.yaml**

In `pubspec.yaml`, under `dependencies:`, add after `cupertino_icons`:

```yaml
  google_fonts: ^6.2.1
```

- [ ] **Step 2: Fetch the dependency**

```bash
cd modulor_app && flutter pub get
```

Expected output: resolves packages without errors, `pubspec.lock` updated.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/pubspec.yaml modulor_app/pubspec.lock
git commit -m "feat: add google_fonts dependency"
```

---

## Task 2: Create AppColors constants

**Files:**
- Create: `modulor_app/lib/app_theme.dart`

- [ ] **Step 1: Create the file**

Create `modulor_app/lib/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background       = Color(0xFFF8F9FA);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const primary          = Color(0xFFB7102A);
  static const secondaryContainer = Color(0xFFFFD167);
  static const tertiaryContainer  = Color(0xFF007EA4);
  static const ink              = Color(0xFF191C1D);

  // Piece fill colors (model: red → red, blue → teal, green → yellow)
  static const pieceRed    = Color(0xFFB7102A);
  static const pieceBlue   = Color(0xFF007EA4);
  static const pieceYellow = Color(0xFFFFD167);

  // Clue header colors cycle by index
  static const clueHeaderBg = [primary, secondaryContainer, tertiaryContainer];
  static const clueHeaderFg = [Color(0xFFFFFFFF), ink, Color(0xFFFFFFFF)];
}
```

- [ ] **Step 2: Commit**

```bash
git add modulor_app/lib/app_theme.dart
git commit -m "feat: add AppColors constants"
```

---

## Task 3: Update PieceWidget — new colors and outline stroke

**Files:**
- Modify: `modulor_app/lib/widgets/piece_widget.dart`
- Test: `modulor_app/test/widgets/piece_widget_test.dart`

- [ ] **Step 1: Run the existing test to confirm it passes before changes**

```bash
cd modulor_app && flutter test test/widgets/piece_widget_test.dart -v
```

Expected: all tests PASS.

- [ ] **Step 2: Update piece_widget.dart**

Replace the entire content of `modulor_app/lib/widgets/piece_widget.dart`:

```dart
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/piece.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final double size;

  const PieceWidget({super.key, required this.piece, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PiecePainter(piece),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final Piece piece;
  _PiecePainter(this.piece);

  static const _fillColors = {
    PieceColor.red:   AppColors.pieceRed,
    PieceColor.blue:  AppColors.pieceBlue,
    PieceColor.green: AppColors.pieceYellow,
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
        canvas.drawOval(rect, fill);
        canvas.drawOval(rect, stroke);
      case PieceShape.square:
        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, stroke);
      case PieceShape.triangle:
        final path = Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(_PiecePainter old) => old.piece != piece;
}
```

- [ ] **Step 3: Run the test again to confirm it still passes**

```bash
cd modulor_app && flutter test test/widgets/piece_widget_test.dart -v
```

Expected: all tests PASS (the test only checks that the widget renders without error).

- [ ] **Step 4: Commit**

```bash
git add modulor_app/lib/widgets/piece_widget.dart
git commit -m "feat: update PieceWidget with new colors and ink outline"
```

---

## Task 4: Update ClueCard — compact bounding-box grid with colored header

**Files:**
- Modify: `modulor_app/lib/widgets/clue_card.dart`

- [ ] **Step 1: Write failing widget test for compact grid dimensions**

Add a new test file `modulor_app/test/widgets/clue_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/clue.dart';
import 'package:modulor_app/models/piece.dart';
import 'package:modulor_app/widgets/clue_card.dart';

void main() {
  testWidgets('ClueCard 2x2 clue renders 4 cells', (tester) async {
    const clue = Clue(reveals: [
      CellReveal(row: 0, col: 0, color: PieceColor.red, shape: PieceShape.circle),
      CellReveal(row: 0, col: 1, color: PieceColor.blue, shape: PieceShape.square),
      CellReveal(row: 1, col: 0),
      CellReveal(row: 1, col: 1, color: PieceColor.green, shape: PieceShape.triangle),
    ]);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ClueCard(clue: clue, index: 0))),
    );
    // 2 rows × 2 cols = 4 cells; each cell is a Container with fixed size
    final cells = tester.widgetList<Container>(find.byType(Container));
    // At minimum 4 cell containers exist (plus outer containers)
    expect(cells.length, greaterThanOrEqualTo(4));
    expect(find.text('CLUE A'), findsOneWidget);
  });

  testWidgets('ClueCard 1x3 column clue renders 3 cells', (tester) async {
    const clue = Clue(reveals: [
      CellReveal(row: 0, col: 1, color: PieceColor.blue, shape: PieceShape.square),
      CellReveal(row: 1, col: 1),
      CellReveal(row: 2, col: 1, color: PieceColor.blue, shape: PieceShape.square),
    ]);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ClueCard(clue: clue, index: 1))),
    );
    expect(find.text('CLUE B'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ClueCard renders without error for all index values', (tester) async {
    for (int i = 0; i < 5; i++) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClueCard(
              clue: const Clue(reveals: [
                CellReveal(row: 0, col: 0, color: PieceColor.red, shape: PieceShape.circle),
              ]),
              index: i,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd modulor_app && flutter test test/widgets/clue_card_test.dart -v
```

Expected: FAIL — `ClueCard` does not yet accept an `index` parameter.

- [ ] **Step 3: Replace clue_card.dart with compact implementation**

Replace the entire content of `modulor_app/lib/widgets/clue_card.dart`:

```dart
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

    return Container(
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
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
      child: PieceWidget(
        piece: Piece(color: PieceColor.red, shape: reveal.shape!),
        size: cellSize,
      ),
    );
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
```

- [ ] **Step 4: Run the new test to verify it passes**

```bash
cd modulor_app && flutter test test/widgets/clue_card_test.dart -v
```

Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add modulor_app/lib/widgets/clue_card.dart modulor_app/test/widgets/clue_card_test.dart
git commit -m "feat: compact ClueCard with bounding-box grid and colored header"
```

---

## Task 5: Update ClueStrip — pass index to ClueCard

**Files:**
- Modify: `modulor_app/lib/widgets/clue_strip.dart`

- [ ] **Step 1: Update clue_strip.dart**

Replace the entire content of `modulor_app/lib/widgets/clue_strip.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/clue.dart';
import 'clue_card.dart';

class ClueStrip extends StatelessWidget {
  final List<Clue> clues;

  const ClueStrip({super.key, required this.clues});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: clues.indexed
            .map((e) => ClueCard(clue: e.$2, index: e.$1))
            .toList(),
      ),
    );
  }
}
```

- [ ] **Step 2: Run all tests to verify nothing is broken**

```bash
cd modulor_app && flutter test -v
```

Expected: all tests PASS.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/widgets/clue_strip.dart
git commit -m "feat: pass clue index to ClueCard for header color cycling"
```

---

## Task 6: Update BoardGrid — full-width layout and new border styling

**Files:**
- Modify: `modulor_app/lib/widgets/board_grid.dart`

- [ ] **Step 1: Replace board_grid.dart**

Replace the entire content of `modulor_app/lib/widgets/board_grid.dart`:

```dart
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
        final gridSize = constraints.maxWidth;
        final cellSize = gridSize / 3;
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
```

- [ ] **Step 2: Run all tests**

```bash
cd modulor_app && flutter test -v
```

Expected: all tests PASS.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/widgets/board_grid.dart
git commit -m "feat: full-width BoardGrid with 4px outer and 2px inner ink borders"
```

---

## Task 7: Update Tray — surface container background and bordered piece boxes

**Files:**
- Modify: `modulor_app/lib/widgets/tray.dart`

- [ ] **Step 1: Replace tray.dart**

Replace the entire content of `modulor_app/lib/widgets/tray.dart`:

```dart
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
                          child: _PieceBox(
                              piece: tray[i]!, size: pieceSize),
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
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
```

- [ ] **Step 2: Run all tests**

```bash
cd modulor_app && flutter test -v
```

Expected: all tests PASS.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/widgets/tray.dart
git commit -m "feat: styled Tray with surface-container background and bordered piece boxes"
```

---

## Task 8: Update GameScreen — styled header with MODULOR title, hint and settings

**Files:**
- Modify: `modulor_app/lib/widgets/game_screen.dart`
- Modify: `modulor_app/test/widgets/game_screen_test.dart`

- [ ] **Step 1: Update game_screen_test.dart first (tests for the new header)**

Replace the entire content of `modulor_app/test/widgets/game_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/puzzle.dart';
import 'package:modulor_app/widgets/game_screen.dart';

void main() {
  Widget buildGame() {
    return const MaterialApp(home: GameScreen(puzzle: kHardcodedPuzzle));
  }

  testWidgets('MODULOR title is visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.text('MODULOR'), findsOneWidget);
  });

  testWidgets('hint button is always visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
  });

  testWidgets('settings menu button is always visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('settings menu contains Restart option', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('tapping Restart does not crash', (tester) async {
    await tester.pumpWidget(buildGame());
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();
    expect(find.text('MODULOR'), findsOneWidget);
  });

  testWidgets('check button is not visible when board is empty', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.text('CHECK'), findsNothing);
  });

  testWidgets('clue strip is visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the new tests to verify they fail**

```bash
cd modulor_app && flutter test test/widgets/game_screen_test.dart -v
```

Expected: FAIL — `MODULOR`, `lightbulb_outline`, `settings_outlined` not found yet.

- [ ] **Step 3: Replace game_screen.dart**

Replace the entire content of `modulor_app/lib/widgets/game_screen.dart`:

```dart
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
```

- [ ] **Step 4: Run the game_screen tests to verify they pass**

```bash
cd modulor_app && flutter test test/widgets/game_screen_test.dart -v
```

Expected: all tests PASS.

- [ ] **Step 5: Run full test suite**

```bash
cd modulor_app && flutter test -v
```

Expected: all tests PASS.

- [ ] **Step 6: Commit**

```bash
git add modulor_app/lib/widgets/game_screen.dart modulor_app/test/widgets/game_screen_test.dart
git commit -m "feat: styled GameScreen header with MODULOR title, hint and settings menu"
```

---

## Task 9: Update main.dart theme

**Files:**
- Modify: `modulor_app/lib/main.dart`

- [ ] **Step 1: Update main.dart**

Replace the entire content of `modulor_app/lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'models/puzzle.dart';
import 'widgets/game_screen.dart';

void main() {
  runApp(const ModulorApp());
}

class ModulorApp extends StatelessWidget {
  const ModulorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modulor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.archivoNarrowTextTheme(),
        useMaterial3: true,
      ),
      home: const GameScreen(puzzle: kHardcodedPuzzle),
    );
  }
}
```

- [ ] **Step 2: Run full test suite**

```bash
cd modulor_app && flutter test -v
```

Expected: all tests PASS.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/main.dart
git commit -m "feat: update MaterialApp theme with Modulor color scheme and Archivo Narrow font"
```

---

## Done

All styling changes are complete. To verify the app visually:

```bash
cd modulor_app && flutter run
```

Check against the design reference:
- [ ] "MODULOR" title in red Archivo Narrow, lightbulb left, settings right
- [ ] Clue cards are compact (not always 3×3), each with a colored header label
- [ ] Board has thick black border, square layout
- [ ] Tray has grey background, each piece in a white bordered box
- [ ] Pieces are red / teal / yellow with black outline
