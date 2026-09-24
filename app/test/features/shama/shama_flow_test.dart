import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';

import '../../support/test_app.dart';

void main() {
  testWidgets('chip → comfort → 5 min → play → end → mood → saved', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final player = FakeVersePlayer();
    final container = await pumpApp(tester, database: db, versePlayer: player);
    container
        .read(userLocationProvider.notifier)
        .set(UserLocation.fromCity(sydney));
    container.read(appRouterProvider).go(Routes.shama);
    await tester.pumpAndSettle();

    expect(find.text('How are you feeling?'), findsOneWidget);
    // Chips hug their labels, several to a row.
    final chip = find.ancestor(
      of: find.text('ANXIOUS'),
      matching: find.byType(Material),
    );
    expect(tester.getSize(chip.first).width, lessThan(200));
    await tester.tap(find.text('ANXIOUS'));
    await tester.pumpAndSettle();
    expect(find.text('FEELING ANXIOUS'), findsOneWidget);

    await tester.tap(find.text('Comfort me'));
    await tester.pumpAndSettle();
    expect(find.text('ANXIOUS · COMFORT'), findsOneWidget);
    expect(find.textContaining('We recommend 10 minutes'), findsOneWidget);
    await tester.tap(find.text('5 MIN'));
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();

    // Arabic above the translation, each with its source.
    expect(find.textContaining('arabic 1:'), findsOneWidget);
    expect(find.textContaining('translation 1:'), findsOneWidget);
    expect(find.text('ARABIC · UTHMANI · FROM QURAN API'), findsOneWidget);
    expect(find.text('TRANSLATION · SAHIH INTERNATIONAL'), findsOneWidget);
    expect(find.text('MISHARY ALAFASY'), findsOneWidget);
    expect(find.text('−5:00'), findsOneWidget);

    player.advance(const Duration(seconds: 65));
    await tester.pump(); // deliver the position
    await tester.pump(); // redraw with it
    expect(find.text('1:05'), findsOneWidget);
    expect(find.text('−3:55'), findsOneWidget);

    await tester.tap(find.byTooltip('End session'));
    await tester.pumpAndSettle();
    expect(find.text('How do you feel now?'), findsOneWidget);
    expect(find.text('BEFORE · ANXIOUS'), findsOneWidget);

    await tester.tap(find.text('CALMER'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.text('Session saved'), findsOneWidget);

    final row = await tester.runAsync(() => db.select(db.sessions).getSingle());
    expect(row!.emotion, 'anxiety');
    expect(row.moodAfter, 'calmer');
    expect(row.verses, isNotEmpty);
  });

  testWidgets('before the scholar\'s verses, a session is duas to read', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      library: testLibrary(placeholder: true),
      duas: FakeDuas([testDua(1, repeat: 3), testDua(2)]),
    );
    container.read(appRouterProvider).go(Routes.shama);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ANXIOUS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comfort me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Begin'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('DUA · DUA '), findsOneWidget);
    expect(find.text('READ ALONG'), findsOneWidget);
    expect(find.textContaining('VIA UMMAHAPI'), findsOneWidget);
    // Read-only: no audio controls.
    expect(find.bySemanticsLabel('Pause'), findsNothing);
    expect(find.bySemanticsLabel('Next'), findsNothing);
    await tester.tap(find.byTooltip('End session'));
    await tester.pumpAndSettle();
  });

  testWidgets('offline with nothing downloaded: says to connect once', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      noLibrary: true,
      duas: FakeDuas(const [], true),
    );
    container.read(appRouterProvider).go(Routes.shama);
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAD'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comfort me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Connect to the internet'), findsOneWidget);
  });

  testWidgets('home mood button opens Shama', (tester) async {
    final container = await pumpApp(tester);
    container
        .read(userLocationProvider.notifier)
        .set(UserLocation.fromCity(sydney));
    container.read(appRouterProvider).go(Routes.home);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Tell us how you feel'));
    await tester.pumpAndSettle();
    expect(find.text('How are you feeling?'), findsOneWidget);
    expect(find.byType(Wrap), findsWidgets);
  });
}
