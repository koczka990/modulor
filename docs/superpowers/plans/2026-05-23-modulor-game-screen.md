# Modulor Game Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a playable Flutter puzzle game where the user drags 9 Bauhaus-style pieces onto a 3×3 board, guided by visual clues, and checks their solution.

**Architecture:** Single `GameScreen` StatefulWidget holds all state (`board` and `tray` as `List<Piece?>`). Each drag carries a `DragData` object so the drop handler knows both the piece and its source, enabling swapping. Widgets are stateless and receive callbacks from `GameScreen`.

**Tech Stack:** Flutter 3.x, Dart 3.x, `flutter_test` (already in devDependencies). No additional packages.

---

## File Map

| File | Responsibility |
|---|---|
| `lib/models/piece.dart` | `Piece`, `PieceColor`, `PieceShape` |
| `lib/models/clue.dart` | `CellReveal`, `Clue` |
| `lib/models/puzzle.dart` | `Puzzle` class + `kHardcodedPuzzle` constant |
| `lib/models/drag_data.dart` | `DragData` — payload carried by every `Draggable` |
| `lib/widgets/piece_widget.dart` | `CustomPainter` drawing Bauhaus shapes |
| `lib/widgets/clue_card.dart` | Mini 3×3 grid showing one clue |
| `lib/widgets/clue_strip.dart` | Horizontally scrollable row of `ClueCard`s |
| `lib/widgets/board_grid.dart` | 3×3 `DragTarget`/`Draggable` board |
| `lib/widgets/tray.dart` | `Wrap` of draggable pieces + Check button overlay |
| `lib/widgets/game_screen.dart` | Root `StatefulWidget`, all game state and logic |
| `lib/main.dart` | `MaterialApp` → `GameScreen` |
| `test/models/piece_test.dart` | Piece equality and hashCode |
| `test/models/puzzle_test.dart` | Hardcoded puzzle shape |
| `test/widgets/piece_widget_test.dart` | Renders all 9 combinations without error |
| `test/widgets/game_screen_test.dart` | Initial state, reset button visible, check hidden |

---

## Task 1: Data Models

**Files:**
- Create: `lib/models/piece.dart`
- Create: `lib/models/clue.dart`
- Create: `lib/models/puzzle.dart`
- Create: `lib/models/drag_data.dart`
- Create: `test/models/piece_test.dart`
- Create: `test/models/puzzle_test.dart`

- [ ] **Step 1: Write failing model tests**

Create `test/models/piece_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/piece.dart';

void main() {
  group('Piece', () {
    test('equality is value-based', () {
      expect(
        Piece(color: PieceColor.red, shape: PieceShape.circle),
        equals(Piece(color: PieceColor.red, shape: PieceShape.circle)),
      );
      expect(
        Piece(color: PieceColor.red, shape: PieceShape.circle),
        isNot(equals(Piece(color: PieceColor.blue, shape: PieceShape.circle))),
      );
    });

    test('hashCode is consistent with equality', () {
      final a = Piece(color: PieceColor.red, shape: PieceShape.circle);
      final b = Piece(color: PieceColor.red, shape: PieceShape.circle);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('all 9 color-shape combinations are distinct', () {
      final pieces = [
        for (final color in PieceColor.values)
          for (final shape in PieceShape.values)
            Piece(color: color, shape: shape),
      ];
      expect(pieces.toSet().length, equals(9));
    });
  });
}
```

Create `test/models/puzzle_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/piece.dart';
import 'package:modulor_app/models/puzzle.dart';

void main() {
  group('kHardcodedPuzzle', () {
    test('solution has exactly 9 pieces', () {
      expect(kHardcodedPuzzle.solution.length, equals(9));
    });

    test('all 9 solution pieces are unique', () {
      expect(kHardcodedPuzzle.solution.toSet().length, equals(9));
    });

    test('solution covers every color-shape combination', () {
      final expected = {
        for (final color in PieceColor.values)
          for (final shape in PieceShape.values)
            Piece(color: color, shape: shape),
      };
      expect(kHardcodedPuzzle.solution.toSet(), equals(expected));
    });

    test('has at least one clue', () {
      expect(kHardcodedPuzzle.clues, isNotEmpty);
    });

    test('all clue reveals reference valid 3x3 cells', () {
      for (final clue in kHardcodedPuzzle.clues) {
        for (final reveal in clue.reveals) {
          expect(reveal.row, inInclusiveRange(0, 2));
          expect(reveal.col, inInclusiveRange(0, 2));
        }
      }
    });
  });
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```
cd modulor_app && flutter test test/models/
```

Expected: errors like `Target of URI doesn't exist: 'package:modulor_app/models/piece.dart'`

