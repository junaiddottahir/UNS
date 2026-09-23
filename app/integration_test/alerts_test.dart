import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/alerts/alert_planner.dart';
import 'package:uns/features/alerts/alert_settings.dart';
import 'package:uns/features/alerts/notification_permission.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/prayer/prayer_schedule.dart';
import 'package:uns/main.dart';

const _sydney = City(
  name: 'Sydney',
  region: 'New South Wales',
  countryCode: 'AU',
  countryName: 'Australia',
  latitude: -33.8678,
  longitude: 151.2073,
  timeZone: 'Australia/Sydney',
  population: 5638830,
);

/// Launching with saved alert choices registers them with iOS:
///   flutter test integration_test/alerts_test.dart -d SIMULATOR_ID
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
    dispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(dispatcher.clearAccessibilityFeaturesTestValue);
  });

  testWidgets('saved alerts are scheduled with the OS on launch', (
    tester,
  ) async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, AppDatabase.fileName));
    if (file.existsSync()) file.deleteSync();

    // Provisional (quiet) permission needs no prompt, so the simulator can
    // schedule without a tap.
    final granted = await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true, provisional: true);
    expect(granted, isTrue);

    final db = await AppDatabase.open();
    final store = await SettingsStore.load(db);
    final alerts = AlertSettings.defaults
        .withPrayer(
          Prayer.fajr,
          const PrayerAlert(mode: AlertMode.adhan, remindBefore: 15),
        )
        .withPrayer(
          Prayer.maghrib,
          const PrayerAlert(mode: AlertMode.silent, checkIn: true),
        );
    store
      ..writeJson(SettingKeys.location, UserLocation.fromCity(_sydney).toJson())
      ..writeJson(SettingKeys.alerts, alerts.toJson())
      ..writeBool(SettingKeys.onboardingComplete, true);
    await store.flush();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsStoreProvider.overrideWithValue(store)],
        child: const UnsApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    final pending = await FlutterLocalNotificationsPlugin()
        .pendingNotificationRequests();
    // 7 days × 4 (Fajr + reminder, Maghrib + check-in), minus any past today.
    expect(pending.length, inInclusiveRange(24, 28));
    expect(pending.length, lessThanOrEqualTo(maxPendingAlerts));
    final titles = pending.map((n) => n.title).toSet();
    expect(
      titles,
      containsAll([
        'Fajr',
        'Fajr in 15 min',
        'Maghrib',
        'Did you pray Maghrib?',
      ]),
    );
    await db.close();
  });

  // iOS triggers it on time (it leaves the pending list). Whether the
  // banner shows depends on permission and focus, so check that by hand.
  testWidgets('a scheduled alert fires at its time', (tester) async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true, provisional: true);
    await plugin.cancelAll();

    await LocalNotifications(plugin).replaceAll([
      ScheduledNotification(
        id: 1,
        fireAt: tz.TZDateTime.now(timeZoneNamed('Australia/Sydney'))
            .add(const Duration(seconds: 5)),
        title: 'Asr',
        body: 'Delivery check',
        mode: AlertMode.notification,
      ),
    ]);
    expect((await plugin.pendingNotificationRequests()).length, 1);

    await Future<void>.delayed(const Duration(seconds: 2));
    expect((await plugin.pendingNotificationRequests()).length, 1);
    await Future<void>.delayed(const Duration(seconds: 6));
    expect(await plugin.pendingNotificationRequests(), isEmpty);
    await plugin.cancelAll();
  });
}
