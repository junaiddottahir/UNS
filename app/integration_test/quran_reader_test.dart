import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/quran/surah_recitation.dart';
import 'package:uns/main.dart';

/// The Quran tab on the device: real surah text from the Quran API, real
/// recitation, real player.
///   flutter test integration_test/quran_reader_test.dart -d SIMULATOR_ID
/// Set UNS_TOUR_PAUSE=1 (dart-define) to hold each screen for screenshots.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const pause = bool.fromEnvironment('UNS_TOUR_PAUSE');

  Future<void> hold(String screen) async {
    if (!pause) return;
    // ignore: avoid_print
    print('TOUR $screen');
    await Future<void>.delayed(const Duration(seconds: 3));
  }

  setUp(() {
    final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
    dispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(dispatcher.clearAccessibilityFeaturesTestValue);
  });

  testWidgets('reads and recites a surah from the real sources', (
    tester,
  ) async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/${AppDatabase.fileName}');
    if (file.existsSync()) file.deleteSync();
    final db = await AppDatabase.open();
    final store = await SettingsStore.load(db);
    const sydney = City(
      name: 'Sydney',
      region: 'New South Wales',
      countryCode: 'AU',
      countryName: 'Australia',
      latitude: -33.8678,
      longitude: 151.2073,
      timeZone: 'Australia/Sydney',
      population: 1,
    );
    store
      ..writeJson(SettingKeys.location, UserLocation.fromCity(sydney).toJson())
      ..writeBool(SettingKeys.onboardingComplete, true);
    await store.flush();

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const UnsApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Quran'));
    await tester.pumpAndSettle();
    expect(find.text('Al-Faatiha'), findsOneWidget);
    await hold('list');

    container.read(appRouterProvider).push(Routes.quranSurah(112));
    await tester.pumpAndSettle();
    // Al-Ikhlas: 4 verses, fetched whole from the API.
    for (var i = 0; i < 100 && find.text('Al-Ikhlaas').evaluate().isEmpty;) {
      await tester.pump(const Duration(milliseconds: 200));
      i++;
    }
    await tester.pumpAndSettle();
    expect(find.textContaining('4 verses'), findsOneWidget);
    await hold('reader');

    await tester.tap(find.text('LISTEN'));
    final recitation = surahRecitationProvider(112);
    for (var i = 0; i < 150 && !container.read(recitation).playing; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(container.read(recitation).playing, isTrue);
    expect(container.read(recitation).ayah, 1);
    await tester.pumpAndSettle();
    await hold('playing');

    // Verse 1 plays to its end and verse 2 follows by itself.
    for (var i = 0; i < 150 && container.read(recitation).ayah == 1; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(container.read(recitation).ayah, 2);
    await tester.pumpAndSettle();
    await hold('next');

    await tester.tap(find.byTooltip('Stop'));
    await tester.pumpAndSettle();
    expect(container.read(recitation).ayah, isNull);
  });
}
