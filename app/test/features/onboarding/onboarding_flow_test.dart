import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/city_repository.dart';
import 'package:uns/features/location/device_locator.dart';
import 'package:uns/features/location/location_providers.dart';
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
  searchKeys: ['sydney'],
);

const _makkah = City(
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

class _FakeLocator implements DeviceLocator {
  _FakeLocator(this.result);
  final DeviceLocationResult result;
  bool openedSettings = false;

  @override
  Future<DeviceLocationResult> locate() async => result;

  @override
  Future<void> openSettings() async => openedSettings = true;
}

Future<ProviderContainer> _pumpApp(
  WidgetTester tester,
  DeviceLocator locator,
) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      deviceLocatorProvider.overrideWithValue(locator),
      cityRepositoryProvider.overrideWith(
        (ref) async => CityRepository([_sydney, _makkah]),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const UnsApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

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
    await _pumpApp(tester, _FakeLocator(const DeviceLocationFailed()));
    expect(find.text('ASSALAMU ALAYKUM'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
  });

  testWidgets('intro slides advance with the arrow to location', (
    tester,
  ) async {
    await _pumpApp(tester, _FakeLocator(const DeviceLocationFailed()));
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
    final container = await _pumpApp(
      tester,
      _FakeLocator(const DeviceLocationFound(-33.8568, 151.2153)),
    );
    await _toLocationStep(tester);

    await tester.tap(find.text('Use my location'));
    await tester.pumpAndSettle();

    expect(find.text('Your prayer times'), findsOneWidget);
    expect(find.text('Sydney, today. Updates as you choose.'), findsOneWidget);
    final location = container.read(userLocationProvider)!;
    expect(location.source, LocationSource.device);
    expect(location.latitude, -33.8568);
  });

  testWidgets('permanently denied shows Settings link and city fallback', (
    tester,
  ) async {
    final locator = _FakeLocator(const DeviceLocationDenied(permanently: true));
    await _pumpApp(tester, locator);
    await _toLocationStep(tester);

    await tester.tap(find.text('Use my location'));
    await tester.pumpAndSettle();

    expect(find.textContaining('turned off for Uns'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    expect(locator.openedSettings, isTrue);
    expect(find.text('Choose a city'), findsOneWidget);
  });

  testWidgets('manual city search through to home', (tester) async {
    final container = await _pumpApp(
      tester,
      _FakeLocator(const DeviceLocationFailed()),
    );
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

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('3 OF 4'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('4 OF 4'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('MAKKAH, SA'), findsOneWidget);
  });
}
