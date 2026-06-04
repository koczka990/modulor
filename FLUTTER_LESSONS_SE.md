# Flutter for Backend Engineers — Learn Through Modulor

You already know how to program. These lessons skip language fundamentals and focus on the mental model shifts that trip up backend developers coming to Flutter. Each lesson is anchored to a real file in this project.

---

## The One Thing to Internalise First

Flutter's UI is a **pure function of state**: `UI = f(state)`. You never mutate the DOM, you never call `element.style.color = ...`. Instead, you update state and Flutter recomputes the entire widget subtree from scratch. This is closer to React than to imperative Android/iOS development — but Flutter takes it further because it re-runs `build()` on every frame if needed, and it's fast enough for that to be fine.

Widgets are **immutable descriptions**, not live objects. Think of them like serialised request payloads, not database rows.

---

## Module 1 — Dart for People Who Already Code

### Lesson 1 — What's Actually Different About Dart

**File:** `modulor_app/lib/models/piece.dart`

Dart will feel instantly familiar. The things worth noting are what Dart does *differently*:

- **`const` is pervasive** — `const Piece(...)` (line 8) means the object is a compile-time constant, interned like string literals. Flutter uses this everywhere for performance: a `const` widget is never rebuilt.
- **`factory` constructors** (line 24) — not a static method, not a regular constructor. A factory *looks* like a constructor at the call site but can delegate, return cached instances, or throw. Common pattern for `fromJson`.
- **`operator ==`** (line 32) — Dart does not use structural equality by default. Unlike Python's `__eq__`, you must explicitly override it. The `Object.hash` utility (line 36) is the idiomatic way to combine fields for `hashCode`.
- **`switch` as an expression** (line 10–15) — since Dart 3, `switch` is exhaustive and returns a value. The compiler enforces coverage of all enum cases, like Rust's `match`.
- **No `null` without `?`** — Dart has sound null safety. `Puzzle? _puzzle` (game_screen.dart line 27) explicitly opts into nullability; everything else is guaranteed non-null at compile time.

---

## Module 2 — The Flutter Rendering Model

### Lesson 2 — Widgets, Elements, and the Render Tree

**File:** `modulor_app/lib/widgets/piece_widget.dart`, `modulor_app/lib/main.dart`

This is the most important conceptual lesson. Flutter has **three parallel trees**:

1. **Widget tree** — your code. Immutable descriptions, rebuilt freely.
2. **Element tree** — Flutter's internal reconciler. Persists across rebuilds, tracks widget identity. You never touch this directly.
3. **Render object tree** — handles layout and painting. Also persists.

When you call `setState`, Flutter rebuilds the *widget* subtree, then diffs it against the *element* tree (like a virtual DOM), and only updates the *render* tree where things actually changed. This is why rebuilding widgets freely is cheap.

**`StatelessWidget` vs `StatefulWidget`:**
- `StatelessWidget` — like a pure function. Given the same inputs, always produces the same output. `PieceWidget` (line 5): takes a `Piece` and a `size`, draws the shape. No side effects.
- `StatefulWidget` — splits into two objects: the **widget** (immutable config, can be thrown away and recreated) and the **State** (survives rebuilds, holds mutable data). See `GameScreen` / `_GameScreenState` (`game_screen.dart` line 15 vs 25).

**`BuildContext`** is not a magic god-object — it's your widget's node in the element tree. It's how `context.go('/sets')` works: GoRouter walks up the element tree from your widget to find the router. This is the same pattern as dependency injection via a service locator, except the "locator" is the widget tree itself.

**`Key`** is the reconciler hint. Without a key, Flutter matches widgets by type and position. With a `ValueKey('$setId-$levelIndex')` (`router.dart` line 35), it matches by identity — forcing the element (and its `State`) to be destroyed and recreated when the key changes. This is how navigating from level 1 to level 2 resets all game state.

---

### Lesson 3 — Layout: Constraints Flow Down, Sizes Flow Up

