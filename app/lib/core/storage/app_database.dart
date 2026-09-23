import 'dart:io';

import 'package:drift/drift.dart';
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

/// The encrypted on-device database. Holds every piece of user data; later
/// units add journal, tasbih and session tables.
@DriftDatabase(tables: [Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

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
