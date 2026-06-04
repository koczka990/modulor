# Flutter Lesson Plan — Learn Through Modulor

Each lesson builds on the last. Every concept is anchored to a real file in this project so you can read actual code, not toy examples.

---

## Module 1 — Foundations

### Lesson 1 — Dart Types & Enums

**File:** `modulor_app/lib/models/piece.dart`

The simplest file in the project. It introduces:

- **`enum`** — `PieceColor` and `PieceShape` are Dart enums (line 1–2)
- **`class` with `final` fields** — immutable value types
- **`const` constructors** — `Piece` can be a compile-time constant (line 8)
- **`factory` constructors** — `Piece.fromJson` (line 24) is a named constructor that can return an existing instance or do validation
- **`operator ==` and `hashCode` override** — how Dart decides if two objects are equal (line 32–36)
- **`switch` expressions** — modern Dart's `switch` as an expression with exhaustive matching (line 10–15)

> **Exercise:** Add a `toString()` override to `Piece` that returns e.g. `"red circle"`.

---

### Lesson 2 — The Widget Tree

**Files:** `modulor_app/lib/main.dart`, `modulor_app/lib/widgets/piece_widget.dart`

Flutter's core idea: _everything is a widget, widgets form a tree._

- **`StatelessWidget`** — `PieceWidget` is a widget with no mutable state (line 5)
- **The `build()` method** — called by the framework whenever the widget needs to paint (line 18)
- **`BuildContext`** — your widget's handle to its position in the tree
- **`MaterialApp` / `Scaffold`** — the two outermost containers almost every Flutter app uses (`main.dart` line 19, `game_screen.dart` line 174)
- **`super.key`** — why every public widget accepts a `Key` parameter (line 6, 8)

> **Exercise:** Open `PieceWidget` and trace what `build()` returns — it's just a `CustomPaint`. Flutter called `build` on `PieceWidget`, which returned a `CustomPaint`, which the framework called `paint()` on.

---

### Lesson 3 — Layout: Column, Row, Stack

**Files:** `modulor_app/lib/widgets/game_screen.dart`, `modulor_app/lib/widgets/board_grid.dart`

Layout widgets don't draw pixels — they _position_ children.

- **`Column`** — children stacked vertically (`game_screen.dart` line 179)
- **`Row`** — children side by side (`board_grid.dart` line 37)
- **`Expanded`** — a child that grows to fill remaining space (`game_screen.dart` line 133)
- **`Stack`** — children drawn on top of each other; used for the `CompletionOverlay` (`game_screen.dart` line 178, 207)
- **`Positioned.fill`** — a `Stack` child that fills the entire stack (`game_screen.dart` line 208)
- **`Padding` / `Center`** — the simplest single-child layout widgets (lines 184, 187)
- **`SafeArea`** — keeps content away from notches and system UI (line 176)

> **Exercise:** In `_buildHeader()` (`game_screen.dart` line 116), trace why the title text sits in the center even though it has siblings on both sides. Hint: `Expanded` + `TextAlign.center`.

---

### Lesson 4 — Styling & Theming

**Files:** `modulor_app/lib/app_theme.dart`, `modulor_app/lib/main.dart`

Colours and fonts should live in one place — not scattered across widgets.

- **`AppColors`** — a utility class with a private constructor (`AppColors._()`) so nobody can instantiate it; all values are `static const` (line 3–20)
- **`ThemeData` + `ColorScheme.fromSeed`** — Material 3 theming in `main.dart` (line 23–30)
- **`GoogleFonts`** — loading web fonts at runtime via the `google_fonts` package (line 29)
- **Per-widget `TextStyle`** — overriding the theme locally with `GoogleFonts.archivoNarrow(...)` in `game_screen.dart` (line 137)

> **Exercise:** Change `AppColors.primary` from `0xFFB7102A` (red) to `0xFF1565C0` (blue) and hot-reload — watch every primary-colored element update instantly. This is why tokens belong in one file.

---

## Module 2 — State & Interaction

### Lesson 5 — StatefulWidget & setState

**File:** `modulor_app/lib/widgets/game_screen.dart`

When a widget needs to remember something, it becomes `StatefulWidget`.

