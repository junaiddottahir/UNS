import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/purchases/premium_store.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/features/library/verse_library.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/paywall/quota.dart';
import 'package:uns/features/shama/session_store.dart';

import '../../support/test_app.dart';

/// Sessions already started this week (testNow is Wednesday 23 Sep).
Future<AppDatabase> _dbWith(
  WidgetTester tester, {
  int sessions = 0,
  int replays = 0,
}) async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final store = SessionStore(db);
  await tester.runAsync(() async {
    for (var i = 0; i < sessions + replays; i++) {
      await store.start(
        at: DateTime(2026, 9, 22, 9 + i),
        emotion: Emotion.anxiety,
        comfort: true,
        minutes: 5,
        replay: i >= sessions,
      );
    }
    // Last week's don't count.
    await store.start(
      at: DateTime(2026, 9, 20),
      emotion: Emotion.anxiety,
      comfort: true,
      minutes: 5,
    );
  });
  return db;
}

Future<ProviderContainer> _shama(
  WidgetTester tester, {
  required AppDatabase db,
  FakePremiumStore? premium,
}) async {
  final container = await pumpApp(tester, database: db, premium: premium);
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  container.read(appRouterProvider).go(Routes.shama);
  await tester.pumpAndSettle();
  return container;
}

Future<void> _begin(WidgetTester tester) async {
  await tester.tap(find.text('ANXIOUS'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Comfort me'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Begin'));
  await tester.pumpAndSettle();
}

void main() {
  test('the week starts on Monday', () {
    expect(weekStart(DateTime(2026, 9, 23, 15)), DateTime(2026, 9, 21));
    expect(weekStart(DateTime(2026, 9, 21, 0, 5)), DateTime(2026, 9, 21));
    expect(weekStart(DateTime(2026, 9, 27, 23)), DateTime(2026, 9, 21));
  });

  testWidgets('counts down the free sessions', (tester) async {
    final db = await _dbWith(tester, sessions: 1, replays: 2);
    await _shama(tester, db: db);
    // Replays and last week's sessions don't count.
    expect(
      find.text(
        '${freeSessionsPerWeek - 1} OF $freeSessionsPerWeek FREE THIS WEEK',
      ),
      findsOneWidget,
    );
  });

  testWidgets('past the free sessions, it shows the limit, not a session', (
    tester,
  ) async {
    final db = await _dbWith(tester, sessions: freeSessionsPerWeek);
    await _shama(tester, db: db);
    expect(find.text('NO FREE SESSIONS LEFT'), findsOneWidget);
    await _begin(tester);
    expect(
      find.text('$freeSessionsPerWeek OF $freeSessionsPerWeek USED'),
      findsOneWidget,
    );
    expect(find.text('Your free sessions reset on Monday'), findsOneWidget);
    expect(find.textContaining('FROM QURAN API'), findsNothing);

    await tester.tap(find.text('Revisit a past session'));
    await tester.pumpAndSettle();
    expect(find.text('Journal'), findsOneWidget);
  });

  testWidgets('Premium: no limit and no counter', (tester) async {
    final db = await _dbWith(tester, sessions: freeSessionsPerWeek + 2);
    await _shama(tester, db: db, premium: FakePremiumStore(premium: true));
    expect(find.textContaining('FREE THIS WEEK'), findsNothing);
    await _begin(tester);
    expect(find.textContaining('FROM QURAN API'), findsOneWidget);
  });

  testWidgets('paywall: prices, saving, buy → Premium', (tester) async {
    final premium = FakePremiumStore();
    final db = await _dbWith(tester, sessions: freeSessionsPerWeek);
    final c = await _shama(tester, db: db, premium: premium);
    await _begin(tester);
    await tester.tap(find.text('See Premium'));
    await tester.pumpAndSettle();

    expect(find.text('Go deeper'), findsOneWidget);
    expect(find.text(r'$35.99 / yr'), findsOneWidget);
    expect(find.text(r'$4.99 / mo'), findsOneWidget);
    expect(find.text(r'$89.99 once'), findsOneWidget);
    // 35.99 vs 12 × 4.99 = 59.88 → 39% off.
    expect(find.text('SAVE 39%'), findsOneWidget);

    await tester.tap(find.text('Monthly'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(premium.bought, [PlanKind.monthly]);
    expect(find.text('Welcome to Premium'), findsOneWidget);
    expect(c.read(premiumProvider).value, isTrue);
  });

  testWidgets('a cancelled or failed purchase changes nothing', (tester) async {
    final premium = FakePremiumStore(outcome: BuyOutcome.cancelled);
    final c = await pumpApp(tester, premium: premium);
    c.read(appRouterProvider).push(Routes.plans);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Go deeper'), findsOneWidget);
    expect(find.textContaining("didn't go through"), findsNothing);

    premium.outcome = BuyOutcome.failed;
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining("haven't been charged"), findsOneWidget);
    expect(premium.premium, isFalse);
  });

  testWidgets('restore from the paywall and from Profile', (tester) async {
    final c = await pumpApp(
      tester,
      premium: FakePremiumStore(canRestore: true),
    );
    c.read(appRouterProvider).push(Routes.plans);
    await tester.pumpAndSettle();
    await tester.tap(find.text('RESTORE'));
    await tester.pumpAndSettle();
    expect(find.text('Purchases restored'), findsOneWidget);

    c.read(appRouterProvider).go(Routes.profile);
    await tester.pumpAndSettle();
    expect(find.text('Active'), findsOneWidget);
    await tester.tap(find.text('Restore purchases'));
    await tester.pumpAndSettle();
    expect(find.text('Purchases restored'), findsOneWidget);
  });

  testWidgets('nothing to restore says so', (tester) async {
    final c = await pumpApp(tester);
    c.read(appRouterProvider).go(Routes.profile);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore purchases'));
    await tester.pumpAndSettle();
    expect(find.text('No purchases to restore'), findsOneWidget);
  });

  testWidgets('plans unavailable: says so', (tester) async {
    final c = await pumpApp(tester, premium: FakePremiumStore(plans: const []));
    c.read(appRouterProvider).push(Routes.plans);
    await tester.pumpAndSettle();
    expect(find.textContaining("Plans aren't available"), findsOneWidget);
  });
}
