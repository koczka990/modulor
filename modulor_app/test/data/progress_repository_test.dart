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
