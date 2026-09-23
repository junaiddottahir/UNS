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
    with TableInfo<$VerseTextsTable, CachedVerseText> {
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
    Insertable<CachedVerseText> instance, {
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
  CachedVerseText map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedVerseText(
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

class CachedVerseText extends DataClass implements Insertable<CachedVerseText> {
  final String edition;
  final int surah;
  final int ayah;
  final String body;
  const CachedVerseText({
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

  factory CachedVerseText.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedVerseText(
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

  CachedVerseText copyWith({
    String? edition,
    int? surah,
    int? ayah,
    String? body,
  }) => CachedVerseText(
    edition: edition ?? this.edition,
    surah: surah ?? this.surah,
    ayah: ayah ?? this.ayah,
    body: body ?? this.body,
  );
  CachedVerseText copyWithCompanion(VerseTextsCompanion data) {
    return CachedVerseText(
      edition: data.edition.present ? data.edition.value : this.edition,
      surah: data.surah.present ? data.surah.value : this.surah,
      ayah: data.ayah.present ? data.ayah.value : this.ayah,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedVerseText(')
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
      (other is CachedVerseText &&
          other.edition == this.edition &&
          other.surah == this.surah &&
          other.ayah == this.ayah &&
          other.body == this.body);
}

class VerseTextsCompanion extends UpdateCompanion<CachedVerseText> {
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
  static Insertable<CachedVerseText> custom({
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

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emotionMeta = const VerificationMeta(
    'emotion',
  );
  @override
  late final GeneratedColumn<String> emotion = GeneratedColumn<String>(
    'emotion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _helpMeta = const VerificationMeta('help');
  @override
  late final GeneratedColumn<String> help = GeneratedColumn<String>(
    'help',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versesMeta = const VerificationMeta('verses');
  @override
  late final GeneratedColumn<String> verses = GeneratedColumn<String>(
    'verses',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _moodAfterMeta = const VerificationMeta(
    'moodAfter',
  );
  @override
  late final GeneratedColumn<String> moodAfter = GeneratedColumn<String>(
    'mood_after',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reflectionMeta = const VerificationMeta(
    'reflection',
  );
  @override
  late final GeneratedColumn<String> reflection = GeneratedColumn<String>(
    'reflection',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voiceNoteMeta = const VerificationMeta(
    'voiceNote',
  );
  @override
  late final GeneratedColumn<String> voiceNote = GeneratedColumn<String>(
    'voice_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voiceSecondsMeta = const VerificationMeta(
    'voiceSeconds',
  );
  @override
  late final GeneratedColumn<int> voiceSeconds = GeneratedColumn<int>(
    'voice_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    emotion,
    help,
    minutes,
    verses,
    moodAfter,
    endedAt,
    reflection,
    voiceNote,
    voiceSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('emotion')) {
      context.handle(
        _emotionMeta,
        emotion.isAcceptableOrUnknown(data['emotion']!, _emotionMeta),
      );
    } else if (isInserting) {
      context.missing(_emotionMeta);
    }
    if (data.containsKey('help')) {
      context.handle(
        _helpMeta,
        help.isAcceptableOrUnknown(data['help']!, _helpMeta),
      );
    } else if (isInserting) {
      context.missing(_helpMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    } else if (isInserting) {
      context.missing(_minutesMeta);
    }
    if (data.containsKey('verses')) {
      context.handle(
        _versesMeta,
        verses.isAcceptableOrUnknown(data['verses']!, _versesMeta),
      );
    }
    if (data.containsKey('mood_after')) {
      context.handle(
        _moodAfterMeta,
        moodAfter.isAcceptableOrUnknown(data['mood_after']!, _moodAfterMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('reflection')) {
      context.handle(
        _reflectionMeta,
        reflection.isAcceptableOrUnknown(data['reflection']!, _reflectionMeta),
      );
    }
    if (data.containsKey('voice_note')) {
      context.handle(
        _voiceNoteMeta,
        voiceNote.isAcceptableOrUnknown(data['voice_note']!, _voiceNoteMeta),
      );
    }
    if (data.containsKey('voice_seconds')) {
      context.handle(
        _voiceSecondsMeta,
        voiceSeconds.isAcceptableOrUnknown(
          data['voice_seconds']!,
          _voiceSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      emotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emotion'],
      )!,
      help: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}help'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
      verses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verses'],
      )!,
      moodAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_after'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      reflection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection'],
      ),
      voiceNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_note'],
      ),
      voiceSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voice_seconds'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final DateTime startedAt;
  final String emotion;

  /// `comfort` or `remind`.
  final String help;
  final int minutes;

  /// Verses played, e.g. `2:286,94:5`.
  final String verses;
  final String? moodAfter;
  final DateTime? endedAt;

  /// The written reflection, if any (journal). Never processed by AI.
  final String? reflection;

  /// A voice-note reflection: its encrypted file in the vault, and length.
  /// Never transcribed.
  final String? voiceNote;
  final int? voiceSeconds;
  const Session({
    required this.id,
    required this.startedAt,
    required this.emotion,
    required this.help,
    required this.minutes,
    required this.verses,
    this.moodAfter,
    this.endedAt,
    this.reflection,
    this.voiceNote,
    this.voiceSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['emotion'] = Variable<String>(emotion);
    map['help'] = Variable<String>(help);
    map['minutes'] = Variable<int>(minutes);
    map['verses'] = Variable<String>(verses);
    if (!nullToAbsent || moodAfter != null) {
      map['mood_after'] = Variable<String>(moodAfter);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || reflection != null) {
      map['reflection'] = Variable<String>(reflection);
    }
    if (!nullToAbsent || voiceNote != null) {
      map['voice_note'] = Variable<String>(voiceNote);
    }
    if (!nullToAbsent || voiceSeconds != null) {
      map['voice_seconds'] = Variable<int>(voiceSeconds);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      emotion: Value(emotion),
      help: Value(help),
      minutes: Value(minutes),
      verses: Value(verses),
      moodAfter: moodAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(moodAfter),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      reflection: reflection == null && nullToAbsent
          ? const Value.absent()
          : Value(reflection),
      voiceNote: voiceNote == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceNote),
      voiceSeconds: voiceSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceSeconds),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      emotion: serializer.fromJson<String>(json['emotion']),
      help: serializer.fromJson<String>(json['help']),
      minutes: serializer.fromJson<int>(json['minutes']),
      verses: serializer.fromJson<String>(json['verses']),
      moodAfter: serializer.fromJson<String?>(json['moodAfter']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      reflection: serializer.fromJson<String?>(json['reflection']),
      voiceNote: serializer.fromJson<String?>(json['voiceNote']),
      voiceSeconds: serializer.fromJson<int?>(json['voiceSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'emotion': serializer.toJson<String>(emotion),
      'help': serializer.toJson<String>(help),
      'minutes': serializer.toJson<int>(minutes),
      'verses': serializer.toJson<String>(verses),
      'moodAfter': serializer.toJson<String?>(moodAfter),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'reflection': serializer.toJson<String?>(reflection),
      'voiceNote': serializer.toJson<String?>(voiceNote),
      'voiceSeconds': serializer.toJson<int?>(voiceSeconds),
    };
  }

  Session copyWith({
    int? id,
    DateTime? startedAt,
    String? emotion,
    String? help,
    int? minutes,
    String? verses,
    Value<String?> moodAfter = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> reflection = const Value.absent(),
    Value<String?> voiceNote = const Value.absent(),
    Value<int?> voiceSeconds = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    emotion: emotion ?? this.emotion,
    help: help ?? this.help,
    minutes: minutes ?? this.minutes,
    verses: verses ?? this.verses,
    moodAfter: moodAfter.present ? moodAfter.value : this.moodAfter,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    reflection: reflection.present ? reflection.value : this.reflection,
    voiceNote: voiceNote.present ? voiceNote.value : this.voiceNote,
    voiceSeconds: voiceSeconds.present ? voiceSeconds.value : this.voiceSeconds,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      emotion: data.emotion.present ? data.emotion.value : this.emotion,
      help: data.help.present ? data.help.value : this.help,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      verses: data.verses.present ? data.verses.value : this.verses,
      moodAfter: data.moodAfter.present ? data.moodAfter.value : this.moodAfter,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      reflection: data.reflection.present
          ? data.reflection.value
          : this.reflection,
      voiceNote: data.voiceNote.present ? data.voiceNote.value : this.voiceNote,
      voiceSeconds: data.voiceSeconds.present
          ? data.voiceSeconds.value
          : this.voiceSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('emotion: $emotion, ')
          ..write('help: $help, ')
          ..write('minutes: $minutes, ')
          ..write('verses: $verses, ')
          ..write('moodAfter: $moodAfter, ')
          ..write('endedAt: $endedAt, ')
          ..write('reflection: $reflection, ')
          ..write('voiceNote: $voiceNote, ')
          ..write('voiceSeconds: $voiceSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    emotion,
    help,
    minutes,
    verses,
    moodAfter,
    endedAt,
    reflection,
    voiceNote,
    voiceSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.emotion == this.emotion &&
          other.help == this.help &&
          other.minutes == this.minutes &&
          other.verses == this.verses &&
          other.moodAfter == this.moodAfter &&
          other.endedAt == this.endedAt &&
          other.reflection == this.reflection &&
          other.voiceNote == this.voiceNote &&
          other.voiceSeconds == this.voiceSeconds);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<String> emotion;
  final Value<String> help;
  final Value<int> minutes;
  final Value<String> verses;
  final Value<String?> moodAfter;
  final Value<DateTime?> endedAt;
  final Value<String?> reflection;
  final Value<String?> voiceNote;
  final Value<int?> voiceSeconds;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.emotion = const Value.absent(),
    this.help = const Value.absent(),
    this.minutes = const Value.absent(),
    this.verses = const Value.absent(),
    this.moodAfter = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.reflection = const Value.absent(),
    this.voiceNote = const Value.absent(),
    this.voiceSeconds = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    required String emotion,
    required String help,
    required int minutes,
    this.verses = const Value.absent(),
    this.moodAfter = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.reflection = const Value.absent(),
    this.voiceNote = const Value.absent(),
    this.voiceSeconds = const Value.absent(),
  }) : startedAt = Value(startedAt),
       emotion = Value(emotion),
       help = Value(help),
       minutes = Value(minutes);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<String>? emotion,
    Expression<String>? help,
    Expression<int>? minutes,
    Expression<String>? verses,
    Expression<String>? moodAfter,
    Expression<DateTime>? endedAt,
    Expression<String>? reflection,
    Expression<String>? voiceNote,
    Expression<int>? voiceSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (emotion != null) 'emotion': emotion,
      if (help != null) 'help': help,
      if (minutes != null) 'minutes': minutes,
      if (verses != null) 'verses': verses,
      if (moodAfter != null) 'mood_after': moodAfter,
      if (endedAt != null) 'ended_at': endedAt,
      if (reflection != null) 'reflection': reflection,
      if (voiceNote != null) 'voice_note': voiceNote,
      if (voiceSeconds != null) 'voice_seconds': voiceSeconds,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<String>? emotion,
    Value<String>? help,
    Value<int>? minutes,
    Value<String>? verses,
    Value<String?>? moodAfter,
    Value<DateTime?>? endedAt,
    Value<String?>? reflection,
    Value<String?>? voiceNote,
    Value<int?>? voiceSeconds,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      emotion: emotion ?? this.emotion,
      help: help ?? this.help,
      minutes: minutes ?? this.minutes,
      verses: verses ?? this.verses,
      moodAfter: moodAfter ?? this.moodAfter,
      endedAt: endedAt ?? this.endedAt,
      reflection: reflection ?? this.reflection,
      voiceNote: voiceNote ?? this.voiceNote,
      voiceSeconds: voiceSeconds ?? this.voiceSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (emotion.present) {
      map['emotion'] = Variable<String>(emotion.value);
    }
    if (help.present) {
      map['help'] = Variable<String>(help.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (verses.present) {
      map['verses'] = Variable<String>(verses.value);
    }
    if (moodAfter.present) {
      map['mood_after'] = Variable<String>(moodAfter.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (reflection.present) {
      map['reflection'] = Variable<String>(reflection.value);
    }
    if (voiceNote.present) {
      map['voice_note'] = Variable<String>(voiceNote.value);
    }
    if (voiceSeconds.present) {
      map['voice_seconds'] = Variable<int>(voiceSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('emotion: $emotion, ')
          ..write('help: $help, ')
          ..write('minutes: $minutes, ')
          ..write('verses: $verses, ')
          ..write('moodAfter: $moodAfter, ')
          ..write('endedAt: $endedAt, ')
          ..write('reflection: $reflection, ')
          ..write('voiceNote: $voiceNote, ')
          ..write('voiceSeconds: $voiceSeconds')
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
  late final $SessionsTable sessions = $SessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    tasbihDays,
    verseTexts,
    sessions,
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
          CachedVerseText,
          $$VerseTextsTableFilterComposer,
          $$VerseTextsTableOrderingComposer,
          $$VerseTextsTableAnnotationComposer,
          $$VerseTextsTableCreateCompanionBuilder,
          $$VerseTextsTableUpdateCompanionBuilder,
          (
            CachedVerseText,
            BaseReferences<_$AppDatabase, $VerseTextsTable, CachedVerseText>,
          ),
          CachedVerseText,
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
                  e.readTable<$VerseTextsTable, CachedVerseText>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $VerseTextsTable,
                    CachedVerseText
                  >(db, table, e),
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
      CachedVerseText,
      $$VerseTextsTableFilterComposer,
      $$VerseTextsTableOrderingComposer,
      $$VerseTextsTableAnnotationComposer,
      $$VerseTextsTableCreateCompanionBuilder,
      $$VerseTextsTableUpdateCompanionBuilder,
      (
        CachedVerseText,
        BaseReferences<_$AppDatabase, $VerseTextsTable, CachedVerseText>,
      ),
      CachedVerseText,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required DateTime startedAt,
  required String emotion,
  required String help,
  required int minutes,
  Value<String> verses,
  Value<String?> moodAfter,
  Value<DateTime?> endedAt,
  Value<String?> reflection,
  Value<String?> voiceNote,
  Value<int?> voiceSeconds,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<String> emotion,
  Value<String> help,
  Value<int> minutes,
  Value<String> verses,
  Value<String?> moodAfter,
  Value<DateTime?> endedAt,
  Value<String?> reflection,
  Value<String?> voiceNote,
  Value<int?> voiceSeconds,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get help => $composableBuilder(
    column: $table.help,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verses => $composableBuilder(
    column: $table.verses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moodAfter => $composableBuilder(
    column: $table.moodAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceNote => $composableBuilder(
    column: $table.voiceNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voiceSeconds => $composableBuilder(
    column: $table.voiceSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get help => $composableBuilder(
    column: $table.help,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verses => $composableBuilder(
    column: $table.verses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moodAfter => $composableBuilder(
    column: $table.moodAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceNote => $composableBuilder(
    column: $table.voiceNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voiceSeconds => $composableBuilder(
    column: $table.voiceSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  GeneratedColumn<String> get help =>
      $composableBuilder(column: $table.help, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<String> get verses =>
      $composableBuilder(column: $table.verses, builder: (column) => column);

  GeneratedColumn<String> get moodAfter =>
      $composableBuilder(column: $table.moodAfter, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voiceNote =>
      $composableBuilder(column: $table.voiceNote, builder: (column) => column);

  GeneratedColumn<int> get voiceSeconds => $composableBuilder(
    column: $table.voiceSeconds,
    builder: (column) => column,
  );
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<String> emotion = const Value.absent(),
                Value<String> help = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<String> verses = const Value.absent(),
                Value<String?> moodAfter = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> reflection = const Value.absent(),
                Value<String?> voiceNote = const Value.absent(),
                Value<int?> voiceSeconds = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                startedAt: startedAt,
                emotion: emotion,
                help: help,
                minutes: minutes,
                verses: verses,
                moodAfter: moodAfter,
                endedAt: endedAt,
                reflection: reflection,
                voiceNote: voiceNote,
                voiceSeconds: voiceSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                required String emotion,
                required String help,
                required int minutes,
                Value<String> verses = const Value.absent(),
                Value<String?> moodAfter = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> reflection = const Value.absent(),
                Value<String?> voiceNote = const Value.absent(),
                Value<int?> voiceSeconds = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                emotion: emotion,
                help: help,
                minutes: minutes,
                verses: verses,
                moodAfter: moodAfter,
                endedAt: endedAt,
                reflection: reflection,
                voiceNote: voiceNote,
                voiceSeconds: voiceSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  BaseReferences<_$AppDatabase, $SessionsTable, Session>(
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

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
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
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
}
