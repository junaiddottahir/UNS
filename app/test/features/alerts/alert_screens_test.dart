import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/features/alerts/alert_providers.dart';
import 'package:uns/features/alerts/alert_settings.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/prayer/prayer_schedule.dart';

import '../../support/test_app.dart';

Future<ProviderContainer> _at(
  WidgetTester tester,
  String route, {
  FakeAlertScheduler? scheduler,
  FakeNotificationPermission? permission,
}) async {
  final container = await pumpApp(
    tester,
    scheduler: scheduler,
    notifications: permission,
  );
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  container.read(appRouterProvider).go(Routes.home);
  await tester.pumpAndSettle();
  container.read(appRouterProvider).push(route);
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('settings → alerts → set up Maghrib → scheduled', (tester) async {
    final scheduler = FakeAlertScheduler();
    final container = await _at(
      tester,
      Routes.prayerSettings,
      scheduler: scheduler,
    );
    expect(find.text('0 of 5'), findsOneWidget);
    expect(scheduler.pending, isEmpty);

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    expect(find.text('Prayer alerts'), findsOneWidget);
    expect(find.text('Off'), findsNWidgets(5));

    await tester.tap(find.text('Maghrib'));
    await tester.pumpAndSettle();
    expect(find.text('5:52'), findsOneWidget);
    await tester.tap(find.text('ALERT'));
    await tester.tap(find.text('15 MIN'));
    await tester.tap(find.text('YES'));
    await tester.pumpAndSettle();

    final maghrib = container.read(alertSettingsProvider).of(Prayer.maghrib);
    expect(maghrib.mode, AlertMode.notification);
    expect(maghrib.remindBefore, 15);
    expect(maghrib.checkIn, isTrue);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Alert · 15 min before'), findsOneWidget);

    // Today's three Maghrib notifications come first, in order.
    final firstThree = scheduler.pending.take(3).toList();
    expect(firstThree.map((n) => n.title), [
      'Maghrib in 15 min',
      'Maghrib',
      'Did you pray Maghrib?',
    ]);
    // intl puts a narrow no-break space before PM.
    expect(firstThree[1].body, '5:52\u202fPM · Sydney');
  });

  testWidgets('blocked notifications show a way to turn them on', (
    tester,
  ) async {
    final permission = FakeNotificationPermission(allow: false, granted: false);
    await _at(tester, Routes.prayerAlert('fajr'), permission: permission);
    expect(find.textContaining('Notifications are off'), findsOneWidget);

    await tester.tap(find.text('Turn on notifications'));
    await tester.pumpAndSettle();
    expect(permission.requests, 1);
    expect(permission.settingsOpened, 1);
  });

  testWidgets('a time row opens that prayer\'s alert', (tester) async {
    await _at(tester, Routes.prayerTimes);
    await tester.tap(find.text('Isha'));
    await tester.pumpAndSettle();
    expect(find.text('AT PRAYER TIME'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);
  });
}
