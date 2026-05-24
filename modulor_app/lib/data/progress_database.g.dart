// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_database.dart';

// ignore_for_file: type=lint
class $PuzzleAttemptsTable extends PuzzleAttempts
    with TableInfo<$PuzzleAttemptsTable, PuzzleAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PuzzleAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _puzzleSetMeta = const VerificationMeta(
    'puzzleSet',
  );
  @override
  late final GeneratedColumn<String> puzzleSet = GeneratedColumn<String>(
    'puzzle_set',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _puzzleIdMeta = const VerificationMeta(
    'puzzleId',
  );
  @override
  late final GeneratedColumn<String> puzzleId = GeneratedColumn<String>(
    'puzzle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelIndexMeta = const VerificationMeta(
    'levelIndex',
  );
  @override
  late final GeneratedColumn<int> levelIndex = GeneratedColumn<int>(
    'level_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _solvedAtMeta = const VerificationMeta(
    'solvedAt',
  );
  @override
  late final GeneratedColumn<int> solvedAt = GeneratedColumn<int>(
    'solved_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    puzzleSet,
    puzzleId,
    levelIndex,
    solvedAt,
    attempts,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'puzzle_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PuzzleAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('puzzle_set')) {
      context.handle(
        _puzzleSetMeta,
        puzzleSet.isAcceptableOrUnknown(data['puzzle_set']!, _puzzleSetMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleSetMeta);
    }
    if (data.containsKey('puzzle_id')) {
      context.handle(
        _puzzleIdMeta,
        puzzleId.isAcceptableOrUnknown(data['puzzle_id']!, _puzzleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleIdMeta);
    }
    if (data.containsKey('level_index')) {
      context.handle(
        _levelIndexMeta,
        levelIndex.isAcceptableOrUnknown(data['level_index']!, _levelIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_levelIndexMeta);
    }
    if (data.containsKey('solved_at')) {
      context.handle(
        _solvedAtMeta,
        solvedAt.isAcceptableOrUnknown(data['solved_at']!, _solvedAtMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PuzzleAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PuzzleAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      puzzleSet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}puzzle_set'],
      )!,
      puzzleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}puzzle_id'],
      )!,
      levelIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_index'],
      )!,
      solvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}solved_at'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
    );
  }

  @override
  $PuzzleAttemptsTable createAlias(String alias) {
    return $PuzzleAttemptsTable(attachedDatabase, alias);
  }
}