**Files:** `modulor_app/lib/widgets/board_grid.dart`, `modulor_app/lib/widgets/game_screen.dart`

Flutter's layout algorithm has one rule: a parent passes **constraints** (min/max width and height) to each child; the child reports back its **size**; the parent then positions it. You cannot size yourself without your parent's permission.

Understanding this explains what otherwise looks like mysterious behaviour:

- **`Expanded`** (`game_screen.dart` line 133) — tells `Column`/`Row` "give me all remaining space after siblings take what they need." Without it, a `Column` child only gets the space it requests.
- **`LayoutBuilder`** (`board_grid.dart` line 19) — exposes the constraints passed down to your widget, so you can make layout decisions based on available space. Used here to make the board a perfect square that fits its container.
- **`IntrinsicWidth`** (`clue_card.dart` line 45) — forces a widget to be as wide as its widest child. Expensive (requires a two-pass layout), but correct for cards that must shrink-wrap their content.
- **`SizedBox` / `Container` with explicit dimensions** — manually override the size negotiation. Fine for fixed-size UI elements like the 64px header (`game_screen.dart` line 118).

The practical rule: if a widget is unexpectedly filling the screen or collapsing to zero size, the layout constraint chain is the first thing to investigate.

---

## Module 3 — State Management

### Lesson 4 — Local State with setState

**File:** `modulor_app/lib/widgets/game_screen.dart`

`setState` is Flutter's simplest state primitive. It's synchronous, local to one `State` object, and directly analogous to updating a variable and re-rendering. For a single screen with self-contained logic, it's the right tool.

The lifecycle methods matter:
- **`initState()`** (line 33) — runs once after the element is inserted into the tree. The equivalent of a constructor for stateful behaviour. `_loadPuzzle()` is called here.
- **`dispose()`** — runs when the element is removed. Clean up controllers, subscriptions, streams here. Missing `dispose()` on an `AnimationController` is a common memory leak.
- **`didUpdateWidget(oldWidget)`** — not used here, but important: called when the parent rebuilds and passes new config to an existing state. Equivalent to a React `componentDidUpdate` on props change.

The `mounted` guard (line 109) is the Flutter equivalent of checking if a component is still mounted before a React `setState`. After an `await`, your widget may have been removed from the tree. Calling `setState` on an unmounted state throws.

---

### Lesson 5 — Async State & the Loading Sentinel Pattern

**File:** `modulor_app/lib/widgets/game_screen.dart` (lines 27, 40–48, 164–170)

Backend async is request/response: you await a result, then do something. Flutter async adds a wrinkle: **the UI is running the whole time**. You need to represent "I'm waiting" as an explicit state.

The pattern used here is a nullable sentinel:
```dart
Puzzle? _puzzle;  // null = loading, non-null = loaded
```

`build()` checks `_puzzle == null` first (line 166) and returns a loading spinner. Once `_loadPuzzle()` completes and calls `setState`, `_puzzle` is non-null, and `build()` renders the game.

This is preferable to a separate `_isLoading` boolean because you can never have an inconsistent state where `_isLoading = false` but `_puzzle` is still null. The nullability *is* the loading state.

For production apps this pattern scales into `AsyncValue` (from the Riverpod package) which adds explicit loading/error/data states — but the underlying idea is identical.

---

## Module 4 — The Widget Toolkit

### Lesson 6 — Composition Over Configuration

**Files:** `modulor_app/lib/widgets/clue_card.dart`, `modulor_app/lib/widgets/clue_strip.dart`, `modulor_app/lib/widgets/game_screen.dart`

In backend code you avoid deep inheritance and prefer composition. Flutter is built entirely on this principle — there are no subclasses of `Button` with dozens of properties. Instead, you compose small widgets.

**The pattern:** props flow down, callbacks bubble up.
- `GameScreen` owns `board` and `tray` state and defines `_onDropToBoard` / `_onDropToTray`.
- It passes the callback *reference* down to `BoardGrid` and `Tray` as constructor parameters.
- `BoardGrid` knows nothing about game rules — it just calls `onDrop(data, index)` when a drop occurs.

