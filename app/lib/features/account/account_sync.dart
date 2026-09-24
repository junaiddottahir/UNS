import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/auth_service.dart';
import '../../core/storage/settings_store.dart';
import '../alerts/alert_providers.dart';
import '../prayer/prayer_providers.dart';
import '../reciter/reciter.dart';
import '../tasbih/tasbih_providers.dart';
import '../tasbih/tasbih_store.dart';

/// Keeps a signed-in user's settings and tasbih history in step with their
/// account. Only these sync (architecture.md); everything else stays on the
/// phone. Best effort: a failed sync just waits for the next trigger.
class AccountSync {
  AccountSync(this._ref);

  final Ref _ref;
  Future<void>? _running;

  SettingsStore get _store => _ref.read(settingsStoreProvider);
  AccountApi get _api => _ref.read(accountApiProvider);

  /// Syncs settings and tasbih; overlapping calls share one run.
  Future<void> syncAll() =>
      _running ??= _run().whenComplete(() => _running = null);

  Future<void> _run() async {
    try {
      await syncSettings();
      await syncTasbih();
    } on ApiException {
      // Offline, signed out or server trouble: try again later.
    }
  }

  /// The synced settings as the backend expects them.
  Map<String, Object?> _local() => {
    'prayer': ?_store.readJson(SettingKeys.prayer),
    'alerts': ?_store.readJson(SettingKeys.alerts),
    if (_store.readJson(SettingKeys.reciter)?['id'] case final String r)
      'reciter': r,
  };

  /// Newest wins: the phone's settings go up if they changed more recently,
  /// otherwise the account's come down.
  Future<void> syncSettings() async {
    final changedAt = _store.syncedChangedAt;
    final local = _local();
    // Only send when the phone changed since it last agreed with the
    // account; otherwise just look for newer settings.
    final changedHere =
        changedAt != null &&
        local.isNotEmpty &&
        changedAt != _store.syncedAgreedAt;
    final account = changedHere
        ? await _api.putSettings(local, changedAt)
        : await _api.getSettings();
    final settings = account['settings'];
    final at = DateTime.tryParse('${account['updated_at']}');
    if (settings is! Map<String, Object?> || at == null) return;
    if (changedAt == null || at.isAfter(changedAt)) _apply(settings, at);
    _store.markSyncedAgreed(at);
  }

  void _apply(Map<String, Object?> settings, DateTime at) {
    if (settings['prayer'] case final Map<String, Object?> p) {
      _store.writeJson(SettingKeys.prayer, p, syncedAt: at);
      _ref.invalidate(prayerSettingsProvider);
    }
    if (settings['alerts'] case final Map<String, Object?> a) {
      _store.writeJson(SettingKeys.alerts, a, syncedAt: at);
      _ref.invalidate(alertSettingsProvider);
    }
    if (settings['reciter'] case final String r) {
      _store.writeJson(SettingKeys.reciter, {'id': r}, syncedAt: at);
      _ref.invalidate(reciterProvider);
    }
  }

  /// Sends this phone's daily totals and takes back the account's, keeping
  /// the higher count per day.
  Future<void> syncTasbih() async {
    final store = _ref.read(tasbihStoreProvider);
    final days = await store.allDays()
      ..sort((a, b) => b.date.compareTo(a.date));
    final account = await _api.putTasbih([
      for (final d in days.take(400))
        {'day': TasbihStore.keyFor(d.date), 'count': d.count},
    ]);
    for (final entry in account) {
      if (entry case {'day': final String day, 'count': final int count}) {
        final date = DateTime.tryParse(day);
        if (date != null) await store.raiseTo(date, count);
      }
    }
  }
}

final accountSyncProvider = Provider<AccountSync>(AccountSync.new);

/// Wait this long after a change before syncing, so a burst of edits (or
/// tasbih taps) goes up as one. Overridden in tests.
final syncDelayProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 3),
);

/// Runs sync while signed in: at sign-in, on return to the app, and shortly
/// after synced settings or today's tasbih change. Watched by the app root.
final syncDriverProvider = Provider<void>((ref) {
  final signedIn = ref.watch(
    accountProvider.select((a) => a.value?.id != null),
  );
  if (!signedIn) return;
  final sync = ref.read(accountSyncProvider);
  unawaited(sync.syncAll());

  final delay = ref.read(syncDelayProvider);
  Timer? later;
  void soon() {
    later?.cancel();
    later = Timer(delay, () => unawaited(sync.syncAll()));
  }

  ref
    ..listen(prayerSettingsProvider, (_, _) => soon())
    ..listen(alertSettingsProvider, (_, _) => soon())
    ..listen(reciterProvider, (_, _) => soon())
    ..listen(todayTasbihProvider, (_, _) => soon())
    // Bumped when the app comes back to the foreground.
    ..listen(permissionCheckProvider, (_, _) => soon())
    ..onDispose(() => later?.cancel());
});
