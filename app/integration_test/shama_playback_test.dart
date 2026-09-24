import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uns/core/quran/verse_ref.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/library/verse_library.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/shama/shama_session.dart';
import 'package:uns/main.dart';

/// A real session on the device: real Quran text, real recitation audio,
/// real player. The library is a test-only list of references (the app
/// never plays a placeholder).
///   flutter test integration_test/shama_playback_test.dart -d SIMULATOR_ID
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
    dispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(dispatcher.clearAccessibilityFeaturesTestValue);
  });

  testWidgets('a session plays real recitation and shows the verse', (
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
        verseLibraryProvider.overrideWith(
          (ref) async => VerseLibrary(
            version: 'test',
            placeholder: false,
            entries: [
              LibraryEntry(VerseRef(1, 1), Emotion.hope, VerseTag.comfort),
              LibraryEntry(VerseRef(1, 2), Emotion.hope, VerseTag.comfort),
            ],
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const UnsApp()),
    );
    await tester.pump(const Duration(seconds: 1));

    await container
        .read(shamaSessionProvider.notifier)
        .start(emotion: Emotion.hope, comfort: true, minutes: 5);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      final s = container.read(shamaSessionProvider)!;
      if (s.position > const Duration(seconds: 2)) break;
    }
    final s = container.read(shamaSessionProvider)!;
    expect(s.phase, SessionPhase.playing);
    final verse = (s.content! as VerseContent).text;
    expect(verse.arabic, isNotEmpty);
    expect(verse.translation, isNotEmpty);
    expect(s.position, greaterThan(const Duration(seconds: 2)));

    await container.read(shamaSessionProvider.notifier).end();
    container.read(shamaSessionProvider.notifier).setMoodAfter('same');
    await container.read(shamaSessionProvider.notifier).save();
    final row = await db.select(db.sessions).getSingle();
    expect(row.verses, isNotEmpty);
    expect(row.moodAfter, 'same');
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
}