This is the same separation of concerns as a service layer calling a repository: the caller owns the data, the callee only knows its contract.

**`_buildHeader()` as a private method** (`game_screen.dart` line 116) is a refactoring step, not a real widget. It keeps `build()` readable but has access to `this` (including `context` and `setState`). Extracting it into a real `StatelessWidget` forces you to define its interface explicitly — better for reuse, slightly more ceremony.

---

### Lesson 7 — Drag & Drop: Typed Generics in the Widget Tree

**Files:** `modulor_app/lib/widgets/board_grid.dart`, `modulor_app/lib/models/drag_data.dart`

`Draggable<T>` and `DragTarget<T>` communicate via a typed payload — the same idea as a typed event bus.

`DragData` (`drag_data.dart`) is the event payload: it carries the piece being dragged, whether it came from the tray or the board, and its source index. The target doesn't need to know *how* the drag started; it just receives a `DragData` and updates state accordingly.

```
Draggable<DragData>  →  (user releases)  →  DragTarget<DragData>.onAcceptWithDetails
```

The three child slots of `Draggable` are worth understanding:
- **`child`** — rendered normally
- **`childWhenDragging`** — replaces `child` while the drag is in progress (shows the empty cell placeholder)
- **`feedback`** — rendered under the user's finger, floating above everything else. Must be wrapped in `Material` to avoid inheriting broken layout constraints from the drag layer.

The hover highlight (`candidateData.isNotEmpty` check on line 49) is purely cosmetic — `builder` receives a list of in-flight drags over this target, which you can use to provide visual affordance.

---

### Lesson 8 — Custom Painting: Retained vs Immediate Mode

**File:** `modulor_app/lib/widgets/piece_widget.dart`

Most UI frameworks expose retained-mode rendering (you create objects, the framework composites them). Flutter's `CustomPainter` drops you into immediate-mode rendering: you have a `Canvas` and you draw commands onto it in `paint()`.

The performance contract is `shouldRepaint()` (line 70): return `true` only if the visual output would actually change. Flutter calls this before every potential repaint. Returning `true` unconditionally is correct but wasteful; returning `false` unconditionally is a subtle bug.

The `Canvas` API maps directly to what graphics APIs expose:
- `drawOval` / `drawRect` — primitive shapes
- `drawPath` — arbitrary geometry via `Path` (moveTo, lineTo, arcTo, close)
- `Paint` — the brush: fill vs stroke, color, stroke width, blend mode

The `pad` calculation (line 48) is the Flutter equivalent of CSS padding inside a fixed-size box — subtract from the rect so the shape doesn't bleed to the edge.

> **Note for the future:** complex UIs composed of many small `CustomPaint` widgets can be expensive. The `RepaintBoundary` widget isolates a subtree into its own layer, so surrounding repaints don't cascade into it.

---

## Module 5 — App Architecture

### Lesson 9 — Navigation: Declarative Routing

**File:** `modulor_app/lib/router.dart`

`GoRouter` is a declarative router — you declare the route tree and the URL-to-screen mapping; the router handles history, deep links, and back navigation. This is the same philosophy as Express/FastAPI route declarations, except the handlers return widgets instead of HTTP responses.

Path parameters (`:setId`, `:levelIndex`) work exactly as in REST APIs. The `state.pathParameters` map is the Flutter equivalent of `request.params` in Express.

`MaterialApp.router` hands control of navigation entirely to the router config. `context.go('/sets')` is a push-with-replace (no back button); `context.push(...)` would add to the history stack.

**`ValueKey` on `GameScreen`** (`router.dart` line 35) solves an important problem: without it, navigating from `/sets/beginner/levels/0/play` to `/sets/beginner/levels/1/play` keeps the same `GameScreen` element alive (same widget type, same position in tree), and Flutter just calls `didUpdateWidget` — meaning `initState` never re-runs and the old game state persists. The `ValueKey` makes the two routes distinct identities, forcing full recreation.

