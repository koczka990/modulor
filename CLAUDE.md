# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

Modulor is a logic puzzle game. Each puzzle is a 3×3 grid where every cell holds one of 9 unique "pieces" (3 colors × 3 shapes). Clues reveal partial information about cells; the player must deduce the full arrangement by drag-and-drop.

The repo has two independent components that do not share code at runtime:

- **`puzzle/`** — Python engine for generating and validating puzzles
- **`modulor_app/`** — Flutter app (the actual game UI)

---

## Commands

### Python (puzzle engine)

Python 3.11 is required (see `.python-version`).

```bash
pytest                             # run all tests
pytest tests/test_generator.py -v # run a single test file
pytest tests/test_solver.py::test_fully_constrained_has_one_solution -v  # single test
```

No virtual environment setup is documented; dependencies are stdlib only (`itertools`, `dataclasses`, `random`).

### Flutter (app)

All Flutter commands run from inside `modulor_app/`.

```bash
flutter run                                          # run on connected device/emulator
flutter test                                         # run all widget/unit tests
flutter test test/models/piece_test.dart             # run a single test file
flutter analyze                                      # static analysis (dart analyze equivalent)
```

---

## Architecture

### Python puzzle engine

The engine is a pure-Python pipeline (`puzzle/`):

1. **`model.py`** — core types: `Cookie` (color+shape), `Grid` (9-cell dict), `CellReveal` (optional color + optional shape), `Clue` (tuple of `(Cell, CellReveal)` pairs). All frozen dataclasses; hashable.
2. **`shapes.py`** — enumerates all 294 unique connected shapes for a 3×3 grid, each with its possible placements as 3×3 binary matrices.
3. **`clues.py`** — `enumerate_clues(solution, max_size, allowed_info)`: for every shape placement × every combination of reveal types, emits a `Clue` whose reveals are read from the solution.
4. **`solver.py`** — `count_solutions(clues, limit=2)`: CSP backtracking with domain reduction and MRV (most-constrained-variable) heuristic. Stops at `limit` to avoid full enumeration.
5. **`generator.py`** — `generate_puzzle(difficulty)`: shuffles candidates → greedily adds until uniquely solvable → removes any redundant clues (top-down removal). Difficulty controls `max_size` and `allowed_info`.

### Flutter app

State is managed entirely in `GameScreen` (a `StatefulWidget`). The screen holds two flat lists:
- `board: List<Piece?>` — 9 cells in row-major order, initially all `null`
- `tray: List<Piece?>` — the puzzle's pieces, initially all present

Drag-and-drop uses Flutter's built-in `Draggable<DragData>` / `DragTarget<DragData>`. `DragData` carries `piece`, `fromTray`, and `sourceIndex` so both the source and target can swap correctly.

Key widget relationships:
- `GameScreen` → `ClueStrip` → `ClueCard` (one per clue, header color cycles via `AppColors.clueHeaderBg[index % 3]`)
- `GameScreen` → `BoardGrid` (each cell is a `DragTarget`; placed pieces are also `Draggable`)
- `GameScreen` → `Tray` (a `DragTarget` wrapping a `Wrap` of draggable `_PieceBox`es; overlays the CHECK button when all 9 board cells are filled)

All design tokens live in `app_theme.dart` (`AppColors`). Note: the model names `red`/`blue`/`green` map to actual display colors `pieceRed` (crimson) / `pieceBlue` (teal) / `pieceYellow` (yellow) — the enum name does not equal the visual color.

### Connection between the two components

The Python engine generates puzzles; the Flutter app currently uses `kHardcodedPuzzle` (a `const` value in `models/puzzle.dart`). There is no runtime bridge yet. Future work would serialize generated puzzles and load them in the app.

Dart naming differs from Python: `Piece` (Dart) = `Cookie` (Python); `PieceColor`/`PieceShape` are enums (Dart) vs plain strings (Python).

---

## Planned extensions

- **Floating clues** — clues whose cell positions are relative, not absolute. Requires changes to the solver (disjunctive constraints over all placements) and the generator (candidate pool collapses placement-specific clues). Documented in `docs/floating-clues.md`.
- **Difficulty tiers** — easy uses `both` reveals only; hard uses partial reveals only (color-only or shape-only). Documented in `docs/puzzle-generation.md`.
