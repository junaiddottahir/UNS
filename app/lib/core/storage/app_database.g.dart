// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasbihDaysTable extends TasbihDays
    with TableInfo<$TasbihDaysTable, TasbihDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasbihDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasbih_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasbihDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  TasbihDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasbihDay(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $TasbihDaysTable createAlias(String alias) {
    return $TasbihDaysTable(attachedDatabase, alias);
  }
}

class TasbihDay extends DataClass implements Insertable<TasbihDay> {
  final String day;
  final int count;
  const TasbihDay({required this.day, required this.count});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['count'] = Variable<int>(count);
    return map;
  }

  TasbihDaysCompanion toCompanion(bool nullToAbsent) {
    return TasbihDaysCompanion(day: Value(day), count: Value(count));
  }

  factory TasbihDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasbihDay(
      day: serializer.fromJson<String>(json['day']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'count': serializer.toJson<int>(count),
    };
  }

  TasbihDay copyWith({String? day, int? count}) =>
      TasbihDay(day: day ?? this.day, count: count ?? this.count);
  TasbihDay copyWithCompanion(TasbihDaysCompanion data) {
    return TasbihDay(
      day: data.day.present ? data.day.value : this.day,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasbihDay(')
          ..write('day: $day, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasbihDay &&
          other.day == this.day &&
          other.count == this.count);
}

class TasbihDaysCompanion extends UpdateCompanion<TasbihDay> {
  final Value<String> day;
  final Value<int> count;
  final Value<int> rowid;
  const TasbihDaysCompanion({
    this.day = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasbihDaysCompanion.insert({
    required String day,
    required int count,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       count = Value(count);
  static Insertable<TasbihDay> custom({
    Expression<String>? day,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasbihDaysCompanion copyWith({
    Value<String>? day,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return TasbihDaysCompanion(
      day: day ?? this.day,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasbihDaysCompanion(')
          ..write('day: $day, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VerseTextsTable extends VerseTexts
    with TableInfo<$VerseTextsTable, VerseText> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerseTextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _editionMeta = const VerificationMeta(
    'edition',
  );
  @override
  late final GeneratedColumn<String> edition = GeneratedColumn<String>(
    'edition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surahMeta = const VerificationMeta('surah');
  @override
  late final GeneratedColumn<int> surah = GeneratedColumn<int>(
    'surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahMeta = const VerificationMeta('ayah');
  @override
  late final GeneratedColumn<int> ayah = GeneratedColumn<int>(
    'ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [edition, surah, ayah, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verse_texts';
  @override
  VerificationContext validateIntegrity(
    Insertable<VerseText> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('edition')) {
      context.handle(
        _editionMeta,
        edition.isAcceptableOrUnknown(data['edition']!, _editionMeta),
      );
    } else if (isInserting) {
      context.missing(_editionMeta);
    }
    if (data.containsKey('surah')) {
      context.handle(
        _surahMeta,
        surah.isAcceptableOrUnknown(data['surah']!, _surahMeta),
      );
    } else if (isInserting) {
      context.missing(_surahMeta);
    }
    if (data.containsKey('ayah')) {
      context.handle(
        _ayahMeta,
        ayah.isAcceptableOrUnknown(data['ayah']!, _ayahMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {edition, surah, ayah};
  @override
  VerseText map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseText(
      edition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition'],
      )!,
      surah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah'],
      )!,
      ayah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $VerseTextsTable createAlias(String alias) {
    return $VerseTextsTable(attachedDatabase, alias);
  }
}

class VerseText extends DataClass implements Insertable<VerseText> {
  final String edition;
  final int surah;
  final int ayah;
  final String body;
  const VerseText({
    required this.edition,
    required this.surah,
    required this.ayah,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['edition'] = Variable<String>(edition);
    map['surah'] = Variable<int>(surah);
    map['ayah'] = Variable<int>(ayah);
    map['body'] = Variable<String>(body);
    return map;
  }

  VerseTextsCompanion toCompanion(bool nullToAbsent) {
    return VerseTextsCompanion(
      edition: Value(edition),
      surah: Value(surah),
      ayah: Value(ayah),
      body: Value(body),
    );
  }

  factory VerseText.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseText(
      edition: serializer.fromJson<String>(json['edition']),
      surah: serializer.fromJson<int>(json['surah']),
      ayah: serializer.fromJson<int>(json['ayah']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'edition': serializer.toJson<String>(edition),
      'surah': serializer.toJson<int>(surah),
      'ayah': serializer.toJson<int>(ayah),
      'body': serializer.toJson<String>(body),
    };
  }

  VerseText copyWith({String? edition, int? surah, int? ayah, String? body}) =>
      VerseText(
        edition: edition ?? this.edition,
        surah: surah ?? this.surah,
        ayah: ayah ?? this.ayah,
        body: body ?? this.body,
      );
  VerseText copyWithCompanion(VerseTextsCompanion data) {
    return VerseText(
      edition: data.edition.present ? data.edition.value : this.edition,
      surah: data.surah.present ? data.surah.value : this.surah,
      ayah: data.ayah.present ? data.ayah.value : this.ayah,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseText(')
          ..write('edition: $edition, ')
          ..write('surah: $surah, ')
          ..write('ayah: $ayah, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(edition, surah, ayah, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseText &&
          other.edition == this.edition &&
          other.surah == this.surah &&
          other.ayah == this.ayah &&
          other.body == this.body);
}

class VerseTextsCompanion extends UpdateCompanion<VerseText> {
  final Value<String> edition;
  final Value<int> surah;
  final Value<int> ayah;
  final Value<String> body;
  final Value<int> rowid;
  const VerseTextsCompanion({
    this.edition = const Value.absent(),
    this.surah = const Value.absent(),
    this.ayah = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VerseTextsCompanion.insert({
    required String edition,
    required int surah,
    required int ayah,
    required String body,
    this.rowid = const Value.absent(),
  }) : edition = Value(edition),
       surah = Value(surah),
       ayah = Value(ayah),
       body = Value(body);
  static Insertable<VerseText> custom({
    Expression<String>? edition,
    Expression<int>? surah,
    Expression<int>? ayah,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (edition != null) 'edition': edition,
      if (surah != null) 'surah': surah,
      if (ayah != null) 'ayah': ayah,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VerseTextsCompanion copyWith({
    Value<String>? edition,
    Value<int>? surah,
    Value<int>? ayah,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return VerseTextsCompanion(
      edition: edition ?? this.edition,
      surah: surah ?? this.surah,
      ayah: ayah ?? this.ayah,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (edition.present) {
      map['edition'] = Variable<String>(edition.value);
    }
    if (surah.present) {
      map['surah'] = Variable<int>(surah.value);
    }
    if (ayah.present) {
      map['ayah'] = Variable<int>(ayah.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerseTextsCompanion(')
          ..write('edition: $edition, ')
          ..write('surah: $surah, ')
          ..write('ayah: $ayah, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $TasbihDaysTable tasbihDays = $TasbihDaysTable(this);
  late final $VerseTextsTable verseTexts = $VerseTextsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    tasbihDays,
    verseTexts,
  ];
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$TasbihDaysTableCreateCompanionBuilder = TasbihDaysCompanion Function({
  required String day,
  required int count,
  Value<int> rowid,
});
typedef $$TasbihDaysTableUpdateCompanionBuilder = TasbihDaysCompanion Function({
  Value<String> day,
  Value<int> count,
  Value<int> rowid,
});

class $$TasbihDaysTableFilterComposer
    extends Composer<_$AppDatabase, $TasbihDaysTable> {
  $$TasbihDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasbihDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $TasbihDaysTable> {
  $$TasbihDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasbihDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasbihDaysTable> {
  $$TasbihDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$TasbihDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasbihDaysTable,
          TasbihDay,
          $$TasbihDaysTableFilterComposer,
          $$TasbihDaysTableOrderingComposer,
          $$TasbihDaysTableAnnotationComposer,
          $$TasbihDaysTableCreateCompanionBuilder,
          $$TasbihDaysTableUpdateCompanionBuilder,
          (
            TasbihDay,
            BaseReferences<_$AppDatabase, $TasbihDaysTable, TasbihDay>,
          ),
          TasbihDay,
          PrefetchHooks Function()
        > {
  $$TasbihDaysTableTableManager(_$AppDatabase db, $TasbihDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasbihDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasbihDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasbihDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<int> count = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => TasbihDaysCompanion(day: day, count: count, rowid: rowid),
          createCompanionCallback:
              ({
                required String day,
                required int count,
                Value<int> rowid = const Value.absent(),
              }) => TasbihDaysCompanion.insert(
                day: day,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasbihDaysTable, TasbihDay>(table),
                  BaseReferences<_$AppDatabase, $TasbihDaysTable, TasbihDay>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasbihDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasbihDaysTable,
      TasbihDay,
      $$TasbihDaysTableFilterComposer,
      $$TasbihDaysTableOrderingComposer,
      $$TasbihDaysTableAnnotationComposer,
      $$TasbihDaysTableCreateCompanionBuilder,
      $$TasbihDaysTableUpdateCompanionBuilder,
      (TasbihDay, BaseReferences<_$AppDatabase, $TasbihDaysTable, TasbihDay>),
      TasbihDay,
      PrefetchHooks Function()
    >;
typedef $$VerseTextsTableCreateCompanionBuilder = VerseTextsCompanion Function({
  required String edition,
  required int surah,
  required int ayah,
  required String body,
  Value<int> rowid,
});
typedef $$VerseTextsTableUpdateCompanionBuilder = VerseTextsCompanion Function({
  Value<String> edition,
  Value<int> surah,
  Value<int> ayah,
  Value<String> body,
  Value<int> rowid,
});

class $$VerseTextsTableFilterComposer
    extends Composer<_$AppDatabase, $VerseTextsTable> {
  $$VerseTextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get edition => $composableBuilder(
    column: $table.edition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surah => $composableBuilder(
    column: $table.surah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayah => $composableBuilder(
    column: $table.ayah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VerseTextsTableOrderingComposer
    extends Composer<_$AppDatabase, $VerseTextsTable> {
  $$VerseTextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get edition => $composableBuilder(
    column: $table.edition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surah => $composableBuilder(
    column: $table.surah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayah => $composableBuilder(
    column: $table.ayah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VerseTextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VerseTextsTable> {
  $$VerseTextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get edition =>
      $composableBuilder(column: $table.edition, builder: (column) => column);

  GeneratedColumn<int> get surah =>
      $composableBuilder(column: $table.surah, builder: (column) => column);

  GeneratedColumn<int> get ayah =>
      $composableBuilder(column: $table.ayah, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$VerseTextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VerseTextsTable,
          VerseText,
          $$VerseTextsTableFilterComposer,
          $$VerseTextsTableOrderingComposer,
          $$VerseTextsTableAnnotationComposer,
          $$VerseTextsTableCreateCompanionBuilder,
          $$VerseTextsTableUpdateCompanionBuilder,
          (
            VerseText,
            BaseReferences<_$AppDatabase, $VerseTextsTable, VerseText>,
          ),
          VerseText,
          PrefetchHooks Function()
        > {
  $$VerseTextsTableTableManager(_$AppDatabase db, $VerseTextsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VerseTextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VerseTextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VerseTextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> edition = const Value.absent(),
                Value<int> surah = const Value.absent(),
                Value<int> ayah = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VerseTextsCompanion(
                edition: edition,
                surah: surah,
                ayah: ayah,
                body: body,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String edition,
                required int surah,
                required int ayah,
                required String body,
                Value<int> rowid = const Value.absent(),
              }) => VerseTextsCompanion.insert(
                edition: edition,
                surah: surah,
                ayah: ayah,
                body: body,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VerseTextsTable, VerseText>(table),
                  BaseReferences<_$AppDatabase, $VerseTextsTable, VerseText>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VerseTextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VerseTextsTable,
      VerseText,
      $$VerseTextsTableFilterComposer,
      $$VerseTextsTableOrderingComposer,
      $$VerseTextsTableAnnotationComposer,
      $$VerseTextsTableCreateCompanionBuilder,
      $$VerseTextsTableUpdateCompanionBuilder,
      (VerseText, BaseReferences<_$AppDatabase, $VerseTextsTable, VerseText>),
      VerseText,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$TasbihDaysTableTableManager get tasbihDays =>
      $$TasbihDaysTableTableManager(_db, _db.tasbihDays);
  $$VerseTextsTableTableManager get verseTexts =>
      $$VerseTextsTableTableManager(_db, _db.verseTexts);
}