---

### Lesson 10 — Theming: Design Tokens in Code

**Files:** `modulor_app/lib/app_theme.dart`, `modulor_app/lib/main.dart`

`AppColors` (line 3) is a namespace, not a class — it uses a private `_()` constructor to prevent instantiation. All values are `static const`, resolved at compile time. This is the Flutter equivalent of CSS custom properties or a design token system.

Material 3's `ColorScheme.fromSeed` (main.dart line 24) generates a full colour palette from a single seed colour — analogous to Tailwind generating a full colour scale from a base hue. Widgets like `ElevatedButton` automatically pick up colours from the scheme without you specifying them.

Where you need to deviate from the theme locally (e.g., the header title font), override per-widget with an explicit `TextStyle`. The theme is a default, not a constraint.

---

### Lesson 11 — Persistence: Drift as a Type-Safe ORM

**Files:** `modulor_app/lib/data/progress_database.dart`, `modulor_app/lib/data/progress_repository.dart`, `modulor_app/lib/data/app_services.dart`

Drift is a code-generated ORM over SQLite — similar in concept to SQLAlchemy or Prisma, but generating Dart rather than SQL strings.

`progress_database.g.dart` is generated by `build_runner`. You define the schema in `progress_database.dart`; the generator emits type-safe query builders. You never write raw SQL.

**Repository pattern** (`progress_repository.dart`) is the same pattern you'd use in a Spring or Django app: the repository encapsulates all data access logic; consumers (`GameScreen`) call high-level methods like `markSolved(puzzleSet, puzzleId, levelIndex)` and don't know SQLite exists.

**`AppServices`** is a hand-rolled singleton service locator (line 6). It initialises all infrastructure once at startup (`main.dart` line 10) and exposes it via `AppServices.instance`. The `initForTesting()` variant swaps the SQLite file for an in-memory database — the same pattern as using an in-memory H2 database in Spring tests.

For a production app you'd replace this manual singleton with a proper DI container (e.g. `get_it`) or a reactive state management library (Riverpod). The pattern is sound; the wiring is manual.

---

### Lesson 12 — Animations: Explicit Time Control

**File:** `modulor_app/lib/screens/welcome_screen.dart`

Most animation frameworks are implicit ("transition from A to B over 300ms"). Flutter's animation system is explicit: you own the clock (`AnimationController`), you map its 0→1 value to whatever property you want (`CurvedAnimation`, `Tween`), and you attach it to a widget.

`AnimationController` (line 20) is the ticker. `vsync: this` with `SingleTickerProviderStateMixin` ties the ticker to the screen's vsync signal — animations pause when the widget is offscreen, preventing CPU waste.

`CurvedAnimation` (line 24) is a pure function wrapping the controller: `f(t) = curve(t)`. It doesn't tick itself; it just transforms the controller's linear 0→1 into a non-linear easing.

`ScaleTransition` (line 43) is a widget that rebuilds itself on every animation frame and applies the scale to its child. This rebuild is cheap because it happens below a `RepaintBoundary` and only triggers the render layer, not the widget diff.

The `dispose()` call (line 31) is mandatory — `AnimationController` holds a reference to the vsync provider and will leak if not disposed.

---

## How the Modules Fit Together

```
Module 1  Dart nuances that differ from other languages
    ↓
Module 2  How Flutter renders: widget/element/render trees, constraints
    ↓
Module 3  Managing state: local setState, async loading patterns
    ↓
Module 4  The widget toolkit: composition, drag/drop, custom painting
    ↓
Module 5  App-level concerns: routing, theming, persistence, animation
```

Modules 1–3 are the conceptual foundation. If the rendering model and constraint system are clear, most Flutter bugs become obvious. Modules 4–5 are practical — you'll look things up as you need them, but understanding *why* they're designed the way they are makes the docs make sense immediately.
