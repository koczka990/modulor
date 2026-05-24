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
  AppDatabase.forTesting(super.e);

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