- [ ] **Step 3: Implement the models**

Create `lib/models/piece.dart`:

```dart
enum PieceColor { red, blue, green }
enum PieceShape { circle, square, triangle }

class Piece {
  final PieceColor color;
  final PieceShape shape;

  const Piece({required this.color, required this.shape});

  @override
  bool operator ==(Object other) =>
      other is Piece && other.color == color && other.shape == shape;

  @override
  int get hashCode => Object.hash(color, shape);
}
```

Create `lib/models/clue.dart`:

```dart
import 'piece.dart';

class CellReveal {
  final int row;
  final int col;
  final PieceColor? color;
  final PieceShape? shape;

  const CellReveal({
    required this.row,
    required this.col,
    this.color,
    this.shape,
  });
}

class Clue {
  final List<CellReveal> reveals;
  const Clue({required this.reveals});
}
```

Create `lib/models/puzzle.dart`:

```dart
import 'piece.dart';
import 'clue.dart';

class Puzzle {
  final List<Piece> solution;
  final List<Clue> clues;

  const Puzzle({required this.solution, required this.clues});
}

const kHardcodedPuzzle = Puzzle(
  solution: [
    Piece(color: PieceColor.red,   shape: PieceShape.circle),    // (0,0)
    Piece(color: PieceColor.blue,  shape: PieceShape.square),    // (0,1)
    Piece(color: PieceColor.green, shape: PieceShape.triangle),  // (0,2)
    Piece(color: PieceColor.blue,  shape: PieceShape.circle),    // (1,0)
    Piece(color: PieceColor.green, shape: PieceShape.square),    // (1,1)
    Piece(color: PieceColor.red,   shape: PieceShape.triangle),  // (1,2)
    Piece(color: PieceColor.green, shape: PieceShape.circle),    // (2,0)
    Piece(color: PieceColor.red,   shape: PieceShape.square),    // (2,1)
    Piece(color: PieceColor.blue,  shape: PieceShape.triangle),  // (2,2)
  ],
  clues: [
    Clue(reveals: [
      CellReveal(row: 0, col: 0, color: PieceColor.red,   shape: PieceShape.circle),
      CellReveal(row: 0, col: 1, color: PieceColor.blue,  shape: PieceShape.square),
    ]),
    Clue(reveals: [
      CellReveal(row: 0, col: 2, color: PieceColor.green, shape: PieceShape.triangle),
      CellReveal(row: 1, col: 2, color: PieceColor.red,   shape: PieceShape.triangle),
      CellReveal(row: 2, col: 2, color: PieceColor.blue,  shape: PieceShape.triangle),
    ]),
    Clue(reveals: [
      CellReveal(row: 1, col: 0, color: PieceColor.blue,  shape: PieceShape.circle),
      CellReveal(row: 1, col: 1, color: PieceColor.green, shape: PieceShape.square),
    ]),
    Clue(reveals: [
      CellReveal(row: 2, col: 0, color: PieceColor.green, shape: PieceShape.circle),
      CellReveal(row: 2, col: 1, color: PieceColor.red,   shape: PieceShape.square),
    ]),
  ],
);
```

Create `lib/models/drag_data.dart`:

```dart
import 'piece.dart';

class DragData {
  final Piece piece;
  final bool fromTray;
  final int sourceIndex;

  const DragData({
    required this.piece,
    required this.fromTray,
    required this.sourceIndex,
  });
}
```

- [ ] **Step 4: Run tests to confirm they pass**

```
cd modulor_app && flutter test test/models/
```

Expected: 8 tests pass.

