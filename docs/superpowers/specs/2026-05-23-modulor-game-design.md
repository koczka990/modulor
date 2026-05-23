# Modulor Flutter App — Game Screen Design

**Date:** 2026-05-23
**Scope:** Base playable game with one hardcoded puzzle, drag-and-drop piece placement, clue display, and solution check.

---

## Overview

A mobile puzzle game where the player arranges 9 Bauhaus-style geometric pieces onto a 3×3 grid. Visual clues above the board reveal partial information about the correct arrangement. The player drags pieces from a tray into the grid, then checks their solution.

---

## Data Model

### Piece

```dart
enum PieceColor { red, blue, green }
enum PieceShape { circle, square, triangle }

class Piece {
  final PieceColor color;
  final PieceShape shape;
}
```

All 9 pieces are unique combinations of the 3 colors × 3 shapes.

### Clue

A clue is a set of cell reveals on the 3×3 grid. Each reveal specifies an absolute cell position `(row, col)` and what is known about that cell: color only, shape only, or both.

```dart
class CellReveal {
  final int row;
  final int col;
  final PieceColor? color;   // null = not revealed
  final PieceShape? shape;   // null = not revealed
}

class Clue {
  final List<CellReveal> reveals;
}
```

### Puzzle

A puzzle bundles:
- `solution`: `List<Piece>` of 9 entries in row-major order (index = row×3 + col)
- `clues`: `List<Clue>` — the constraints the player uses to solve it

The initial implementation uses a single hardcoded puzzle defined in `lib/models/puzzle.dart`.

---

## Game State

Lives entirely in `GameScreen` (a `StatefulWidget`), managed with plain `setState`. No state management package.

| Field | Type | Description |
|---|---|---|
| `board` | `List<Piece?>` | 9 slots (row-major). `null` = empty cell. |
| `tray` | `List<Piece?>` | 9 fixed-size slots. `null` = slot vacated. |

On start and reset: all 9 pieces in `tray`, `board` is all nulls.

**Drag interactions:**

| Source → Target | Result |
|---|---|
| Tray slot → empty board cell | Piece moves to board cell; tray slot becomes null. |
| Tray slot → occupied board cell | Pieces swap: board piece goes to the source tray slot. |
| Board cell → empty board cell | Piece moves; source cell becomes null. |
| Board cell → occupied board cell | Pieces swap. |
| Board cell → tray (any slot) | Piece returns to the first available tray slot. |

---

## UI Layout

Single `Column`, top to bottom:

### 1. Header

A thin row containing:
- App name or empty space (left)
- Reset button: circular arrow `IconButton` (top-right corner)

Reset moves all board pieces back to the first available tray slots and clears the board.

### 2. Clues Strip

A horizontally scrollable `SingleChildScrollView` containing a `Row` of clue cards. No labels on cards.

Each **clue card** renders a mini 3×3 grid:
- Revealed cells show the Bauhaus shape (color and/or shape, whichever is revealed). If only color is revealed, the cell shows a filled square in that color. If only shape is revealed, the shape is shown in grey. If both, the shape is shown in its color.
- Unrevealed cells are shown as light grey or empty squares.

### 3. Board

A fixed 3×3 grid. Each cell is simultaneously:
- A `DragTarget<Piece>` — accepts a dropped piece (swap or place)
- A `Draggable<Piece>` (when occupied) — allows the piece to be picked up

Empty cells: outlined light-grey square. Occupied cells: render the piece via `PieceWidget`.

### 4. Tray Zone

A `Stack`:
- **Bottom layer:** `Wrap` of `Draggable<Piece>` widgets for all non-null tray slots. The wrap area is also a `DragTarget` so board pieces can be dragged back.
- **Top layer:** Check button — rendered only when all 9 board cells are non-null (i.e. `board.every((p) => p != null)`). Overlays the tray.

**Check behavior:**
- All 9 placed → correct solution: show a `SnackBar` with "Correct!" (green).
- Incorrect: show a `SnackBar` with "Not quite, keep trying." (red). Pieces stay in place.

---

## Piece Rendering (`PieceWidget` / `CustomPainter`)

Bauhaus style: flat filled shapes, no shadows, no gradients, no decorations.

| Shape | Rendering |
|---|---|
| circle | `canvas.drawCircle` |
| square | `canvas.drawRect` (full tile, inset padding) |
| triangle | `canvas.drawPath` (isoceles triangle) |

Colors: `red → Color(0xFFCC0000)`, `blue → Color(0xFF0055BB)`, `green → Color(0xFF007700)`. Flat fills only — no gradients, no shadows.

---

## File Structure

```
modulor_app/lib/
  main.dart
  models/
    piece.dart          — Piece, PieceColor, PieceShape enums
    clue.dart           — CellReveal, Clue
    puzzle.dart         — hardcoded solution + clue list
  widgets/
    game_screen.dart    — root StatefulWidget, all game state + drag logic
    board_grid.dart     — 3×3 board with DragTarget/Draggable cells
    clue_strip.dart     — horizontally scrollable row of clue cards
    clue_card.dart      — single mini 3×3 clue grid (CustomPainter)
    piece_widget.dart   — Bauhaus shape CustomPainter
    tray.dart           — Wrap of draggable pieces + Check button overlay
```

---

## Hardcoded Puzzle (initial)

Solution (row-major, indices 0–8):

| Index | Cell | Color | Shape |
|---|---|---|---|
| 0 | (0,0) | red | circle |
| 1 | (0,1) | blue | square |
| 2 | (0,2) | green | triangle |
| 3 | (1,0) | blue | circle |
| 4 | (1,1) | green | square |
| 5 | (1,2) | red | triangle |
| 6 | (2,0) | green | circle |
| 7 | (2,1) | red | square |
| 8 | (2,2) | blue | triangle |

Clues (4 fixed clues, each a connected shape on the grid, all reveals are full color+shape):

- **Clue 1:** (0,0)=red/circle, (0,1)=blue/square — horizontal pair, top row
- **Clue 2:** (0,2)=green/triangle, (1,2)=red/triangle, (2,2)=blue/triangle — right column
- **Clue 3:** (1,0)=blue/circle, (1,1)=green/square — horizontal pair, middle row
- **Clue 4:** (2,0)=green/circle, (2,1)=red/square — horizontal pair, bottom row

All 9 cells are covered across these 4 clues, so the solution is uniquely determined.

---

## Out of Scope

- Puzzle generation (Python backend already handles this)
- Floating clues
- Multiple difficulty levels
- Animations beyond basic drag feedback
- Persistence / high scores
