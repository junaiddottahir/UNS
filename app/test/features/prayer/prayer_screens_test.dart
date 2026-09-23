import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/device_locator.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/prayer/prayer_providers.dart';
import 'package:uns/features/prayer/prayer_settings.dart';

import '../../support/test_app.dart';

/// Opens home with Sydney already chosen. 13:00 in Sydney: Asr is next.
Future<ProviderContainer> _home(
  WidgetTester tester, {
  DeviceLocator? locator,
  DateTime? now,
}) async {
  final container = await pumpApp(tester, locator: locator, now: now);
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  container.read(appRouterProvider).go(Routes.home);
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('home shows the next prayer and countdown', (tester) async {
    await _home(tester);
    expect(find.text('WED, 23 SEP · SYDNEY'), findsOneWidget);
    expect(find.text('Asr'), findsOneWidget);
    expect(find.text('3:15 · in 2h 15m'), findsOneWidget);
  });

  testWidgets("after Isha, home counts down to tomorrow's Fajr", (
    tester,
  ) async {
    // 11:00 UTC is 21:00 in Sydney.
    final now = DateTime.utc(2026, 9, 23, 11);
    final container = await _home(tester, now: now);
    final next = container.read(prayerScheduleProvider)!.next(now)!;
    expect((next.time.day, next.time.hour), (24, 4));
    final minutes = next.time.difference(now).inMinutes;
    expect(find.text('Fajr'), findsOneWidget);
    expect(
      find.text(
        '4:${next.time.minute.toString().padLeft(2, '0')} · '
        'in ${minutes ~/ 60}h ${minutes % 60}m',
      ),
      findsOneWidget,
    );
  });

  testWidgets('today list marks the next prayer and dims passed ones', (
    tester,
  ) async {
    await _home(tester);
    await tester.tap(find.text('Asr'));
    await tester.pumpAndSettle();

    expect(find.text('Wednesday, 23 September'), findsOneWidget);
    expect(find.text('SYDNEY, AU'), findsOneWidget);
    expect(find.text('NEXT · 2H 15M'), findsOneWidget);
    for (final t in ['4:21', '11:49', '3:15', '5:52', '7:10']) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    final fajrOpacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Fajr'), matching: find.byType(Opacity)),
    );
    expect(fajrOpacity.opacity, 0.45);
    expect(find.text('MUSLIM WORLD LEAGUE · STANDARD ASR'), findsOneWidget);
  });

  testWidgets('settings: change method, Asr and high latitude', (tester) async {
    final container = await _home(tester);
    await tester.tap(find.byTooltip('Prayer settings'));
    await tester.pumpAndSettle();
    expect(find.text('Prayer settings'), findsOneWidget);
    expect(find.text('Sydney'), findsOneWidget);

    await tester.tap(find.text('Muslim World League'));
    await tester.pumpAndSettle();
    expect(find.text('Calculation method'), findsOneWidget);
    expect(find.text('SUGGESTED FOR AUSTRALIA'), findsOneWidget);
    await tester.tap(find.text('ISNA (North America)'));
    await tester.pumpAndSettle();
    expect(container.read(prayerMethodProvider), PrayerMethod.isna);
    expect(find.text('ISNA (North America)'), findsOneWidget);

    await tester.tap(find.text('HANAFI'));
    await tester.tap(find.text('1/7TH'));
    await tester.pumpAndSettle();
    final settings = container.read(prayerSettingsProvider);
    expect(settings.asr, AsrMethod.hanafi);
    expect(settings.highLatitude, HighLatitudeMethod.seventhOfNight);
  });

  testWidgets('settings: change city, method follows the new country', (
    tester,
  ) async {
    final container = await _home(tester);
    await tester.tap(find.byTooltip('Prayer settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sydney'));
    await tester.pumpAndSettle();

    expect(find.text('Current location'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'makkah');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Makkah'));
    await tester.pumpAndSettle();

    expect(find.text('Prayer settings'), findsOneWidget);
    expect(find.text('Makkah'), findsOneWidget);
    expect(find.text('Umm al-Qura, Makkah'), findsOneWidget);
    expect(container.read(userLocationProvider)!.city.name, 'Makkah');
  });

  testWidgets('settings: current location uses the device position', (
    tester,
  ) async {
    final container = await _home(
      tester,
      locator: FakeLocator(const DeviceLocationFound(21.42, 39.82)),
    );
    await tester.tap(find.byTooltip('Prayer settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sydney'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Current location'));
    await tester.pumpAndSettle();

    expect(find.text('Prayer settings'), findsOneWidget);
    final location = container.read(userLocationProvider)!;
    expect(location.source, LocationSource.device);
    expect(location.city.name, 'Makkah');
  });
}
