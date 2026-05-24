# Level Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Welcome → Puzzle Set Selector → Level Selector → Game → Completion navigation, backed by a drift SQLite database for progress persistence.

**Architecture:** go_router manages 4 named routes. `PuzzleRepository` loads and caches puzzles from bundled JSON assets. `ProgressRepository` wraps a drift database with a simple solved/attempted API. An `AppServices` singleton holds shared repository instances, initialized in `main()` before `runApp`.

**Tech Stack:** Flutter, go_router ^14.0.0, drift ^2.22.0, sqlite3_flutter_libs ^0.5.0, path_provider ^2.0.0, path ^1.8.0

---

## File Map

**Create:**
- `lib/data/app_services.dart` — singleton holding shared repo instances
- `lib/data/puzzle_repository.dart` — loads + caches puzzles from JSON assets
- `lib/data/progress_database.dart` — drift DB schema
- `lib/data/progress_repository.dart` — facade over drift DB
- `lib/router.dart` — go_router configuration
- `lib/screens/welcome_screen.dart` — splash animation
- `lib/screens/puzzle_set_screen.dart` — set selection tiles
- `lib/screens/level_select_screen.dart` — level grid
- `lib/widgets/completion_overlay.dart` — correct/next level overlay
- `test/data/progress_repository_test.dart`
- `test/data/puzzle_fromjson_test.dart`

**Modify:**
- `lib/models/piece.dart` — rename `PieceColor.green → yellow`; add `fromJson` helpers
- `lib/models/clue.dart` — add `CellReveal.fromJson`, `Clue.fromJson`
- `lib/models/puzzle.dart` — add `id` field; add `Puzzle.fromJson`; update `kHardcodedPuzzle`
- `lib/widgets/piece_widget.dart` — update `PieceColor.green` key to `PieceColor.yellow`
- `lib/widgets/game_screen.dart` — new constructor, async puzzle load, completion overlay
- `lib/main.dart` — async init + MaterialApp.router
- `pubspec.yaml` — add deps, fix asset paths

---

### Task 1: Rename PieceColor.green → PieceColor.yellow

**Files:**
- Modify: `lib/models/piece.dart`
- Modify: `lib/models/puzzle.dart`
- Modify: `lib/widgets/piece_widget.dart`

- [ ] **Step 1: Update `lib/models/piece.dart`**

Replace the enum definition:

```dart
enum PieceColor { red, blue, yellow }
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

- [ ] **Step 2: Update `lib/models/puzzle.dart`**

Replace all occurrences of `PieceColor.green` with `PieceColor.yellow`. Also add `id` field now (required for Task 3). Full file content:

```dart
import 'piece.dart';
import 'clue.dart';

class Puzzle {
  final String id;
  final List<Piece> solution;
  final List<Clue> clues;

  const Puzzle({required this.id, required this.solution, required this.clues});
}

const kHardcodedPuzzle = Puzzle(
  id: 'hardcoded_001',
  solution: [
    Piece(color: PieceColor.red,    shape: PieceShape.circle),
    Piece(color: PieceColor.blue,   shape: PieceShape.square),
    Piece(color: PieceColor.yellow, shape: PieceShape.triangle),
    Piece(color: PieceColor.blue,   shape: PieceShape.circle),
    Piece(color: PieceColor.yellow, shape: PieceShape.square),
    Piece(color: PieceColor.red,    shape: PieceShape.triangle),
    Piece(color: PieceColor.yellow, shape: PieceShape.circle),
    Piece(color: PieceColor.red,    shape: PieceShape.square),
    Piece(color: PieceColor.blue,   shape: PieceShape.triangle),
  ],
  clues: [
    Clue(reveals: [
      CellReveal(row: 0, col: 0, color: PieceColor.red,    shape: PieceShape.circle),
      CellReveal(row: 0, col: 1, color: PieceColor.blue,   shape: PieceShape.square),
    ]),
    Clue(reveals: [
      CellReveal(row: 0, col: 2, color: PieceColor.yellow, shape: PieceShape.triangle),
      CellReveal(row: 1, col: 2, color: PieceColor.red,    shape: PieceShape.triangle),
      CellReveal(row: 2, col: 2, color: PieceColor.blue,   shape: PieceShape.triangle),
    ]),
    Clue(reveals: [
      CellReveal(row: 1, col: 0, color: PieceColor.blue,   shape: PieceShape.circle),
      CellReveal(row: 1, col: 1, color: PieceColor.yellow, shape: PieceShape.square),
    ]),
    Clue(reveals: [
      CellReveal(row: 2, col: 0, color: PieceColor.yellow, shape: PieceShape.circle),
      CellReveal(row: 2, col: 1, color: PieceColor.red,    shape: PieceShape.square),
    ]),
  ],
);
```

- [ ] **Step 3: Update `lib/widgets/piece_widget.dart`**

Change the key in `_fillColors` from `PieceColor.green` to `PieceColor.yellow`:

```dart
static const _fillColors = {
  PieceColor.red:    AppColors.pieceRed,
  PieceColor.blue:   AppColors.pieceBlue,
  PieceColor.yellow: AppColors.pieceYellow,
};
```

- [ ] **Step 4: Verify the app still compiles**

```bash
cd modulor_app && flutter analyze
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add modulor_app/lib/models/piece.dart modulor_app/lib/models/puzzle.dart modulor_app/lib/widgets/piece_widget.dart
git commit -m "fix: rename PieceColor.green to yellow to match actual display color"
```

---

### Task 2: Update pubspec.yaml

**Files:**
- Modify: `modulor_app/pubspec.yaml`

- [ ] **Step 1: Replace the `dependencies` and `dev_dependencies` sections and fix asset paths**

Full updated `pubspec.yaml`:

```yaml
name: modulor_app
description: "A new Flutter project."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.12.0

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1
  go_router: ^14.0.0
  drift: ^2.22.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.0.0
  path: ^1.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  drift_dev: ^2.22.0
  build_runner: ^2.4.0