class PuzzleAttempt extends DataClass implements Insertable<PuzzleAttempt> {
  final int id;
  final String puzzleSet;
  final String puzzleId;
  final int levelIndex;
  final int? solvedAt;
  final int attempts;
  const PuzzleAttempt({
    required this.id,
    required this.puzzleSet,
    required this.puzzleId,
    required this.levelIndex,
    this.solvedAt,
    required this.attempts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['puzzle_set'] = Variable<String>(puzzleSet);
    map['puzzle_id'] = Variable<String>(puzzleId);
    map['level_index'] = Variable<int>(levelIndex);
    if (!nullToAbsent || solvedAt != null) {
      map['solved_at'] = Variable<int>(solvedAt);
    }
    map['attempts'] = Variable<int>(attempts);
    return map;
  }

  PuzzleAttemptsCompanion toCompanion(bool nullToAbsent) {
    return PuzzleAttemptsCompanion(
      id: Value(id),
      puzzleSet: Value(puzzleSet),
      puzzleId: Value(puzzleId),
      levelIndex: Value(levelIndex),
      solvedAt: solvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(solvedAt),
      attempts: Value(attempts),
    );
  }

  factory PuzzleAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PuzzleAttempt(
      id: serializer.fromJson<int>(json['id']),
      puzzleSet: serializer.fromJson<String>(json['puzzleSet']),
      puzzleId: serializer.fromJson<String>(json['puzzleId']),
      levelIndex: serializer.fromJson<int>(json['levelIndex']),
      solvedAt: serializer.fromJson<int?>(json['solvedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'puzzleSet': serializer.toJson<String>(puzzleSet),
      'puzzleId': serializer.toJson<String>(puzzleId),
      'levelIndex': serializer.toJson<int>(levelIndex),
      'solvedAt': serializer.toJson<int?>(solvedAt),
      'attempts': serializer.toJson<int>(attempts),
    };
  }

  PuzzleAttempt copyWith({
    int? id,
    String? puzzleSet,
    String? puzzleId,
    int? levelIndex,
    Value<int?> solvedAt = const Value.absent(),
    int? attempts,
  }) => PuzzleAttempt(
    id: id ?? this.id,
    puzzleSet: puzzleSet ?? this.puzzleSet,
    puzzleId: puzzleId ?? this.puzzleId,
    levelIndex: levelIndex ?? this.levelIndex,
    solvedAt: solvedAt.present ? solvedAt.value : this.solvedAt,
    attempts: attempts ?? this.attempts,
  );
  PuzzleAttempt copyWithCompanion(PuzzleAttemptsCompanion data) {
    return PuzzleAttempt(
      id: data.id.present ? data.id.value : this.id,
      puzzleSet: data.puzzleSet.present ? data.puzzleSet.value : this.puzzleSet,
      puzzleId: data.puzzleId.present ? data.puzzleId.value : this.puzzleId,
      levelIndex: data.levelIndex.present
          ? data.levelIndex.value
          : this.levelIndex,
      solvedAt: data.solvedAt.present ? data.solvedAt.value : this.solvedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleAttempt(')
          ..write('id: $id, ')
          ..write('puzzleSet: $puzzleSet, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('levelIndex: $levelIndex, ')
          ..write('solvedAt: $solvedAt, ')
          ..write('attempts: $attempts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, puzzleSet, puzzleId, levelIndex, solvedAt, attempts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PuzzleAttempt &&
          other.id == this.id &&
          other.puzzleSet == this.puzzleSet &&
          other.puzzleId == this.puzzleId &&
          other.levelIndex == this.levelIndex &&
          other.solvedAt == this.solvedAt &&
          other.attempts == this.attempts);
}

class PuzzleAttemptsCompanion extends UpdateCompanion<PuzzleAttempt> {
  final Value<int> id;
  final Value<String> puzzleSet;
  final Value<String> puzzleId;
  final Value<int> levelIndex;
  final Value<int?> solvedAt;
  final Value<int> attempts;
  const PuzzleAttemptsCompanion({
    this.id = const Value.absent(),
    this.puzzleSet = const Value.absent(),
    this.puzzleId = const Value.absent(),
    this.levelIndex = const Value.absent(),
    this.solvedAt = const Value.absent(),
    this.attempts = const Value.absent(),
  });
  PuzzleAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required String puzzleSet,
    required String puzzleId,
    required int levelIndex,
    this.solvedAt = const Value.absent(),
    this.attempts = const Value.absent(),
  }) : puzzleSet = Value(puzzleSet),
       puzzleId = Value(puzzleId),
       levelIndex = Value(levelIndex);
  static Insertable<PuzzleAttempt> custom({
    Expression<int>? id,
    Expression<String>? puzzleSet,
    Expression<String>? puzzleId,
    Expression<int>? levelIndex,
    Expression<int>? solvedAt,
    Expression<int>? attempts,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (puzzleSet != null) 'puzzle_set': puzzleSet,
      if (puzzleId != null) 'puzzle_id': puzzleId,
      if (levelIndex != null) 'level_index': levelIndex,
      if (solvedAt != null) 'solved_at': solvedAt,
      if (attempts != null) 'attempts': attempts,
    });
  }

  PuzzleAttemptsCompanion copyWith({
    Value<int>? id,
    Value<String>? puzzleSet,
    Value<String>? puzzleId,
    Value<int>? levelIndex,
    Value<int?>? solvedAt,
    Value<int>? attempts,
  }) {
    return PuzzleAttemptsCompanion(
      id: id ?? this.id,
      puzzleSet: puzzleSet ?? this.puzzleSet,
      puzzleId: puzzleId ?? this.puzzleId,
      levelIndex: levelIndex ?? this.levelIndex,
      solvedAt: solvedAt ?? this.solvedAt,
      attempts: attempts ?? this.attempts,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (puzzleSet.present) {
      map['puzzle_set'] = Variable<String>(puzzleSet.value);
    }
    if (puzzleId.present) {
      map['puzzle_id'] = Variable<String>(puzzleId.value);
    }
    if (levelIndex.present) {
      map['level_index'] = Variable<int>(levelIndex.value);
    }
    if (solvedAt.present) {
      map['solved_at'] = Variable<int>(solvedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('puzzleSet: $puzzleSet, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('levelIndex: $levelIndex, ')
          ..write('solvedAt: $solvedAt, ')
          ..write('attempts: $attempts')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PuzzleAttemptsTable puzzleAttempts = $PuzzleAttemptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [puzzleAttempts];
}

typedef $$PuzzleAttemptsTableCreateCompanionBuilder =
    PuzzleAttemptsCompanion Function({
      Value<int> id,
      required String puzzleSet,
      required String puzzleId,
      required int levelIndex,
      Value<int?> solvedAt,
      Value<int> attempts,
    });
typedef $$PuzzleAttemptsTableUpdateCompanionBuilder =
    PuzzleAttemptsCompanion Function({
      Value<int> id,
      Value<String> puzzleSet,
      Value<String> puzzleId,
      Value<int> levelIndex,
      Value<int?> solvedAt,
      Value<int> attempts,
    });

class $$PuzzleAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $PuzzleAttemptsTable> {
  $$PuzzleAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puzzleSet => $composableBuilder(
    column: $table.puzzleSet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get levelIndex => $composableBuilder(
    column: $table.levelIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get solvedAt => $composableBuilder(
    column: $table.solvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PuzzleAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $PuzzleAttemptsTable> {
  $$PuzzleAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puzzleSet => $composableBuilder(
    column: $table.puzzleSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get levelIndex => $composableBuilder(
    column: $table.levelIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get solvedAt => $composableBuilder(
    column: $table.solvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PuzzleAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PuzzleAttemptsTable> {
  $$PuzzleAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get puzzleSet =>
      $composableBuilder(column: $table.puzzleSet, builder: (column) => column);

  GeneratedColumn<String> get puzzleId =>
      $composableBuilder(column: $table.puzzleId, builder: (column) => column);

  GeneratedColumn<int> get levelIndex => $composableBuilder(
    column: $table.levelIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get solvedAt =>
      $composableBuilder(column: $table.solvedAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);
}

class $$PuzzleAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PuzzleAttemptsTable,
          PuzzleAttempt,
          $$PuzzleAttemptsTableFilterComposer,
          $$PuzzleAttemptsTableOrderingComposer,
          $$PuzzleAttemptsTableAnnotationComposer,
          $$PuzzleAttemptsTableCreateCompanionBuilder,
          $$PuzzleAttemptsTableUpdateCompanionBuilder,
          (
            PuzzleAttempt,
            BaseReferences<_$AppDatabase, $PuzzleAttemptsTable, PuzzleAttempt>,
          ),
          PuzzleAttempt,
          PrefetchHooks Function()
        > {
  $$PuzzleAttemptsTableTableManager(
    _$AppDatabase db,
    $PuzzleAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PuzzleAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PuzzleAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PuzzleAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> puzzleSet = const Value.absent(),
                Value<String> puzzleId = const Value.absent(),
                Value<int> levelIndex = const Value.absent(),
                Value<int?> solvedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
              }) => PuzzleAttemptsCompanion(
                id: id,
                puzzleSet: puzzleSet,
                puzzleId: puzzleId,
                levelIndex: levelIndex,
                solvedAt: solvedAt,
                attempts: attempts,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String puzzleSet,
                required String puzzleId,
                required int levelIndex,
                Value<int?> solvedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
              }) => PuzzleAttemptsCompanion.insert(
                id: id,
                puzzleSet: puzzleSet,
                puzzleId: puzzleId,
                levelIndex: levelIndex,
                solvedAt: solvedAt,
                attempts: attempts,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PuzzleAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PuzzleAttemptsTable,
      PuzzleAttempt,
      $$PuzzleAttemptsTableFilterComposer,
      $$PuzzleAttemptsTableOrderingComposer,
      $$PuzzleAttemptsTableAnnotationComposer,
      $$PuzzleAttemptsTableCreateCompanionBuilder,
      $$PuzzleAttemptsTableUpdateCompanionBuilder,
      (
        PuzzleAttempt,
        BaseReferences<_$AppDatabase, $PuzzleAttemptsTable, PuzzleAttempt>,
      ),
      PuzzleAttempt,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PuzzleAttemptsTableTableManager get puzzleAttempts =>
      $$PuzzleAttemptsTableTableManager(_db, _db.puzzleAttempts);
}
