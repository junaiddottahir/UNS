import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/city_repository.dart';
import 'package:uns/features/location/device_locator.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/prayer/prayer_providers.dart';
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
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final store = settings ?? await tester.runAsync(memoryStore);
  final container = ProviderContainer(
    overrides: [
      settingsStoreProvider.overrideWithValue(store!),
      deviceLocatorProvider.overrideWithValue(
        locator ?? FakeLocator(const DeviceLocationFailed()),
      ),
      cityRepositoryProvider.overrideWith(
        (ref) async => CityRepository([sydney, makkah]),
      ),
      nowProvider.overrideWith(() => FixedClock(now ?? testNow)),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const UnsApp()),
  );
  await tester.pumpAndSettle();
  return container;
}