- [ ] **Step 5: Commit**

```bash
git add modulor_app/lib/models/ modulor_app/test/models/
git commit -m "feat: add data models (Piece, Clue, Puzzle, DragData)"
```

---

## Task 2: PieceWidget

**Files:**
- Create: `lib/widgets/piece_widget.dart`
- Create: `test/widgets/piece_widget_test.dart`

- [ ] **Step 1: Write failing widget test**

Create `test/widgets/piece_widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/piece.dart';
import 'package:modulor_app/widgets/piece_widget.dart';

void main() {
  testWidgets('PieceWidget renders all 9 pieces without error', (tester) async {
    for (final color in PieceColor.values) {
      for (final shape in PieceShape.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PieceWidget(
                piece: Piece(color: color, shape: shape),
                size: 48,
              ),
            ),
          ),
        );
        expect(find.byType(PieceWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
```

- [ ] **Step 2: Run test to confirm it fails**

```
cd modulor_app && flutter test test/widgets/piece_widget_test.dart
```

Expected: `Target of URI doesn't exist: 'package:modulor_app/widgets/piece_widget.dart'`

- [ ] **Step 3: Implement PieceWidget**

Create `lib/widgets/piece_widget.dart`:

```dart
import 'package:flutter/material.dart';
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

  static const _colors = {
    PieceColor.red:   Color(0xFFCC0000),
    PieceColor.blue:  Color(0xFF0055BB),
    PieceColor.green: Color(0xFF007700),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _colors[piece.color]!
      ..style = PaintingStyle.fill;

    final pad = size.width * 0.1;
    final rect = Rect.fromLTWH(
      pad, pad, size.width - 2 * pad, size.height - 2 * pad,
    );

    switch (piece.shape) {
      case PieceShape.circle:
        canvas.drawOval(rect, paint);
      case PieceShape.square:
        canvas.drawRect(rect, paint);
      case PieceShape.triangle:
        canvas.drawPath(
          Path()
            ..moveTo(rect.center.dx, rect.top)
            ..lineTo(rect.right, rect.bottom)
            ..lineTo(rect.left, rect.bottom)
            ..close(),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_PiecePainter old) => old.piece != piece;
}
```

- [ ] **Step 4: Run test to confirm it passes**

```
cd modulor_app && flutter test test/widgets/piece_widget_test.dart
```

Expected: 1 test passes.

- [ ] **Step 5: Commit**

```bash
git add modulor_app/lib/widgets/piece_widget.dart modulor_app/test/widgets/piece_widget_test.dart
git commit -m "feat: add PieceWidget Bauhaus CustomPainter"
```

---

## Task 3: ClueCard

**Files:**
- Create: `lib/widgets/clue_card.dart`

No separate test for `ClueCard` — it will be exercised by `GameScreen` tests in Task 7.

- [ ] **Step 1: Implement ClueCard**

Create `lib/widgets/clue_card.dart`:

```dart
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
      return _ColorOnlyPainter(color: reveal.color!, size: cellSize);
    }
    return _ShapeOnlyPainter(shape: reveal.shape!, size: cellSize);
  }
}

class _ColorOnlyPainter extends StatelessWidget {
  final PieceColor color;
  final double size;

  const _ColorOnlyPainter({required this.color, required this.size});

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

class _ShapeOnlyPainter extends StatelessWidget {
  final PieceShape shape;
  final double size;

  const _ShapeOnlyPainter({required this.shape, required this.size});

  @override
  Widget build(BuildContext context) {
    return PieceWidget(
      piece: Piece(color: PieceColor.red, shape: shape),
      size: size,
    );
  }
}
```

Note: `_ShapeOnlyPainter` reuses `PieceWidget` with a placeholder color for simplicity — the hardcoded puzzle only uses full color+shape reveals, so this path is not reached in the MVP.

- [ ] **Step 2: Run all tests to confirm nothing broke**

```
cd modulor_app && flutter test
```

