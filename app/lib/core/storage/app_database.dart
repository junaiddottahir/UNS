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

/// The encrypted on-device database. Holds every piece of user data; later
/// units add journal and session tables.
@DriftDatabase(tables: [Settings, TasbihDays])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(tasbihDays);
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