flutter:
  uses-material-design: true

  assets:
    - assets/puzzles/beginner.json
    - assets/puzzles/intermediate.json
    - assets/puzzles/expert.json
```

- [ ] **Step 2: Fetch dependencies**

```bash
cd modulor_app && flutter pub get
```

Expected: resolves without conflicts.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/pubspec.yaml modulor_app/pubspec.lock
git commit -m "chore: add go_router, drift, path_provider; fix asset paths"
```

---

### Task 3: Add fromJson factories to models

**Files:**
- Modify: `lib/models/piece.dart`
- Modify: `lib/models/clue.dart`
- Modify: `lib/models/puzzle.dart`
- Create: `test/data/puzzle_fromjson_test.dart`

- [ ] **Step 1: Write the failing test**

Create `modulor_app/test/data/puzzle_fromjson_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/models/piece.dart';
import 'package:modulor_app/models/clue.dart';
import 'package:modulor_app/models/puzzle.dart';

void main() {
  group('Piece.fromJson', () {
    test('parses red circle', () {
      final p = Piece.fromJson({'color': 'red', 'shape': 'circle'});
      expect(p.color, PieceColor.red);
      expect(p.shape, PieceShape.circle);
    });

    test('parses yellow triangle', () {
      final p = Piece.fromJson({'color': 'yellow', 'shape': 'triangle'});
      expect(p.color, PieceColor.yellow);
      expect(p.shape, PieceShape.triangle);
    });

    test('parses blue square', () {
      final p = Piece.fromJson({'color': 'blue', 'shape': 'square'});
      expect(p.color, PieceColor.blue);
      expect(p.shape, PieceShape.square);
    });
  });

  group('CellReveal.fromJson', () {
    test('parses full reveal', () {
      final cr = CellReveal.fromJson({'r': 1, 'c': 2, 'color': 'blue', 'shape': 'circle'});
      expect(cr.row, 1);
      expect(cr.col, 2);
      expect(cr.color, PieceColor.blue);
      expect(cr.shape, PieceShape.circle);
    });

    test('parses empty cell (no color or shape)', () {
      final cr = CellReveal.fromJson({'r': 0, 'c': 0});
      expect(cr.color, isNull);
      expect(cr.shape, isNull);
    });
  });

  group('Puzzle.fromJson', () {
    test('parses id, solution, and clues', () {
      final json = {
        'id': 'easy_001',
        'solution': [
          {'color': 'red', 'shape': 'circle'},
          {'color': 'blue', 'shape': 'square'},
          {'color': 'yellow', 'shape': 'triangle'},
          {'color': 'blue', 'shape': 'circle'},
          {'color': 'yellow', 'shape': 'square'},
          {'color': 'red', 'shape': 'triangle'},
          {'color': 'yellow', 'shape': 'circle'},
          {'color': 'red', 'shape': 'square'},
          {'color': 'blue', 'shape': 'triangle'},
        ],
        'clues': [
          {
            'cells': [
              {'r': 0, 'c': 0, 'color': 'red', 'shape': 'circle'},
              {'r': 0, 'c': 1},
            ]
          }
        ],
      };
      final puzzle = Puzzle.fromJson(json);
      expect(puzzle.id, 'easy_001');
      expect(puzzle.solution.length, 9);
      expect(puzzle.solution[0].color, PieceColor.red);
      expect(puzzle.clues.length, 1);
      expect(puzzle.clues[0].reveals.length, 2);
      expect(puzzle.clues[0].reveals[0].color, PieceColor.red);
      expect(puzzle.clues[0].reveals[1].color, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd modulor_app && flutter test test/data/puzzle_fromjson_test.dart
```

Expected: FAIL — `fromJson` methods not defined.

- [ ] **Step 3: Add `fromJson` to `lib/models/piece.dart`**

```dart
enum PieceColor { red, blue, yellow }
enum PieceShape { circle, square, triangle }

class Piece {
  final PieceColor color;
  final PieceShape shape;

  const Piece({required this.color, required this.shape});

  factory Piece.fromJson(Map<String, dynamic> json) {
    return Piece(
      color: _colorFromJson(json['color'] as String),
      shape: _shapeFromJson(json['shape'] as String),
    );
  }

  static PieceColor _colorFromJson(String s) => switch (s) {
        'red'    => PieceColor.red,
        'blue'   => PieceColor.blue,
        'yellow' => PieceColor.yellow,
        _        => throw ArgumentError('Unknown color: $s'),
      };

  static PieceShape _shapeFromJson(String s) => switch (s) {
        'circle'   => PieceShape.circle,
        'square'   => PieceShape.square,
        'triangle' => PieceShape.triangle,
        _          => throw ArgumentError('Unknown shape: $s'),
      };

  @override
  bool operator ==(Object other) =>
      other is Piece && other.color == color && other.shape == shape;

  @override
  int get hashCode => Object.hash(color, shape);
}
```

