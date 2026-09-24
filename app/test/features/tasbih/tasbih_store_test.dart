import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/prayer/prayer_providers.dart';
import 'package:uns/features/tasbih/dhikr.dart';
import 'package:uns/features/tasbih/tasbih_providers.dart';
import 'package:uns/features/tasbih/tasbih_store.dart';

import '../../support/test_app.dart';

void main() {
  // Taps trigger haptics, which need the test binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TasbihStore store;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = TasbihStore(db);
  });
  tearDown(() => db.close());

  test('counts per local day', () async {
    final sep23 = DateTime(2026, 9, 23, 23, 59);
    final sep24 = DateTime(2026, 9, 24, 0, 1);
    for (var i = 0; i < 3; i++) {
      await store.increment(sep23);
    }
    await store.increment(sep24);
    expect(await store.watchDay(sep23).first, 3);
    expect(await store.watchDay(sep24).first, 1);
    expect(await store.watchDay(DateTime(2026, 9, 25)).first, 0);
    expect(TasbihStore.keyFor(sep23), '2026-09-23');
  });

  test('live totals update as dhikr are counted', () async {
    final day = DateTime(2026, 9, 23);
    final seen = <int>[];
    final sub = store.watchDay(day).listen(seen.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    await store.increment(day);
    await store.increment(day);
    await pumpEventQueue();
    expect(seen, [0, 1, 2]);
  });

  test('recent days, newest first', () async {
    await store.increment(DateTime(2026, 9, 20));
    await store.increment(DateTime(2026, 9, 22));
    await store.increment(DateTime(2026, 9, 21));
    final days = await store.watchRecent().first;
    expect(days.map((d) => d.date.day), [22, 21, 20]);
  });

  test('upgrading a version 1 database adds tasbih history', () async {
    final dir = Directory.systemTemp.createTempSync('uns_migrate');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/v1.db');
    // A database as unit 3 left it: settings only, schema version 1.
    sqlite3.open(file.path)
      ..execute(
        'CREATE TABLE settings (key TEXT NOT NULL PRIMARY KEY, '
        'value TEXT NOT NULL);',
      )
      ..execute("INSERT INTO settings VALUES ('onboarding_complete', 'true');")
      ..execute('PRAGMA user_version = 1;')
      ..close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);
    final settings = await SettingsStore.load(upgraded);
    expect(settings.readBool(SettingKeys.onboardingComplete), isTrue);
    await TasbihStore(upgraded).increment(DateTime(2026, 9, 23));
    expect(
      await TasbihStore(upgraded).watchDay(DateTime(2026, 9, 23)).first,
      1,
    );
  });

  group('session', () {
    late ProviderContainer container;
    setUp(() async {
      final settings = await SettingsStore.load(db);
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          settingsStoreProvider.overrideWithValue(settings),
          nowProvider.overrideWith(() => FixedClock(testNow)),
        ],
      );
    });
    tearDown(() => container.dispose());

    TasbihSessionNotifier session() =>
        container.read(tasbihSessionProvider.notifier);

    test('counts to the target, then ignores taps', () async {
      session().start([Dhikr.allahuAkbar]);
      for (var i = 0; i < 33; i++) {
        expect(session().tap(), TapResult.counted);
      }
      expect(session().tap(), TapResult.reachedTarget);
      expect(session().tap(), TapResult.ignored);
      expect(container.read(tasbihSessionProvider)!.count, 34);
      await Future<void>.delayed(Duration.zero);
      expect(await store.watchDay(testNow).first, 34);
      expect(session().advance(), isFalse);
      expect(container.read(tasbihSessionProvider), isNull);
      // Ticked for today, but not every dhikr is done.
      expect(container.read(doneTodayProvider), {Dhikr.allahuAkbar});
      expect(container.read(doneTodayProvider.notifier).allDone, isFalse);
    });

    test('the after-prayer set runs in order', () {
      session().start(afterPrayerSet);
      for (final d in afterPrayerSet) {
        expect(container.read(tasbihSessionProvider)!.dhikr, d);
        for (var i = 0; i < d.target; i++) {
          session().tap();
        }
        expect(container.read(tasbihSessionProvider)!.atTarget, isTrue);
        final more = session().advance();
        expect(more, d != Dhikr.allahuAkbar);
      }
      expect(container.read(doneTodayProvider.notifier).allDone, isTrue);
    });

    test('start over resets the count but keeps today', () async {
      session().start([Dhikr.subhanAllah]);
      session()
        ..tap()
        ..tap()
        ..reset();
      expect(container.read(tasbihSessionProvider)!.count, 0);
      await Future<void>.delayed(Duration.zero);
      expect(await store.watchDay(testNow).first, 2);
    });
  });
}
