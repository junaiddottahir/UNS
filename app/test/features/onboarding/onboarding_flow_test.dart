import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/alerts/alert_providers.dart';
import 'package:uns/features/alerts/alert_settings.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/prayer/prayer_schedule.dart';
import 'package:uns/features/reciter/reciter.dart';
import 'package:uns/features/location/device_locator.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/prayer/prayer_providers.dart';
import 'package:uns/features/prayer/prayer_settings.dart';

import '../../support/test_app.dart';

Future<void> _toLocationStep(WidgetTester tester) async {
  await tester.tap(find.text('Begin'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
  expect(find.text('Where are you?'), findsOneWidget);
  expect(find.text('1 OF 4'), findsOneWidget);
}

void main() {
  testWidgets('welcome shows greeting and Begin', (tester) async {
    await pumpApp(tester);
    expect(find.text('ASSALAMU ALAYKUM'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
  });

  testWidgets('intro slides advance with the arrow to location', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    expect(find.text('Pray on time, anywhere'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();
    }
    expect(find.text('Where are you?'), findsOneWidget);
  });

  testWidgets('device location resolves to the nearest city', (tester) async {
    final container = await pumpApp(
      tester,
      locator: FakeLocator(const DeviceLocationFound(-33.8568, 151.2153)),
    );
    await _toLocationStep(tester);

    await tester.tap(find.text('Use my location'));
    await tester.pumpAndSettle();

    expect(find.text('Your prayer times'), findsOneWidget);
    expect(find.text('Sydney, today. Updates as you choose.'), findsOneWidget);
    expect(find.text('METHOD · MUSLIM WORLD LEAGUE'), findsOneWidget);
    final location = container.read(userLocationProvider)!;
    expect(location.source, LocationSource.device);
    expect(location.latitude, -33.8568);
  });

  testWidgets('permanently denied shows Settings link and city fallback', (
    tester,
  ) async {
    final locator = FakeLocator(const DeviceLocationDenied(permanently: true));
    await pumpApp(tester, locator: locator);
    await _toLocationStep(tester);

    await tester.tap(find.text('Use my location'));
    await tester.pumpAndSettle();

    expect(find.textContaining('turned off for Uns'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    expect(locator.openedSettings, isTrue);
    expect(find.text('Choose a city'), findsOneWidget);
  });

  testWidgets('manual city → prayer step with Asr choice → home', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    await _toLocationStep(tester);

    await tester.tap(find.text('Choose a city'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'mecca');
    await tester.pumpAndSettle();
    expect(find.text('Mecca Region, Saudi Arabia'), findsOneWidget);

    await tester.tap(find.text('Makkah'));
    await tester.pumpAndSettle();
    expect(find.text('Makkah, today. Updates as you choose.'), findsOneWidget);
    expect(find.text('2 OF 4'), findsOneWidget);
    expect(container.read(userLocationProvider)!.source, LocationSource.manual);

    // Makkah's times, in Makkah's zone, with the suggested method.
    expect(find.text('METHOD · UMM AL-QURA, MAKKAH'), findsOneWidget);
    for (final t in ['4:54', '12:13', '3:37', '6:16', '7:46']) {
      expect(find.text(t), findsOneWidget, reason: t);
    }

    await tester.tap(find.text('HANAFI'));
    await tester.pumpAndSettle();
    expect(container.read(prayerSettingsProvider).asr, AsrMethod.hanafi);
    expect(find.text('3:37'), findsNothing);
    expect(find.text('12:13'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('3 OF 4'), findsOneWidget);
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();
    expect(find.text('4 OF 4'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    // 06:00 in Makkah: Dhuhr is next.
    expect(find.text('WED, 23 SEP · MAKKAH'), findsOneWidget);
    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('12:13 · in 6h 13m'), findsOneWidget);
    expect(
      container
          .read(settingsStoreProvider)
          .readBool(SettingKeys.onboardingComplete),
      isTrue,
    );
  });

  testWidgets('after a restart, saved settings open straight to home', (
    tester,
  ) async {
    final store = (await tester.runAsync(memoryStore))!;
    store
      ..writeJson(SettingKeys.location, UserLocation.fromCity(makkah).toJson())
      ..writeJson(
        SettingKeys.prayer,
        const PrayerSettings(asr: AsrMethod.hanafi).toJson(),
      )
      ..writeBool(SettingKeys.onboardingComplete, true);
    await tester.runAsync(store.flush);

    final container = await pumpApp(tester, settings: store);
    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.text('WED, 23 SEP · MAKKAH'), findsOneWidget);
    expect(container.read(prayerSettingsProvider).asr, AsrMethod.hanafi);
  });

  testWidgets('unfinished onboarding starts at welcome again', (tester) async {
    final store = (await tester.runAsync(memoryStore))!;
    store.writeJson(
      SettingKeys.location,
      UserLocation.fromCity(makkah).toJson(),
    );
    await pumpApp(tester, settings: store);
    expect(find.text('Begin'), findsOneWidget);
  });

  testWidgets('step 3: pick prayers and sound, then ask permission', (
    tester,
  ) async {
    final permission = FakeNotificationPermission(allow: false);
    final container = await pumpApp(tester, notifications: permission);
    container
        .read(userLocationProvider.notifier)
        .set(UserLocation.fromCity(sydney));
    await _toLocationStep(tester);
    await tester.tap(find.text('Choose a city'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'sydney');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sydney'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('ALERT ME FOR'), findsOneWidget);
    expect(find.text('SOUND'), findsOneWidget);
    await tester.tap(find.text('ISHA'));
    await tester.tap(find.text('FAJR'));
    await tester.tap(find.text('SILENT'));
    await tester.pumpAndSettle();
    final alerts = container.read(alertSettingsProvider);
    expect(alerts.modeOf(Prayer.isha), AlertMode.silent);
    expect(alerts.modeOf(Prayer.fajr), AlertMode.off);
    expect(alerts.modeOf(Prayer.dhuhr), AlertMode.silent);

    // A "no" still moves on: notifications never block onboarding.
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();
    expect(permission.requests, 1);
    expect(find.text('4 OF 4'), findsOneWidget);

    expect(find.text('RECITER'), findsOneWidget);
    await tester.tap(find.text('AL-SUDAIS'));
    await tester.pumpAndSettle();
    expect(container.read(reciterProvider), Reciter.sudais);
  });
}