Expected: all existing tests pass.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/widgets/clue_card.dart
git commit -m "feat: add ClueCard mini 3x3 clue grid"
```

---

## Task 4: ClueStrip

**Files:**
- Create: `lib/widgets/clue_strip.dart`

- [ ] **Step 1: Implement ClueStrip**

Create `lib/widgets/clue_strip.dart`:

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: clues.map((c) => ClueCard(clue: c)).toList(),
      ),
    );
  }
}
```

- [ ] **Step 2: Run all tests to confirm nothing broke**

```
cd modulor_app && flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/widgets/clue_strip.dart
git commit -m "feat: add ClueStrip horizontally scrollable clue row"
```

---

## Task 5: BoardGrid

**Files:**
- Create: `lib/widgets/board_grid.dart`

- [ ] **Step 1: Implement BoardGrid**

Create `lib/widgets/board_grid.dart`:

```dart
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
```

- [ ] **Step 2: Run all tests to confirm nothing broke**

```
cd modulor_app && flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/widgets/board_grid.dart
git commit -m "feat: add BoardGrid 3x3 drag-and-drop board"
```

---

## Task 6: Tray

**Files:**
- Create: `lib/widgets/tray.dart`

- [ ] **Step 1: Implement Tray**

Create `lib/widgets/tray.dart`:

```dart
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
```

- [ ] **Step 2: Run all tests to confirm nothing broke**

```
cd modulor_app && flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/widgets/tray.dart
git commit -m "feat: add Tray with piece wrap and check button overlay"
```

---

## Task 7: GameScreen

**Files:**
- Create: `lib/widgets/game_screen.dart`
- Create: `test/widgets/game_screen_test.dart`

- [ ] **Step 1: Write failing GameScreen tests**

Create `test/widgets/game_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/puzzle.dart';
import 'package:modulor_app/widgets/game_screen.dart';

void main() {
  Widget buildGame() {
    return const MaterialApp(home: GameScreen(puzzle: kHardcodedPuzzle));
  }

  testWidgets('reset button is always visible', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('check button is not visible when board is empty', (tester) async {
    await tester.pumpWidget(buildGame());
    expect(find.text('CHECK'), findsNothing);
  });

  testWidgets('tapping reset returns all pieces to tray', (tester) async {
    await tester.pumpWidget(buildGame());
    // Count piece widgets in tray before reset
    final before = find.byType(ElevatedButton);
    expect(before, findsNothing); // no check button yet

    // Tap reset — board should still be empty so state unchanged, no error
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('clue strip is visible', (tester) async {
    await tester.pumpWidget(buildGame());
    // ClueStrip renders a SingleChildScrollView
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```
cd modulor_app && flutter test test/widgets/game_screen_test.dart
```

Expected: `Target of URI doesn't exist: 'package:modulor_app/widgets/game_screen.dart'`

- [ ] **Step 3: Implement GameScreen**

Create `lib/widgets/game_screen.dart`:

```dart
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
```

- [ ] **Step 4: Run tests to confirm they pass**

```
cd modulor_app && flutter test test/widgets/game_screen_test.dart
```

Expected: 4 tests pass.

- [ ] **Step 5: Run the full test suite**

```
cd modulor_app && flutter test
```

Expected: all tests pass (delete or keep `test/widget_test.dart` — if it references `MyApp`, delete it to avoid a compile error).

Note: if `test/widget_test.dart` still references the old counter app, delete it:
```bash
rm modulor_app/test/widget_test.dart
```

- [ ] **Step 6: Commit**

```bash
git add modulor_app/lib/widgets/game_screen.dart modulor_app/test/widgets/game_screen_test.dart
git commit -m "feat: add GameScreen with full drag-and-drop game logic"
```

---

## Task 8: Wire up main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace main.dart**

Replace the entire contents of `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const GameScreen(puzzle: kHardcodedPuzzle),
    );
  }
}
```

- [ ] **Step 2: Run the full test suite one final time**

```
cd modulor_app && flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Verify the app compiles**

```
cd modulor_app && flutter build apk --debug 2>&1 | tail -5
```

Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`

(Or `flutter run` on a connected device/emulator for a live smoke test.)

- [ ] **Step 4: Commit**

```bash
git add modulor_app/lib/main.dart
git commit -m "feat: wire up main.dart to GameScreen"
```
