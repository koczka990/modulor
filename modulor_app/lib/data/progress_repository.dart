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