- **`StatefulWidget`** splits into two classes: the widget (immutable config) and the `State` (mutable data) (line 15 vs 25)
- **`initState()`** — called once when the state is created; safe place to initialise (line 33)
- **`setState(() { ... })`** — tells Flutter to call `build()` again with new data (line 43, 60, 73)
- **`widget.` prefix** — how the `State` accesses its widget's fields (line 41)
- **`mounted` check** — always check `mounted` before calling `setState` in an async callback (line 109)

> **Exercise:** Add a `_moveCount` integer to `_GameScreenState`. Increment it inside `_onDropToBoard` using `setState`. Display it in the header.

---

### Lesson 6 — Async, Futures & Loading States

**File:** `modulor_app/lib/widgets/game_screen.dart` (lines 40–48, 81–113)

Disk I/O and databases cannot block the UI thread.

- **`Future<void>`** — a value that arrives later
- **`async` / `await`** — syntactic sugar over `Future.then()`
- **`_loadPuzzle()`** — loads JSON from assets asynchronously; the widget shows a `CircularProgressIndicator` until `_puzzle != null` (line 40, line 166)
- **Null as a loading sentinel** — `Puzzle? _puzzle` starts `null`; `build` checks for it (line 166)
- **`_checkSolution()`** — an async method that chains two `await`s, guards with `mounted`, then calls `setState` (line 81)

> **Exercise:** Add an artificial `await Future.delayed(Duration(seconds: 2))` at the top of `_loadPuzzle` and run the app. You'll see the loading spinner for 2 seconds, which shows how the null-sentinel pattern works.

---

### Lesson 7 — Drag & Drop

**Files:** `modulor_app/lib/widgets/board_grid.dart`, `modulor_app/lib/widgets/tray.dart`, `modulor_app/lib/models/drag_data.dart`

Flutter's built-in drag system uses a typed generic: `Draggable<T>` and `DragTarget<T>`.

- **`DragData`** — the payload carried by every drag gesture (`drag_data.dart`)
- **`Draggable<DragData>`** — wraps a piece on the board; has three child slots: `child` (normal), `childWhenDragging` (placeholder), `feedback` (follows the finger) (`board_grid.dart` line 55–73)
- **`DragTarget<DragData>`** — wraps each cell; its `builder` receives candidate data so you can highlight the cell on hover (line 40–76)
- **`onAcceptWithDetails`** — fires when the user releases a valid drag onto this target (line 41)
- **Callback pattern** — `onDrop` is passed down from `GameScreen`; child widgets don't manage state themselves (line 9)

> **Exercise:** Change the hover highlight colour from `secondaryContainer.withOpacity(0.3)` to something obvious like `Colors.red`. Drag a piece over a cell to verify.

---

## Module 3 — Drawing & Animation

### Lesson 8 — Custom Painting

**File:** `modulor_app/lib/widgets/piece_widget.dart`

When no built-in widget draws what you need, use `CustomPainter`.

- **`CustomPaint` widget** — takes a `painter` and a `size`; delegates drawing to the painter (line 19–23)
- **`CustomPainter.paint(Canvas, Size)`** — your drawing code runs here (line 39)
- **`Paint` object** — controls fill vs stroke, color, stroke width (line 40–47)
- **`Canvas` API** — `drawOval`, `drawRect`, `drawPath` for the three shapes (line 52–65)
- **`Path`** — for the triangle: `moveTo`, `lineTo`, `close` (line 59–63)
- **`shouldRepaint`** — return `true` only when the visual output actually changed; avoids unnecessary redraws (line 70–71)

> **Exercise:** Add a `PieceShape.diamond` case that draws a rotated square using `Path`. Add a `diamond` value to the enum and a branch to `_PiecePainter.paint`.

---

### Lesson 9 — Animations

**File:** `modulor_app/lib/screens/welcome_screen.dart`

Flutter animations are explicit: you control time, the framework maps it to pixels.

