import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database_key.dart';

part 'app_database.g.dart';

/// App settings as JSON values under fixed keys (see `SettingsStore`).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Dhikr counted per day, keyed by the phone's local date `yyyy-MM-dd`.
class TasbihDays extends Table {
  TextColumn get day => text()();
  IntColumn get count => integer()();

  @override
  Set<Column> get primaryKey => {day};
}

/// Verse text exactly as fetched from the Quran API, per edition, so
/// sessions work offline.
@DataClassName('CachedVerseText')
class VerseTexts extends Table {
  TextColumn get edition => text()();
  IntColumn get surah => integer()();
  IntColumn get ayah => integer()();
  TextColumn get body => text()();

  @override
  Set<Column> get primaryKey => {edition, surah, ayah};
}

/// Shama sessions and their journal reflections: what was chosen and
/// played, the mood after, and what the user wrote. Never leaves the device.
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  TextColumn get emotion => text()();

  /// `comfort` or `remind`.
  TextColumn get help => text()();
  IntColumn get minutes => integer()();

  /// Verses played, e.g. `2:286,94:5`.
  TextColumn get verses => text().withDefault(const Constant(''))();
  TextColumn get moodAfter => text().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// The written reflection, if any (journal). Never processed by AI.
  TextColumn get reflection => text().nullable()();

  /// A voice-note reflection: its encrypted file in the vault, and length.
  /// Never transcribed.
  TextColumn get voiceNote => text().nullable()();
  IntColumn get voiceSeconds => integer().nullable()();
}

/// The encrypted on-device database. Holds every piece of user data; later
/// units add journal tables.
@DriftDatabase(tables: [Settings, TasbihDays, VerseTexts, Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(tasbihDays);
      if (from < 3) await m.createTable(verseTexts);
      if (from < 4) await m.createTable(sessions);
      if (from == 4) await m.addColumn(sessions, sessions.reflection);
      if (from >= 4 && from < 6) {
        await m.addColumn(sessions, sessions.voiceNote);
        await m.addColumn(sessions, sessions.voiceSeconds);
      }
    },
  );

  static const fileName = 'uns.db';
  static final _hexKey = RegExp(r'^[0-9a-f]{64}$');

  /// Opens (or creates) the encrypted database in the app's support folder.
  static Future<AppDatabase> open({
    DatabaseKeyStore keys = const SecureDatabaseKeyStore(),
    Directory? directory,
  }) async {
    final dir = directory ?? await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, fileName));

    var key = await keys.read();
    if (key == null) {
      key = generateHexKey();
      await keys.write(key);
      // A file without its key is unreadable; start fresh.
      if (file.existsSync()) file.deleteSync();
    } else if (file.existsSync() && !canOpen(file, key)) {
      file.deleteSync();
    }

    final hexKey = key;
    return AppDatabase(
      NativeDatabase.createInBackground(
        file,
        setup: (db) => applyKey(db, hexKey),
      ),
    );
  }

  /// Unlocks [db] with [hexKey]. Throws if the SQLite build in use can't
  /// encrypt, so data is never written in plain text by mistake.
  static void applyKey(Database db, String hexKey) {
    if (!_hexKey.hasMatch(hexKey)) {
      throw ArgumentError('Database key must be 64 hex characters.');
    }
    final cipher = db.select('PRAGMA cipher;');
    if (cipher.isEmpty) {
      throw StateError('SQLite build has no encryption support.');
    }
    db.execute("PRAGMA hexkey = '$hexKey';");
  }

  /// Whether [file] opens with [hexKey].
  static bool canOpen(File file, String hexKey) {
    final db = sqlite3.open(file.path);
    try {
      applyKey(db, hexKey);
      db.select('SELECT count(*) FROM sqlite_master;');
      return true;
    } on SqliteException {
      return false;
    } finally {
      db.close();
    }
  }
}

/// Opened in `main` before the app starts, then provided through an
/// override.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider not overridden'),
);