- [ ] **Step 4: Add `fromJson` to `lib/models/clue.dart`**

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

  factory CellReveal.fromJson(Map<String, dynamic> json) {
    return CellReveal(
      row: json['r'] as int,
      col: json['c'] as int,
      color: json['color'] != null
          ? Piece._colorFromJson(json['color'] as String)
          : null,
      shape: json['shape'] != null
          ? Piece._shapeFromJson(json['shape'] as String)
          : null,
    );
  }
}

class Clue {
  final List<CellReveal> reveals;
  const Clue({required this.reveals});

  factory Clue.fromJson(Map<String, dynamic> json) {
    final cells = (json['cells'] as List)
        .map((c) => CellReveal.fromJson(c as Map<String, dynamic>))
        .where((cr) => cr.color != null || cr.shape != null)
        .toList();
    return Clue(reveals: cells);
  }
}
```

Note: `_colorFromJson` and `_shapeFromJson` are private static methods on `Piece`. Make them package-private by moving them to a helper or making them internal. Simpler: make them top-level private functions in `piece.dart` and import them in `clue.dart`. Actually the cleanest approach without exposing internals is to duplicate the switch or expose them as `static` with a non-underscore name. Update `piece.dart` to expose them as `static` (non-private):

Update `lib/models/piece.dart` — change `_colorFromJson` and `_shapeFromJson` to `colorFromJson` and `shapeFromJson` (remove underscore):

```dart
enum PieceColor { red, blue, yellow }
enum PieceShape { circle, square, triangle }

class Piece {
  final PieceColor color;
  final PieceShape shape;

  const Piece({required this.color, required this.shape});

  factory Piece.fromJson(Map<String, dynamic> json) {
    return Piece(
      color: colorFromJson(json['color'] as String),
      shape: shapeFromJson(json['shape'] as String),
    );
  }

  static PieceColor colorFromJson(String s) => switch (s) {
        'red'    => PieceColor.red,
        'blue'   => PieceColor.blue,
        'yellow' => PieceColor.yellow,
        _        => throw ArgumentError('Unknown color: $s'),
      };

  static PieceShape shapeFromJson(String s) => switch (s) {
        'circle'   => PieceShape.circle,
        'square'   => PieceShape.square,
        'triangle' => PieceShape.triangle,
        _          => throw ArgumentError('Unknown shape: $s'),
      };

  @override
  bool operator ==(Object other) =>
      other is Piece && other.color == color && other.shape == shape;

  @override
  int get hashCode => Object.hash(color, shape);
}
```

Then `lib/models/clue.dart`:

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

  factory CellReveal.fromJson(Map<String, dynamic> json) {
    return CellReveal(
      row: json['r'] as int,
      col: json['c'] as int,
      color: json['color'] != null
          ? Piece.colorFromJson(json['color'] as String)
          : null,
      shape: json['shape'] != null
          ? Piece.shapeFromJson(json['shape'] as String)
          : null,
    );
  }
}

class Clue {
  final List<CellReveal> reveals;
  const Clue({required this.reveals});

  factory Clue.fromJson(Map<String, dynamic> json) {
    final cells = (json['cells'] as List)
        .map((c) => CellReveal.fromJson(c as Map<String, dynamic>))
        .where((cr) => cr.color != null || cr.shape != null)
        .toList();
    return Clue(reveals: cells);
  }
}
```

- [ ] **Step 5: Add `fromJson` to `lib/models/puzzle.dart`**

Add the factory to the Puzzle class (the rest of the file was updated in Task 1):

```dart
import 'dart:convert';
import 'piece.dart';
import 'clue.dart';

class Puzzle {
  final String id;
  final List<Piece> solution;
  final List<Clue> clues;

  const Puzzle({required this.id, required this.solution, required this.clues});

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'] as String,
      solution: (json['solution'] as List)
          .map((p) => Piece.fromJson(p as Map<String, dynamic>))
          .toList(),
      clues: (json['clues'] as List)
          .map((c) => Clue.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

const kHardcodedPuzzle = Puzzle(
  id: 'hardcoded_001',
  solution: [
    Piece(color: PieceColor.red,    shape: PieceShape.circle),
    Piece(color: PieceColor.blue,   shape: PieceShape.square),
    Piece(color: PieceColor.yellow, shape: PieceShape.triangle),
    Piece(color: PieceColor.blue,   shape: PieceShape.circle),
    Piece(color: PieceColor.yellow, shape: PieceShape.square),
    Piece(color: PieceColor.red,    shape: PieceShape.triangle),
    Piece(color: PieceColor.yellow, shape: PieceShape.circle),
    Piece(color: PieceColor.red,    shape: PieceShape.square),
    Piece(color: PieceColor.blue,   shape: PieceShape.triangle),
  ],
  clues: [
    Clue(reveals: [
      CellReveal(row: 0, col: 0, color: PieceColor.red,    shape: PieceShape.circle),
      CellReveal(row: 0, col: 1, color: PieceColor.blue,   shape: PieceShape.square),
    ]),
    Clue(reveals: [
      CellReveal(row: 0, col: 2, color: PieceColor.yellow, shape: PieceShape.triangle),
      CellReveal(row: 1, col: 2, color: PieceColor.red,    shape: PieceShape.triangle),
      CellReveal(row: 2, col: 2, color: PieceColor.blue,   shape: PieceShape.triangle),
    ]),
    Clue(reveals: [
      CellReveal(row: 1, col: 0, color: PieceColor.blue,   shape: PieceShape.circle),
      CellReveal(row: 1, col: 1, color: PieceColor.yellow, shape: PieceShape.square),
    ]),
    Clue(reveals: [
      CellReveal(row: 2, col: 0, color: PieceColor.yellow, shape: PieceShape.circle),
      CellReveal(row: 2, col: 1, color: PieceColor.red,    shape: PieceShape.square),
    ]),
  ],
);
```

