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
  static const library = 'library';
  static const accountOffered = 'account_offered';

  /// Dhikr finished today, for the ticks on the Tasbih tab. Not synced.
  static const tasbihDone = 'tasbih_done';

  /// When the synced settings (below) last changed on this phone.
  static const syncedChangedAt = 'synced_changed_at';

  /// The change time last agreed with the account (after a sync).
  static const syncedAgreedAt = 'synced_agreed_at';

  /// The settings that sync to a signed-in account (architecture.md).
  static const synced = {prayer, alerts, reciter};
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
  /// For a synced key this also stamps the change time — [syncedAt] when
  /// the value came from the account, so it isn't sent straight back.
  void writeJson(String key, Map<String, Object?> value, {DateTime? syncedAt}) {
    _write(key, jsonEncode(value));
    if (SettingKeys.synced.contains(key)) {
      _write(
        SettingKeys.syncedChangedAt,
        (syncedAt ?? DateTime.now()).toUtc().toIso8601String(),
      );
    }
  }

  /// When synced settings last changed here, or null if never.
  DateTime? get syncedChangedAt =>
      DateTime.tryParse(_values[SettingKeys.syncedChangedAt] ?? '');

  /// The change time both the phone and the account last held.
  DateTime? get syncedAgreedAt =>
      DateTime.tryParse(_values[SettingKeys.syncedAgreedAt] ?? '');

  void markSyncedAgreed(DateTime at) =>
      _write(SettingKeys.syncedAgreedAt, at.toUtc().toIso8601String());

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
