import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Keys in the settings table. Kept together so features can't collide.
abstract final class SettingKeys {
  static const location = 'location';
  static const prayer = 'prayer';
  static const onboardingComplete = 'onboarding_complete';
  static const alerts = 'alerts';
  static const reciter = 'reciter';
}

/// Settings loaded into memory at startup, so providers can read them
/// synchronously; every change is written through to the database.
class SettingsStore {
  SettingsStore._(this._db, this._values);

  final AppDatabase _db;
  final Map<String, String> _values;

  static Future<SettingsStore> load(AppDatabase db) async {
    final rows = await db.select(db.settings).get();
    return SettingsStore._(db, {for (final r in rows) r.key: r.value});
  }

  /// The stored JSON object, or null if missing or unreadable.
  Map<String, Object?>? readJson(String key) {
    final raw = _values[key];
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  bool readBool(String key) => _values[key] == 'true';

  /// Stores [value] now in memory; the database write completes later.
  void writeJson(String key, Map<String, Object?> value) =>
      _write(key, jsonEncode(value));

  void writeBool(String key, bool value) => _write(key, '$value');

  /// Completes when every write so far has reached the database.
  Future<void> flush() => _pending;

  Future<void> _pending = Future.value();

  void _write(String key, String value) {
    _values[key] = value;
    final write = _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
    _pending = _pending.then((_) => write);
    unawaited(_pending);
  }
}

/// Opened in `main` before the app starts, then provided through an
/// override.
final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => throw UnimplementedError('settingsStoreProvider not overridden'),
);
