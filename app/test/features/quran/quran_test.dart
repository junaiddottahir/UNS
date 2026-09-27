import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:uns/core/quran/verse_ref.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';

import '../../support/test_app.dart';

Future<GoRouter> _openQuran(
  WidgetTester tester, {
  FakeVersePlayer? player,
  FakeQuran? quran,
  bool offlineAudio = false,
}) async {
  final container = await pumpApp(
    tester,
    quranPlayer: player,
    quran: quran,
    recitations: FakeRecitations(offline: offlineAudio),
  );
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  final router = container.read(appRouterProvider)..go(Routes.tasbih);
  await tester.pumpAndSettle();
  // The Quran tab sits after Tasbih.
  await tester.tap(find.bySemanticsLabel('Quran'));
  await tester.pumpAndSettle();
  return router;
}

Future<void> _openFatiha(WidgetTester tester) async {
  await tester.tap(find.text('Al-Faatiha'));
  await tester.pumpAndSettle();
}

void main() {
  test('the bundled surah list matches the Hafs verse counts', () {
    final surahs =
        jsonDecode(File('assets/data/surahs.json').readAsStringSync()) as List;
    expect(
      [for (final s in surahs) s['number']],
      [for (var n = 1; n <= 114; n++) n],
    );
    expect([for (final s in surahs) s['ayahs']], ayahCounts);
  });

  testWidgets('lists every surah and opens one to read', (tester) async {
    await _openQuran(tester);
    expect(find.text('Read and listen'), findsOneWidget);
    expect(find.text('The Opening · 7 verses'), findsOneWidget);

    await _openFatiha(tester);
    expect(find.text('SURAH 1'), findsOneWidget);
    expect(find.text('The Opening · 7 verses · Meccan'), findsOneWidget);
    expect(find.text('arabic 1:1'), findsOneWidget);
    expect(find.text('translation 1:1'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('translation 1:7'), 300);
    expect(find.text('arabic 1:7'), findsOneWidget);
  });

  testWidgets('listens verse by verse and stops after the last', (
    tester,
  ) async {
    final player = FakeVersePlayer();
    await _openQuran(tester, player: player);
    await _openFatiha(tester);

    await tester.tap(find.text('LISTEN'));
    await tester.pumpAndSettle();
    expect(player.opened.single, endsWith('/001001.mp3'));
    expect(player.playing, isTrue);
    expect(find.text('Verse 1'), findsOneWidget);

    player.finishVerse();
    await tester.pumpAndSettle();
    expect(player.opened.last, endsWith('/001002.mp3'));
    expect(find.text('Verse 2'), findsOneWidget);

    // Tapping a verse recites from there.
    await tester.scrollUntilVisible(find.text('translation 1:7'), 300);
    await tester.tap(find.text('translation 1:7'));
    await tester.pumpAndSettle();
    expect(player.opened.last, endsWith('/001007.mp3'));

    await tester.tap(find.byTooltip('Pause'));
    await tester.pumpAndSettle();
    expect(player.playing, isFalse);
    await tester.tap(find.byTooltip('Play'));
    await tester.pumpAndSettle();
    expect(player.playing, isTrue);

    player.finishVerse();
    await tester.pumpAndSettle();
    expect(player.playing, isFalse);
    expect(find.text('Verse 7'), findsNothing); // player bar gone
  });

  testWidgets('previous, next and stop', (tester) async {
    final player = FakeVersePlayer();
    await _openQuran(tester, player: player);
    await _openFatiha(tester);
    await tester.tap(find.text('translation 1:2'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(player.opened.last, endsWith('/001003.mp3'));
    await tester.tap(find.byTooltip('Previous'));
    await tester.pumpAndSettle();
    expect(player.opened.last, endsWith('/001002.mp3'));

    await tester.tap(find.byTooltip('Stop'));
    await tester.pumpAndSettle();
    expect(player.playing, isFalse);
    expect(find.text('Verse 2'), findsNothing);
  });

  testWidgets('leaving the surah stops the recitation', (tester) async {
    final player = FakeVersePlayer();
    await _openQuran(tester, player: player);
    await _openFatiha(tester);
    await tester.tap(find.text('LISTEN'));
    await tester.pumpAndSettle();
    expect(player.playing, isTrue);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Read and listen'), findsOneWidget);
    expect(player.playing, isFalse);
  });

  testWidgets('offline: says so, and the text can be retried', (tester) async {
    final quran = FakeQuran()..offlineSurahs = {1};
    await _openQuran(tester, quran: quran, offlineAudio: true);
    await _openFatiha(tester);
    expect(
      find.text(
        "Couldn't load this surah. Check your connection and try again.",
      ),
      findsOneWidget,
    );

    quran.offlineSurahs = {};
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('arabic 1:1'), findsOneWidget);

    await tester.tap(find.text('LISTEN'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "Couldn't load the recitation. Check your connection and try again.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('a link to a surah that does not exist shows the list', (
    tester,
  ) async {
    final router = await _openQuran(tester);
    router.push(Routes.quranSurah(115));
    await tester.pumpAndSettle();
    expect(find.text('Read and listen'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
