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

  testWidgets('a single dhikr is ticked; History comes once all are done', (
    tester,
  ) async {
    await _openTasbih(tester);
    expect(find.text('dhikr'), findsOneWidget);
    await tester.tap(find.text('Allahu Akbar'));
    await tester.pumpAndSettle();
    expect(find.text('SINGLE DHIKR'), findsOneWidget);

    await tester.tap(find.byTooltip('Start over'));
    await _tapCounter(tester, 34);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Back on the list, not History: Allahu Akbar has a tick.
    expect(find.text('Dhikr complete'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('dhikr · 1 of 3 complete'), findsOneWidget);
    // Today's total, and Allahu Akbar's target in the list.
    expect(find.text('34'), findsNWidgets(2));

    // The other two: the last one finishes on History.
    for (final (name, target) in [('SubhanAllah', 33), ('Alhamdulillah', 33)]) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      await _tapCounter(tester, target);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
    expect(find.text('Dhikr complete'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
    expect(find.text('dhikr · all complete'), findsOneWidget);
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
    expect(find.text('Go deeper'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });
}