- **`AnimationController`** — the clock; `value` goes 0 → 1 over `duration` (line 14, 20–23)
- **`vsync: this`** — the `SingleTickerProviderStateMixin` prevents off-screen animation from wasting CPU (line 13)
- **`CurvedAnimation`** — wraps a controller and applies an easing curve (`Curves.easeOut`) (line 24)
- **`ScaleTransition`** — a built-in animated widget that reads the animation's value and scales its child (line 43)
- **`controller.forward()`** — starts the animation; returns a `Future` that completes when done (line 25)
- **`dispose()`** — always dispose controllers to avoid memory leaks (line 31–33)

> **Exercise:** Replace `Curves.easeOut` with `Curves.bounceOut` and hot-reload. The square will bounce when it appears.

---

## Module 4 — Architecture

### Lesson 10 — Navigation with GoRouter

**Files:** `modulor_app/lib/router.dart`, `modulor_app/lib/screens/`

Routing maps URLs to screens — useful on web, clean on mobile.

- **`GoRouter`** — a declarative router from the `go_router` package (line 9)
- **`GoRoute`** — maps a path pattern to a builder function (line 11)
- **Path parameters** — `:setId` and `:levelIndex` are captured and passed via `state.pathParameters` (line 22, 29)
- **`context.go('/sets')`** — programmatic navigation from anywhere in the widget tree (`game_screen.dart` line 151)
- **`MaterialApp.router`** — `main.dart` uses the router variant of `MaterialApp` instead of the simpler one (line 19)
- **`ValueKey`** — the `GameScreen` key (`'$setId-$levelIndex'`) forces Flutter to recreate state when navigating between levels (line 35)

> **Exercise:** Add a `/about` route that shows a simple `Scaffold` with your name. Navigate to it by adding a menu item in `game_screen.dart`'s `PopupMenuButton`.

---

### Lesson 11 — Splitting Widgets & Callbacks

**Files:** `modulor_app/lib/widgets/clue_card.dart`, `modulor_app/lib/widgets/clue_strip.dart`

Big `build` methods become hard to read. Decompose into focused widgets.

- **One file, one job** — `ClueStrip` renders a scrollable row of `ClueCard`s; each has a single responsibility
- **Props down / callbacks up** — `ClueCard` receives `clue`, `index`, `cellSize`; it never mutates state, it just renders
- **`IntrinsicWidth`** — sizes the card to fit its content rather than stretching (`clue_card.dart` line 45)
- **`List.generate(rows, ...)`** — building children programmatically instead of hard-coding (line 75)
- **Map for lookup** — `revealMap` converts the list of reveals into an `(row*cols+col) → reveal` map for O(1) cell lookup (line 34)

> **Exercise:** Extract `_buildHeader()` from `GameScreen` into its own `GameHeader` stateless widget. Pass the reset and menu callbacks as constructor parameters.

---

### Lesson 12 — Persistence with Drift

**Files:** `modulor_app/lib/data/progress_database.dart`, `modulor_app/lib/data/progress_repository.dart`, `modulor_app/lib/data/app_services.dart`

Most apps need to remember data between sessions.

- **Drift** — a type-safe SQLite wrapper for Flutter (replaces raw SQL)
- **`AppDatabase`** — a Drift `@DriftDatabase` class defining your tables (`progress_database.dart`)
- **Repository pattern** — `ProgressRepository` wraps the database so `GameScreen` never touches SQL directly; it just calls `progress.markSolved(...)` (`game_screen.dart` line 99)
- **Singleton service locator** — `AppServices.instance` is a hand-rolled singleton initialised in `main()` (`main.dart` line 10)
- **`initForTesting()`** — uses an in-memory database so tests don't touch the file system (`app_services.dart` line 21)

> **Exercise:** Read `progress_repository.dart` and explain in plain English what `completedIds` does. Then look at how `LevelSelectScreen` uses it to show checkmarks on solved levels.

---

## Suggested Order

| Week | Lessons | What you can build after |
|------|---------|--------------------------|
| 1    | 1–4     | Static screens with correct layout and colours |
| 2    | 5–7     | Interactive screens with working state and drag/drop |
| 3    | 8–9     | Custom-drawn components and smooth animations |
| 4    | 10–12   | Multi-screen apps with navigation, routing, and local storage |

Each lesson is self-contained — you can read the file, experiment with a change, hot-reload, and see results in seconds. That tight feedback loop is Flutter's biggest strength; use it.
