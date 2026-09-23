import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/tasbih/tasbih_store.dart';

import '../../support/test_app.dart';

Future<void> _openTasbih(WidgetTester tester, {AppDatabase? db}) async {
  final container = await pumpApp(tester, database: db);
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  container.read(appRouterProvider).go(Routes.tasbih);
  await tester.pumpAndSettle();
}

Future<void> _tapCounter(WidgetTester tester, int times) async {
  for (var i = 0; i < times; i++) {
    await tester.tap(find.text('TAP ANYWHERE'));
    await tester.pump(const Duration(milliseconds: 150));
  }
}

void main() {
  testWidgets('after-prayer set moves on at each target', (tester) async {
    await _openTasbih(tester);
    expect(find.text('After prayer'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('After prayer'));
    await tester.pumpAndSettle();
    expect(find.text('SubhanAllah'), findsOneWidget);
    expect(find.text('1 OF 3'), findsOneWidget);
    expect(find.text('OF 33'), findsOneWidget);

    await _tapCounter(tester, 32);
    expect(find.text('32'), findsOneWidget);
    await tester.tap(find.text('TAP ANYWHERE'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('COMPLETE'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Alhamdulillah'), findsOneWidget);
    expect(find.text('2 OF 3'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('a single dhikr finishes on History with today\'s total', (
    tester,
  ) async {
    await _openTasbih(tester);
    await tester.tap(find.text('Allahu Akbar'));
    await tester.pumpAndSettle();
    expect(find.text('SINGLE DHIKR'), findsOneWidget);

    await tester.tap(find.byTooltip('Start over'));
    await _tapCounter(tester, 34);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Dhikr complete'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('34'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    // Today's total, and Allahu Akbar's target in the list.
    expect(find.text('34'), findsNWidgets(2));
  });

  testWidgets('history lists earlier days by weekday', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final store = TasbihStore(db);
    await tester.runAsync(() async {
      for (var i = 0; i < 5; i++) {
        await store.increment(DateTime(2026, 9, 21)); // Monday
      }
      await store.increment(DateTime(2026, 9, 1));
    });

    await _openTasbih(tester, db: db);
    await tester.tap(find.text('HISTORY'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Sep 1'), findsOneWidget);
    expect(find.text('STREAKS · PREMIUM'), findsOneWidget);
  });

  testWidgets('custom dhikr and streaks lead to Premium', (tester) async {
    await _openTasbih(tester);
    await tester.tap(find.text('Custom dhikr'));
    await tester.pumpAndSettle();
    expect(find.text('Uns Premium'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });
}
