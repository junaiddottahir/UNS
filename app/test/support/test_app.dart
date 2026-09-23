import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/alerts/alert_providers.dart';
import 'package:uns/features/alerts/notification_permission.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/city_repository.dart';
import 'package:uns/features/location/device_locator.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/prayer/prayer_providers.dart';
import 'package:uns/features/qibla/compass_source.dart';
import 'package:uns/features/qibla/qibla_providers.dart';
import 'package:uns/main.dart';

const sydney = City(
  name: 'Sydney',
  region: 'New South Wales',
  countryCode: 'AU',
  countryName: 'Australia',
  latitude: -33.8678,
  longitude: 151.2073,
  timeZone: 'Australia/Sydney',
  population: 5638830,
  searchKeys: ['sydney'],
);

const makkah = City(
  name: 'Makkah',
  region: 'Mecca Region',
  countryCode: 'SA',
  countryName: 'Saudi Arabia',
  latitude: 21.4266,
  longitude: 39.8256,
  timeZone: 'Asia/Riyadh',
  population: 1578722,
  searchKeys: ['makkah', 'la mecca', 'مكه'],
);

/// 03:00 UTC on 23 Sep 2026: 13:00 in Sydney, 06:00 in Makkah.
final testNow = DateTime.utc(2026, 9, 23, 3);

class FakeLocator implements DeviceLocator {
  FakeLocator(this.result);
  final DeviceLocationResult result;
  bool openedSettings = false;

  @override
  Future<DeviceLocationResult> locate() async => result;

  @override
  Future<void> openSettings() async => openedSettings = true;
}

/// A clock that never ticks, so tests can settle.
class FixedClock extends MinuteClock {
  FixedClock(this.now);
  final DateTime now;

  @override
  DateTime build() => now;
}

class FakeNotificationPermission implements NotificationPermission {
  FakeNotificationPermission({this.allow = true, this.granted = true});
  final bool allow;
  bool granted;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<bool> request() async {
    requests++;
    granted = allow;
    return allow;
  }

  @override
  Future<bool> isGranted() async => granted;

  @override
  Future<void> openSettings() async => settingsOpened++;
}

/// Records what would be scheduled with the OS.
class FakeAlertScheduler implements AlertScheduler {
  List<ScheduledNotification> pending = const [];

  @override
  Future<void> replaceAll(List<ScheduledNotification> notifications) async =>
      pending = notifications;
}

/// A compass the test drives by adding states.
class FakeCompass implements CompassSource {
  final states = StreamController<CompassState>.broadcast();
  int locationRequests = 0;

  @override
  Stream<CompassState> watch(double latitude, double longitude) =>
      states.stream;

  @override
  Future<void> allowLocation({required bool openSettings}) async =>
      locationRequests++;
}

/// A settings store on an in-memory database.
Future<SettingsStore> memoryStore() async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return SettingsStore.load(db);
}

/// Pumps the app on a phone-sized screen with fake location and time.
/// Pass [settings] to start with saved settings, as after a restart.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  DeviceLocator? locator,
  DateTime? now,
  SettingsStore? settings,
  NotificationPermission? notifications,
  AlertScheduler? scheduler,
  CompassSource? compass,
  AppDatabase? database,
}) async {
  // Reduced motion, so the pulsing mood button lets frames settle.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final store = settings ?? await tester.runAsync(memoryStore);
  final db = database ?? AppDatabase(NativeDatabase.memory());
  if (database == null) addTearDown(db.close);
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      settingsStoreProvider.overrideWithValue(store!),
      deviceLocatorProvider.overrideWithValue(
        locator ?? FakeLocator(const DeviceLocationFailed()),
      ),
      cityRepositoryProvider.overrideWith(
        (ref) async => CityRepository([sydney, makkah]),
      ),
      nowProvider.overrideWith(() => FixedClock(now ?? testNow)),
      notificationPermissionProvider.overrideWithValue(
        notifications ?? FakeNotificationPermission(),
      ),
      alertSchedulerProvider.overrideWithValue(
        scheduler ?? FakeAlertScheduler(),
      ),
      compassSourceProvider.overrideWithValue(compass ?? FakeCompass()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const UnsApp()),
  );
  await tester.pumpAndSettle();
  return container;
}
