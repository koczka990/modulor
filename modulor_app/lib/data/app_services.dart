import 'package:drift/native.dart';
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

  Future<void> initForTesting() async {
    _db = AppDatabase.forTesting(NativeDatabase.memory());
    progress = ProgressRepository(_db);
    puzzles = PuzzleRepository();
  }
}