- [ ] **Step 6: Run test to verify it passes**

```bash
cd modulor_app && flutter test test/data/puzzle_fromjson_test.dart
```

Expected: all tests PASS.

- [ ] **Step 7: Commit**

```bash
git add modulor_app/lib/models/ modulor_app/test/
git commit -m "feat: add fromJson factories to Piece, CellReveal, Clue, Puzzle"
```

---

### Task 4: Create PuzzleRepository

**Files:**
- Create: `lib/data/puzzle_repository.dart`

- [ ] **Step 1: Create `lib/data/puzzle_repository.dart`**

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/puzzle.dart';

class PuzzleRepository {
  final Map<String, List<Puzzle>> _cache = {};

  Future<List<Puzzle>> loadSet(String setId) async {
    if (_cache.containsKey(setId)) return _cache[setId]!;

    final jsonStr = await rootBundle.loadString('assets/puzzles/$setId.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final puzzles = (data['puzzles'] as List)
        .map((p) => Puzzle.fromJson(p as Map<String, dynamic>))
        .toList();
    _cache[setId] = puzzles;
    return puzzles;
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd modulor_app && flutter analyze lib/data/puzzle_repository.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/data/puzzle_repository.dart
git commit -m "feat: add PuzzleRepository for loading puzzles from JSON assets"
```

---

### Task 5: Create drift database schema

**Files:**
- Create: `lib/data/progress_database.dart`

- [ ] **Step 1: Create `lib/data/progress_database.dart`**

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'progress_database.g.dart';

class PuzzleAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get puzzleSet => text()();
  TextColumn get puzzleId => text()();
  IntColumn get levelIndex => integer()();
  IntColumn get solvedAt => integer().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(1))();
}

@DriftDatabase(tables: [PuzzleAttempts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'modulor.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

- [ ] **Step 2: Run build_runner to generate the `.g.dart` file**

```bash
cd modulor_app && dart run build_runner build --delete-conflicting-outputs
```

Expected: creates `lib/data/progress_database.g.dart`. No errors.

- [ ] **Step 3: Verify compilation**

```bash
flutter analyze lib/data/progress_database.dart
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add modulor_app/lib/data/progress_database.dart modulor_app/lib/data/progress_database.g.dart
git commit -m "feat: add drift database schema for puzzle progress tracking"
```

---

### Task 6: Create ProgressRepository

**Files:**
- Create: `lib/data/progress_repository.dart`
- Create: `test/data/progress_repository_test.dart`

- [ ] **Step 1: Write the failing test**

Create `modulor_app/test/data/progress_repository_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modulor_app/data/progress_database.dart';
import 'package:modulor_app/data/progress_repository.dart';

void main() {
  late AppDatabase db;
  late ProgressRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProgressRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('completedIds returns empty set when no progress', () async {
    final ids = await repo.completedIds('beginner');
    expect(ids, isEmpty);
  });

  test('markSolved adds puzzle to completedIds', () async {
    await repo.markSolved('beginner', 'easy_001', 0);
    final ids = await repo.completedIds('beginner');
    expect(ids, {'easy_001'});
  });

  test('isSolved returns true after markSolved', () async {
    await repo.markSolved('beginner', 'easy_001', 0);
    expect(await repo.isSolved('beginner', 'easy_001'), isTrue);
  });

  test('isSolved returns false for different puzzle set', () async {
    await repo.markSolved('beginner', 'easy_001', 0);
    expect(await repo.isSolved('intermediate', 'easy_001'), isFalse);
  });

  test('completedIds is scoped to puzzle set', () async {
    await repo.markSolved('beginner', 'easy_001', 0);
    final ids = await repo.completedIds('intermediate');
    expect(ids, isEmpty);
  });

  test('markSolved is idempotent — does not duplicate entries', () async {
    await repo.markSolved('beginner', 'easy_001', 0);
    await repo.markSolved('beginner', 'easy_001', 0);
    final ids = await repo.completedIds('beginner');
    expect(ids.length, 1);
  });

  test('can mark multiple puzzles solved independently', () async {
    await repo.markSolved('beginner', 'easy_001', 0);
    await repo.markSolved('beginner', 'easy_002', 1);
    final ids = await repo.completedIds('beginner');
    expect(ids, {'easy_001', 'easy_002'});
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd modulor_app && flutter test test/data/progress_repository_test.dart
```

Expected: FAIL — `ProgressRepository` not defined.

- [ ] **Step 3: Create `lib/data/progress_repository.dart`**

```dart
import 'package:drift/drift.dart';
import 'progress_database.dart';

class ProgressRepository {
  final AppDatabase _db;

  ProgressRepository(this._db);

  Future<Set<String>> completedIds(String puzzleSet) async {
    final rows = await (_db.select(_db.puzzleAttempts)
          ..where((t) => t.puzzleSet.equals(puzzleSet) & t.solvedAt.isNotNull()))
        .get();
    return rows.map((r) => r.puzzleId).toSet();
  }

  Future<bool> isSolved(String puzzleSet, String puzzleId) async {
    final row = await (_db.select(_db.puzzleAttempts)
          ..where((t) =>
              t.puzzleSet.equals(puzzleSet) &
              t.puzzleId.equals(puzzleId) &
              t.solvedAt.isNotNull()))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> markSolved(String puzzleSet, String puzzleId, int levelIndex) async {
    final existing = await (_db.select(_db.puzzleAttempts)
          ..where((t) =>
              t.puzzleSet.equals(puzzleSet) & t.puzzleId.equals(puzzleId)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.puzzleAttempts).insert(PuzzleAttemptsCompanion.insert(
        puzzleSet: puzzleSet,
        puzzleId: puzzleId,
        levelIndex: levelIndex,
        solvedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
    } else if (existing.solvedAt == null) {
      await (_db.update(_db.puzzleAttempts)
            ..where((t) => t.id.equals(existing.id)))
          .write(PuzzleAttemptsCompanion(
        solvedAt: Value(DateTime.now().millisecondsSinceEpoch),
        attempts: Value(existing.attempts + 1),
      ));
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd modulor_app && flutter test test/data/progress_repository_test.dart
```

Expected: all 7 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add modulor_app/lib/data/progress_repository.dart modulor_app/test/data/progress_repository_test.dart
git commit -m "feat: add ProgressRepository with drift-backed puzzle progress tracking"
```

---

### Task 7: Create AppServices and initialize in main.dart

**Files:**
- Create: `lib/data/app_services.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Create `lib/data/app_services.dart`**

```dart
import 'progress_database.dart';
import 'progress_repository.dart';
import 'puzzle_repository.dart';

class AppServices {
  static final AppServices instance = AppServices._();
  AppServices._();

  late final AppDatabase _db;
  late final ProgressRepository progress;
  late final PuzzleRepository puzzles;

  Future<void> init() async {
    _db = AppDatabase();
    progress = ProgressRepository(_db);
    puzzles = PuzzleRepository();
  }
}
```

- [ ] **Step 2: Update `lib/main.dart`** to initialize services and use `MaterialApp.router` (router will be wired in Task 8; for now keep `home` as a placeholder to keep the app runnable):

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'data/app_services.dart';
import 'models/puzzle.dart';
import 'widgets/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppServices.instance.init();
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

- [ ] **Step 3: Verify compilation**

```bash
cd modulor_app && flutter analyze
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add modulor_app/lib/data/app_services.dart modulor_app/lib/main.dart
git commit -m "feat: add AppServices singleton and async initialization in main"
```

---

### Task 8: Create router and wire MaterialApp.router

**Files:**
- Create: `lib/router.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Create `lib/router.dart`**

```dart
import 'package:go_router/go_router.dart';

import 'screens/welcome_screen.dart';
import 'screens/puzzle_set_screen.dart';
import 'screens/level_select_screen.dart';
import 'widgets/game_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/sets',
      builder: (context, state) => const PuzzleSetScreen(),
    ),
    GoRoute(
      path: '/sets/:setId/levels',
      builder: (context, state) => LevelSelectScreen(
        setId: state.pathParameters['setId']!,
      ),
    ),
    GoRoute(
      path: '/sets/:setId/levels/:levelIndex/play',
      builder: (context, state) => GameScreen(
        setId: state.pathParameters['setId']!,
        levelIndex: int.parse(state.pathParameters['levelIndex']!),
      ),
    ),
  ],
);
```

Note: `WelcomeScreen`, `PuzzleSetScreen`, `LevelSelectScreen`, and the new `GameScreen` signature are referenced here before they exist. Create stub files for the screens now so the router compiles.

- [ ] **Step 2: Create stub `lib/screens/welcome_screen.dart`**

```dart
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Welcome')));
  }
}
```

- [ ] **Step 3: Create stub `lib/screens/puzzle_set_screen.dart`**

```dart
import 'package:flutter/material.dart';

class PuzzleSetScreen extends StatelessWidget {
  const PuzzleSetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Puzzle Sets')));
  }
}
```

- [ ] **Step 4: Create stub `lib/screens/level_select_screen.dart`**

```dart
import 'package:flutter/material.dart';

class LevelSelectScreen extends StatelessWidget {
  final String setId;
  const LevelSelectScreen({super.key, required this.setId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Levels: $setId')));
  }
}
```

- [ ] **Step 5: Update `GameScreen` constructor signature to accept `setId` + `levelIndex`**

`GameScreen` currently takes `puzzle: Puzzle`. Change it to accept the new params while keeping it compilable (it will still use the hardcoded puzzle internally for now — full implementation in Task 13).

In `lib/widgets/game_screen.dart`, change the constructor:

```dart
class GameScreen extends StatefulWidget {
  final String setId;
  final int levelIndex;

  const GameScreen({super.key, required this.setId, required this.levelIndex});

  @override
  State<GameScreen> createState() => _GameScreenState();
}
```

And in `_GameScreenState`, temporarily hardcode the puzzle:

```dart
@override
void initState() {
  super.initState();
  board = List<Piece?>.filled(9, null, growable: false);
  tray = List<Piece?>.from(kHardcodedPuzzle.solution);
}
```

Update `_checkSolution` to reference `kHardcodedPuzzle` temporarily:

```dart
void _checkSolution() {
  final solution = kHardcodedPuzzle.solution;
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
```

Update `build` to reference `kHardcodedPuzzle.clues`:

```dart
ClueStrip(clues: kHardcodedPuzzle.clues),
```

Also update the `_reset` method:

```dart
void _reset() {
  setState(() {
    board = List<Piece?>.filled(9, null, growable: false);
    tray = List<Piece?>.from(kHardcodedPuzzle.solution);
  });
}
```

- [ ] **Step 6: Wire `MaterialApp.router` in `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'data/app_services.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppServices.instance.init();
  runApp(const ModulorApp());
}

class ModulorApp extends StatelessWidget {
  const ModulorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Modulor',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.archivoNarrowTextTheme(),
        useMaterial3: true,
      ),
    );
  }
}
```

- [ ] **Step 7: Verify the app runs** (should show Welcome stub screen)

```bash
cd modulor_app && flutter analyze
```

Expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add modulor_app/lib/router.dart modulor_app/lib/main.dart modulor_app/lib/screens/ modulor_app/lib/widgets/game_screen.dart
git commit -m "feat: add go_router with 4 routes; stub screens; wire MaterialApp.router"
```

---

### Task 9: Implement WelcomeScreen

**Files:**
- Modify: `lib/screens/welcome_screen.dart`

- [ ] **Step 1: Replace the stub with the full implementation**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) context.go('/sets');
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 80,
            height: 80,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd modulor_app && flutter analyze lib/screens/welcome_screen.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/screens/welcome_screen.dart
git commit -m "feat: implement WelcomeScreen with scale animation"
```

---

### Task 10: Implement PuzzleSetScreen

**Files:**
- Modify: `lib/screens/puzzle_set_screen.dart`

- [ ] **Step 1: Replace the stub with the full implementation**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../data/app_services.dart';

class PuzzleSetScreen extends StatelessWidget {
  const PuzzleSetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PUZZLE SETS',
                    style: TextStyle(
                      fontFamily: 'Archivo Narrow',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 2, color: AppColors.ink),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, (int, int)>>(
                future: _loadProgress(),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? {};
                  return _SetGrid(progressData: data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, (int, int)>> _loadProgress() async {
    const sets = ['beginner', 'intermediate', 'expert'];
    final result = <String, (int, int)>{};
    for (final setId in sets) {
      final puzzles = await AppServices.instance.puzzles.loadSet(setId);
      final completed = await AppServices.instance.progress.completedIds(setId);
      result[setId] = (completed.length, puzzles.length);
    }
    return result;
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.ink, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: null,
          ),
          Text(
            'MODULOR',
            style: TextStyle(
              fontFamily: 'Archivo Narrow',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

class _SetGrid extends StatelessWidget {
  final Map<String, (int, int)> progressData;

  const _SetGrid({required this.progressData});

  static const _sets = [
    _SetConfig(
      id: 'beginner',
      label: 'BEGINNER',
      bgColor: AppColors.secondaryContainer,
      fgColor: AppColors.ink,
      icon: Icons.change_history,
    ),
    _SetConfig(
      id: 'intermediate',
      label: 'INTERMEDIATE',
      bgColor: AppColors.tertiaryContainer,
      fgColor: Colors.white,
      icon: Icons.square_outlined,
    ),
    _SetConfig(
      id: 'expert',
      label: 'EXPERT',
      bgColor: AppColors.primary,
      fgColor: Colors.white,
      icon: Icons.category_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: _sets.map((cfg) {
          final (completed, total) = progressData[cfg.id] ?? (0, 0);
          return _SetTile(
            config: cfg,
            completed: completed,
            total: total,
            onTap: () => context.go('/sets/${cfg.id}/levels'),
          );
        }).toList(),
      ),
    );
  }
}

class _SetConfig {
  final String id;
  final String label;
  final Color bgColor;
  final Color fgColor;
  final IconData icon;

  const _SetConfig({
    required this.id,
    required this.label,
    required this.bgColor,
    required this.fgColor,
    required this.icon,
  });
}

class _SetTile extends StatelessWidget {
  final _SetConfig config;
  final int completed;
  final int total;
  final VoidCallback onTap;

  const _SetTile({
    required this.config,
    required this.completed,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: config.bgColor,
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  config.label,
                  style: TextStyle(
                    fontFamily: 'Archivo Narrow',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: config.fgColor,
                  ),
                ),
                Icon(config.icon, color: config.fgColor, size: 32),
              ],
            ),
            const Spacer(),
            Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.ink, width: 2),
                color: AppColors.background,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$completed/$total SOLVED',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: config.fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Note: `AppColors.tertiaryContainer` needs to be added to `app_theme.dart` if it doesn't exist. Check and add:
```dart
static const tertiaryContainer = Color(0xFF007EA4);
```
It already exists in `app_theme.dart` as shown in the existing file.

- [ ] **Step 2: Verify compilation**

```bash
cd modulor_app && flutter analyze lib/screens/puzzle_set_screen.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/screens/puzzle_set_screen.dart
git commit -m "feat: implement PuzzleSetScreen with set tiles and progress bars"
```

---

### Task 11: Implement LevelSelectScreen

**Files:**
- Modify: `lib/screens/level_select_screen.dart`

- [ ] **Step 1: Replace the stub with the full implementation**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../data/app_services.dart';
import '../models/puzzle.dart';

enum _LevelState { completed, current, locked }

class LevelSelectScreen extends StatelessWidget {
  final String setId;

  const LevelSelectScreen({super.key, required this.setId});

  String get _setLabel => switch (setId) {
        'beginner'     => 'BEGINNER',
        'intermediate' => 'INTERMEDIATE',
        'expert'       => 'EXPERT',
        _              => setId.toUpperCase(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppBar(setId: setId),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LEVELS',
                        style: const TextStyle(
                          fontFamily: 'Archivo Narrow',
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        _setLabel,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(height: 2, color: AppColors.ink),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<(List<Puzzle>, Set<String>)>(
                future: _loadData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final (puzzles, completed) = snapshot.data!;
                  return _LevelGrid(
                    puzzles: puzzles,
                    completed: completed,
                    setId: setId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<(List<Puzzle>, Set<String>)> _loadData() async {
    final puzzles = await AppServices.instance.puzzles.loadSet(setId);
    final completed = await AppServices.instance.progress.completedIds(setId);
    return (puzzles, completed);
  }
}

class _AppBar extends StatelessWidget {
  final String setId;
  const _AppBar({required this.setId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.ink, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => context.go('/sets'),
          ),
          Text(
            'MODULOR',
            style: const TextStyle(
              fontFamily: 'Archivo Narrow',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final List<Puzzle> puzzles;
  final Set<String> completed;
  final String setId;

  static const _completedColors = [
    AppColors.primary,
    AppColors.secondaryContainer,
    AppColors.tertiaryContainer,
  ];

  const _LevelGrid({
    required this.puzzles,
    required this.completed,
    required this.setId,
  });

  _LevelState _stateFor(int index) {
    final isCompleted = completed.contains(puzzles[index].id);
    if (isCompleted) return _LevelState.completed;
    final isUnlocked = index == 0 || completed.contains(puzzles[index - 1].id);
    if (!isUnlocked) return _LevelState.locked;
    return _LevelState.current;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: puzzles.length,
      itemBuilder: (context, index) {
        final state = _stateFor(index);
        return _LevelCell(
          index: index,
          state: state,
          completedColor: _completedColors[index % 3],
          onTap: state != _LevelState.locked
              ? () => context.go('/sets/$setId/levels/$index/play')
              : null,
        );
      },
    );
  }
}

class _LevelCell extends StatelessWidget {
  final int index;
  final _LevelState state;
  final Color completedColor;
  final VoidCallback? onTap;

  const _LevelCell({
    required this.index,
    required this.state,
    required this.completedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = (index + 1).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _bgColor,
          border: Border.all(color: AppColors.ink, width: 2),
          boxShadow: state == _LevelState.current
              ? [BoxShadow(color: AppColors.primary, spreadRadius: 2, blurRadius: 0)]
              : null,
        ),
        child: Opacity(
          opacity: state == _LevelState.locked ? 0.6 : 1.0,
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 8,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Archivo Narrow',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Center(child: _centerIcon),
              Positioned(
                bottom: 8,
                right: 8,
                child: _Dots(filled: state == _LevelState.completed ? 3 : 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _bgColor => switch (state) {
        _LevelState.completed => completedColor,
        _LevelState.current   => AppColors.background,
        _LevelState.locked    => const Color(0xFFE1E3E4),
      };

  Widget? get _centerIcon => switch (state) {
        _LevelState.current => const Icon(
            Icons.play_arrow,
            color: AppColors.ink,
            size: 40,
          ),
        _LevelState.locked => const Icon(
            Icons.lock_outline,
            color: AppColors.ink,
            size: 28,
          ),
        _LevelState.completed => null,
      };
}

class _Dots extends StatelessWidget {
  final int filled;

  const _Dots({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: i < filled ? AppColors.ink : Colors.transparent,
            border: Border.all(color: AppColors.ink, width: 1),
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 2: Verify compilation**

```bash
cd modulor_app && flutter analyze lib/screens/level_select_screen.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/screens/level_select_screen.dart
git commit -m "feat: implement LevelSelectScreen with sequential unlock logic"
```

---

### Task 12: Create CompletionOverlay

**Files:**
- Create: `lib/widgets/completion_overlay.dart`

- [ ] **Step 1: Create `lib/widgets/completion_overlay.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';

class CompletionOverlay extends StatelessWidget {
  final String setId;
  final int levelIndex;
  final bool showNextButton;

  const CompletionOverlay({
    super.key,
    required this.setId,
    required this.levelIndex,
    required this.showNextButton,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CORRECT!',
                style: TextStyle(
                  fontFamily: 'Archivo Narrow',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/sets'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.ink, width: 2),
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'BACK TO MENU',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              if (showNextButton) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go(
                      '/sets/$setId/levels/${levelIndex + 1}/play',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'NEXT LEVEL',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify compilation**

```bash
cd modulor_app && flutter analyze lib/widgets/completion_overlay.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add modulor_app/lib/widgets/completion_overlay.dart
git commit -m "feat: add CompletionOverlay with back-to-menu and next-level buttons"
```

---

### Task 13: Refactor GameScreen with async puzzle loading and completion flow

**Files:**
- Modify: `lib/widgets/game_screen.dart`

- [ ] **Step 1: Replace the full contents of `lib/widgets/game_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../data/app_services.dart';
import '../models/drag_data.dart';
import '../models/piece.dart';
import '../models/puzzle.dart';
import 'board_grid.dart';
import 'clue_strip.dart';
import 'completion_overlay.dart';
import 'tray.dart';

class GameScreen extends StatefulWidget {
  final String setId;
  final int levelIndex;

  const GameScreen({super.key, required this.setId, required this.levelIndex});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Puzzle? _puzzle;
  late List<Piece?> board;
  late List<Piece?> tray;
  bool _showOverlay = false;
  bool _showNextButton = false;

  @override
  void initState() {
    super.initState();
    board = List<Piece?>.filled(9, null, growable: false);
    tray = [];
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    final puzzles =
        await AppServices.instance.puzzles.loadSet(widget.setId);
    final puzzle = puzzles[widget.levelIndex];
    setState(() {
      _puzzle = puzzle;
      board = List<Piece?>.filled(9, null, growable: false);
      tray = List<Piece?>.from(puzzle.solution);
    });
  }

  void _reset() {
    if (_puzzle == null) return;
    setState(() {
      board = List<Piece?>.filled(9, null, growable: false);
      tray = List<Piece?>.from(_puzzle!.solution);
      _showOverlay = false;
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

  Future<void> _checkSolution() async {
    final puzzle = _puzzle;
    if (puzzle == null) return;

    final correct =
        List.generate(9, (i) => board[i] == puzzle.solution[i]).every((b) => b);
    if (!correct) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not quite, keep trying.'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    await AppServices.instance.progress
        .markSolved(widget.setId, puzzle.id, widget.levelIndex);

    final puzzles = await AppServices.instance.puzzles.loadSet(widget.setId);
    final nextIndex = widget.levelIndex + 1;
    final hasNext = nextIndex < puzzles.length;
    final nextAlreadySolved = hasNext &&
        await AppServices.instance.progress
            .isSolved(widget.setId, puzzles[nextIndex].id);

    if (!mounted) return;
    setState(() {
      _showOverlay = true;
      _showNextButton = hasNext && !nextAlreadySolved;
    });
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
              const PopupMenuItem(value: 'restart', child: Text('Restart')),
              const PopupMenuItem(
                  value: 'menu', enabled: false, child: Text('Back to Menu')),
              const PopupMenuItem(
                  value: 'settings', enabled: false, child: Text('Settings')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_puzzle == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isBoardFull = board.every((p) => p != null);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                ClueStrip(clues: _puzzle!.clues),
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
                    onCheck: () => _checkSolution(),
                  ),
                ),
              ],
            ),
            if (_showOverlay)
              Positioned.fill(
                child: CompletionOverlay(
                  setId: widget.setId,
                  levelIndex: widget.levelIndex,
                  showNextButton: _showNextButton,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify full project compiles**

```bash
cd modulor_app && flutter analyze
```

Expected: no errors.

- [ ] **Step 3: Run all tests**

```bash
cd modulor_app && flutter test
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
git add modulor_app/lib/widgets/game_screen.dart
git commit -m "feat: refactor GameScreen to load puzzle from repo and show CompletionOverlay"
```

---

## Self-review

**Spec coverage check:**

| Spec requirement | Task |
|---|---|
| Rename PieceColor.green → yellow | Task 1 |
| Add go_router, drift, deps | Task 2 |
| fromJson factories on all models | Task 3 |
| PuzzleRepository loading/caching | Task 4 |
| Drift schema with puzzle_attempts | Task 5 |
| ProgressRepository API | Task 6 |
| AppServices singleton | Task 7 |
| router.dart with 4 routes | Task 8 |
| WelcomeScreen animation | Task 9 |
| PuzzleSetScreen with progress | Task 10 |
| LevelSelectScreen with unlock logic | Task 11 |
| CompletionOverlay | Task 12 |
| GameScreen refactor | Task 13 |
| Fix pubspec asset paths | Task 2 |
| Correct → mark solved → overlay → next/menu | Task 13 |
| Next level edge case (already solved) | Task 13 |

All spec requirements covered. ✓
