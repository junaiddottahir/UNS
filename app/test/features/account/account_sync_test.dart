import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/alerts/alert_providers.dart';
import 'package:uns/features/prayer/prayer_providers.dart';
import 'package:uns/features/prayer/prayer_schedule.dart';
import 'package:uns/features/prayer/prayer_settings.dart';
import 'package:uns/features/reciter/reciter.dart';
import 'package:uns/core/l10n/language.dart';
import 'package:uns/features/tasbih/tasbih_store.dart';

import '../../support/test_app.dart';

Future<FakeAuth> _signedIn() async {
  final auth = FakeAuth()..users['a@example.com'] = 'password1';
  await auth.signIn('a@example.com', 'password1');
  return auth;
}

Future<(ProviderContainer, AppDatabase)> _start(
  WidgetTester tester, {
  required FakeAccountApi api,
  FakeAuth? auth,
  SettingsStore? settings,
  AppDatabase? db,
}) async {
  final database = db ?? AppDatabase(NativeDatabase.memory());
  if (db == null) addTearDown(database.close);
  final container = await pumpApp(
    tester,
    auth: auth ?? await _signedIn(),
    accountApi: api,
    settings: settings,
    database: database,
  );
  await tester.pumpAndSettle();
  return (container, database);
}

void main() {
  testWidgets("a new phone takes the account's settings", (tester) async {
    final api = FakeAccountApi()
      ..settings = {
        'prayer': {
          'method': 'karachi',
          'asr': 'hanafi',
          'highLatitude': 'middleOfNight',
        },
        'reciter': 'sudais',
        'language': 'ar',
      }
      ..settingsAt = DateTime.utc(2026, 9, 20);
    final (c, _) = await _start(tester, api: api);
    expect(c.read(prayerSettingsProvider).asr, AsrMethod.hanafi);
    expect(c.read(prayerSettingsProvider).method, PrayerMethod.karachi);
    expect(c.read(reciterProvider), Reciter.sudais);
    expect(c.read(languageProvider), AppLanguage.ar);
    // Nothing was pushed back over the account's settings.
    expect(
      api.calls.where((c) => c.startsWith('PUT /v1/me/settings')),
      isEmpty,
    );
  });

  testWidgets('changes made on the phone go up shortly after', (tester) async {
    final api = FakeAccountApi();
    final (c, _) = await _start(tester, api: api);
    c.read(prayerSettingsProvider.notifier).setAsr(AsrMethod.hanafi);
    c.read(alertSettingsProvider.notifier).toggle(Prayer.fajr);
    c.read(languageProvider.notifier).set(AppLanguage.ar);
    await tester.pumpAndSettle();
    expect(api.settings!['language'], 'ar');
    expect((api.settings!['prayer']! as Map)['asr'], 'hanafi');
    expect(
      ((api.settings!['alerts']! as Map)['prayers']! as Map)['fajr'],
      containsPair('mode', 'adhan'),
    );
  });

  testWidgets('the newer side wins', (tester) async {
    // The phone changed its settings after the account's copy.
    final store = (await tester.runAsync(memoryStore))!;
    store.writeJson(SettingKeys.reciter, {
      'id': 'abdulBasit',
    }, syncedAt: DateTime.utc(2026, 9, 23));
    final api = FakeAccountApi()
      ..settings = {'reciter': 'sudais'}
      ..settingsAt = DateTime.utc(2026, 9, 22);
    final (c, _) = await _start(tester, api: api, settings: store);
    expect(c.read(reciterProvider), Reciter.abdulBasit);
    expect(api.settings, {'reciter': 'abdulBasit'});

    // Later, another phone changes it: this one takes it on the next sync.
    api
      ..settings = {'reciter': 'sudais'}
      ..settingsAt = DateTime.utc(2026, 9, 25);
    c.read(permissionCheckProvider.notifier).recheck(); // back to the app
    await tester.pumpAndSettle();
    expect(c.read(reciterProvider), Reciter.sudais);
  });

  testWidgets('tasbih days merge both ways', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final store = TasbihStore(db);
    await tester.runAsync(() async {
      for (var i = 0; i < 33; i++) {
        await store.increment(DateTime(2026, 9, 23));
      }
    });
    final api = FakeAccountApi()
      ..tasbih.addAll({'2026-09-23': 10, '2026-09-21': 50});
    await _start(tester, api: api, db: db);

    expect(api.tasbih['2026-09-23'], 33);
    final local = await tester.runAsync(store.allDays);
    expect(
      {for (final d in local!) TasbihStore.keyFor(d.date): d.count},
      {'2026-09-23': 33, '2026-09-21': 50},
    );
  });

  testWidgets('signed out: nothing syncs', (tester) async {
    final api = FakeAccountApi();
    await _start(tester, api: api, auth: FakeAuth());
    expect(api.calls, isEmpty);
  });

  testWidgets('offline: no harm, and it tries again after a change', (
    tester,
  ) async {
    final api = FakeAccountApi(fails: true);
    final (c, _) = await _start(tester, api: api);
    expect(api.calls, isNotEmpty);
    api.fails = false;
    c.read(prayerSettingsProvider.notifier).setAsr(AsrMethod.hanafi);
    await tester.pumpAndSettle();
    expect((api.settings!['prayer']! as Map)['asr'], 'hanafi');
  });
}
