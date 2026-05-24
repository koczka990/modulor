# Level Navigation Design

**Date:** 2026-05-24
**Status:** Approved

## Overview

Add a full navigation flow to the Modulor Flutter app:
Welcome → Puzzle Set Selector → Level Selector → Game → Completion.

Replaces the current hardcoded `GameScreen` home with proper routing, puzzle loading from JSON assets, and persistent progress tracking via a local SQLite database.

---

## Bug fix included

Rename `PieceColor.green` → `PieceColor.yellow` everywhere in Dart code. The enum name was wrong — visually the piece is yellow (`AppColors.pieceYellow = Color(0xFFFFD167)`), and the JSON asset uses `"yellow"`. All references in `piece.dart`, `app_theme.dart`, `puzzle.dart`, and any widget mapping piece colors must be updated.

---

## Navigation (go_router)

Route tree:

```
/                                        → WelcomeScreen
/sets                                    → PuzzleSetScreen
/sets/:setId/levels                      → LevelSelectScreen
/sets/:setId/levels/:levelIndex/play     → GameScreen
```

- `setId` is one of: `beginner | intermediate | expert`
- `levelIndex` is 0-based integer
- `WelcomeScreen` auto-navigates to `/sets` after its animation using `context.go('/sets')` — not pushable back
- "Back to menu" anywhere uses `context.go('/')` replacing the stack

## Completion navigation rules

After a correct CHECK in `GameScreen`:
- Mark level solved via `ProgressRepository`
- Show `CompletionOverlay` (full-screen stack overlay, not a new route)
- If next level exists and is NOT already solved → show "BACK TO MENU" + "NEXT LEVEL"
- If next level does not exist OR is already solved → show "BACK TO MENU" only, auto-route to `/sets` after tap
- "NEXT LEVEL" → `context.go('/sets/:setId/levels/:nextIndex/play')`
- "BACK TO MENU" → `context.go('/sets')`

---

## New files

```
lib/
  router.dart
  data/
    puzzle_repository.dart
    progress_database.dart       # drift schema + DAOs
    progress_repository.dart
  screens/
    welcome_screen.dart
    puzzle_set_screen.dart
    level_select_screen.dart
  widgets/
    completion_overlay.dart
```

---

## Data layer

### `progress_database.dart` (drift)

Schema — `puzzle_attempts` table:

| column       | type    | notes                              |
|--------------|---------|------------------------------------|
| id           | int PK  | autoincrement                      |
| puzzle_set   | text    | "beginner" / "intermediate" / "expert" |
| puzzle_id    | text    | e.g. "easy_001"                    |
| level_index  | int     | 0-based position in set            |
| solved_at    | int?    | Unix ms, null = attempted not solved |
| attempts     | int     | default 1                          |

### `progress_repository.dart`

Public API (all async):
- `Set<String> completedIds(String puzzleSet)`
- `bool isSolved(String puzzleSet, String puzzleId)`
- `Future<void> markSolved(String puzzleSet, String puzzleId, int levelIndex)`

### `puzzle_repository.dart`

- Loads `assets/puzzles/{setId}.json` via `rootBundle`
- Returns `List<Puzzle>` with `fromJson` factories
- Cached in memory per set after first load
- JSON color `"yellow"` maps to `PieceColor.yellow`; `"red"` → `PieceColor.red`; `"blue"` → `PieceColor.blue`

### `fromJson` factories needed

- `Piece.fromJson(Map<String, dynamic>)`
- `CellReveal.fromJson(Map<String, dynamic>)`
- `Clue.fromJson(Map<String, dynamic>)`
- `Puzzle.fromJson(Map<String, dynamic>)`

---

## Screens

### `WelcomeScreen`

- No app bar
- Scaffold background: `AppColors.background`
- Centered red square (`AppColors.primary`, 80×80)
- Scale animation: 0 → 1 over 600ms, hold 400ms, then `context.go('/sets')`
- Uses `SingleTickerProviderStateMixin` + `AnimationController`

### `PuzzleSetScreen`

Matches `puzzle_sets_page_design.html`:
- Top app bar: menu icon | "MODULOR" label | settings icon
- Page title: "PUZZLE SETS" with bottom border
- 2-column grid (1 column on narrow screens) of set tiles:
  - Beginner: `secondaryContainer` background, `change_history` icon
  - Intermediate: `tertiaryContainer` background, `square` icon
  - Expert: `primary` background, `category` icon
- Each tile shows: set name, icon, progress bar, "N/M Solved"
- Progress loaded with `FutureBuilder` from `ProgressRepository`
- Tile tap → `context.go('/sets/$setId/levels')`

### `LevelSelectScreen`

Matches `level_page_design.html`:
- Same top app bar
- Header: "LEVELS" + set name, bottom border
- 2-column square-cell grid
- Cell states (determined from `ProgressRepository.completedIds`):
  - **Completed**: colored bg cycling `[primary, secondaryContainer, tertiaryContainer]` by index; 3 filled dots bottom-right
  - **Current** (first unsolved unlocked): white bg, play icon centered, `primary` ring border; 3 empty dots
  - **Locked**: `surfaceVariant` bg, lock icon, 60% opacity
- Unlock rule: level N is unlocked iff N == 0 OR level N-1 is solved
- Tap unlocked → `context.go('/sets/$setId/levels/$index/play')`
- Rebuilds fresh on every visit (no caching of unlock state)

### `GameScreen` changes

- Constructor changes: takes `setId: String` + `levelIndex: int` instead of `puzzle: Puzzle`
- Loads puzzle via `PuzzleRepository` in `initState` (async, shows loading indicator)
- On correct CHECK: calls `ProgressRepository.markSolved`, then shows `CompletionOverlay`
- Keeps existing drag-and-drop and CHECK logic unchanged

### `CompletionOverlay`

- Full-screen semi-transparent dim layer
- Centered card with "CORRECT!" headline
- Shows "BACK TO MENU" + "NEXT LEVEL" buttons if next level exists and is unsolved
- Shows only "BACK TO MENU" otherwise

---

## `pubspec.yaml` changes

Dependencies to add:
- `go_router: ^14.0.0`
- `drift: ^2.0.0`
- `sqlite3_flutter_libs: ^0.5.0`
- `path_provider: ^2.0.0`
- `path: ^1.0.0`

Dev dependencies to add:
- `drift_dev: ^2.0.0`
- `build_runner: ^2.0.0`

Drift requires a `build_runner` code-generation step (`dart run build_runner build`) to generate the `.g.dart` companion files from the schema.

Asset paths to fix (current entries reference non-existent filenames):
```yaml
assets:
  - assets/puzzles/beginner.json
  - assets/puzzles/intermediate.json
  - assets/puzzles/expert.json
```

---

## Out of scope

- Bottom navigation bar / sidebar (referenced in HTML designs but not wired up yet)
- Stats screen
- Settings screen
- Menu drawer
- Richer progress stats (time elapsed, hint count) — schema is ready for them
- Floating clues (separate spec in `docs/floating-clues.md`)
