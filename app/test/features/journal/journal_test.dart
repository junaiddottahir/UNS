import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;
import 'package:uns/core/quran/verse_ref.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/features/journal/journal_providers.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/shama/shama_session.dart';

import '../../support/test_app.dart';

/// Runs a short session through to the "How do you feel now?" screen.
Future<void> _toAfter(WidgetTester tester) async {
  await tester.tap(find.text('ANXIOUS'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Comfort me'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Begin'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('End session'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('CALMER'));
  await tester.pumpAndSettle();
}

Future<AppDatabase> _open(WidgetTester tester) async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final container = await pumpApp(tester, database: db);
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  container.read(appRouterProvider).go(Routes.shama);
  await tester.pumpAndSettle();
  return db;
}

void main() {
  testWidgets('write a reflection → saved → in the journal → entry', (
    tester,
  ) async {
    final db = await _open(tester);
    await _toAfter(tester);
    expect(find.text('CAPTURE A REFLECTION? · OPTIONAL'), findsOneWidget);

    await tester.tap(find.text('Write'));
    await tester.pumpAndSettle();
    expect(find.text("TODAY'S PROMPT"), findsOneWidget);
    expect(find.text('ONLY ON THIS PHONE'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'The verse about ease after hardship stayed with me today.',
    );
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Reflection saved to your journal'), findsOneWidget);

    final row = (await tester.runAsync(
      () => db.select(db.sessions).getSingle(),
    ))!;
    expect(row.reflection, startsWith('The verse about ease'));
    expect(row.moodAfter, 'calmer');

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('1 entry'), findsOneWidget);
    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();
    expect(find.text('ANXIOUS → CALMER'), findsOneWidget);
    expect(
      find.textContaining('The verse about ease after hardship'),
      findsOne,
    );

    await tester.tap(find.textContaining('The verse about ease'));
    await tester.pumpAndSettle();
    expect(find.text('Replay session'), findsOneWidget);
    expect(find.text('CALMER'), findsOneWidget);
    await tester.tap(find.text('Replay session'));
    await tester.pumpAndSettle();
    expect(find.textContaining('FROM QURAN API'), findsOneWidget);
  });

  testWidgets('a risky reflection still saves, then shows support', (
    tester,
  ) async {
    final db = await _open(tester);
    await _toAfter(tester);
    await tester.tap(find.text('Write'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'some days I want to die');
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text("You don't have to carry this alone"), findsOneWidget);
    final row = (await tester.runAsync(
      () => db.select(db.sessions).getSingle(),
    ))!;
    expect(row.reflection, 'some days I want to die');
  });

  testWidgets('Done without writing: "Session only"', (tester) async {
    await _open(tester);
    await _toAfter(tester);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();
    expect(find.text('Session only'), findsOneWidget);
  });

  group('replay', () {
    test('keeps only verses still in the approved library', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final player = FakeVersePlayer();
      final container = await containerFor(db, player: player);
      addTearDown(container.dispose);
      await container
          .read(shamaSessionProvider.notifier)
          .start(
            emotion: testLibrary().entries.first.emotion,
            comfort: true,
            minutes: 5,
            // 2:255 isn't in the test library.
            replay: [VerseRef(1, 3), VerseRef(2, 255), VerseRef(1, 1)],
          );
      expect(container.read(shamaSessionProvider)!.queue, [
        VerseRef(1, 3),
        VerseRef(1, 1),
      ]);
    });
  });

  test('versesOf parses and skips junk', () {
    final s = Session(
      id: 1,
      startedAt: DateTime(2026),
      emotion: 'hope',
      help: 'comfort',
      minutes: 5,
      verses: '2:286,x,94:5,0:1,',
      isReplay: false,
    );
    expect(versesOf(s), [VerseRef(2, 286), VerseRef(94, 5)]);
  });

  test('upgrading a version 4 database adds reflections', () async {
    final dir = Directory.systemTemp.createTempSync('uns_v4');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/v4.db');
    final v4 = AppDatabase(NativeDatabase(file));
    await v4.customSelect('SELECT 1').get(); // create at the current schema
    await v4.close();
    // Roll the file back to what unit 9 shipped: no reflection or voice.
    sqlite3.open(file.path)
      ..execute('ALTER TABLE sessions DROP COLUMN reflection;')
      ..execute('ALTER TABLE sessions DROP COLUMN voice_note;')
      ..execute('ALTER TABLE sessions DROP COLUMN voice_seconds;')
      ..execute('ALTER TABLE sessions DROP COLUMN is_replay;')
      ..execute(
        "INSERT INTO sessions (started_at, emotion, help, minutes, verses) "
        "VALUES (0, 'hope', 'comfort', 5, '1:1');",
      )
      ..execute('PRAGMA user_version = 4;')
      ..close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);
    final row = await upgraded.select(upgraded.sessions).getSingle();
    expect(row.reflection, isNull);
    expect(row.emotion, 'hope');
  });

  test('upgrading a version 5 database adds voice notes', () async {
    final dir = Directory.systemTemp.createTempSync('uns_v5');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/v5.db');
    final current = AppDatabase(NativeDatabase(file));
    await current.customSelect('SELECT 1').get();
    await current.close();
    sqlite3.open(file.path)
      ..execute('ALTER TABLE sessions DROP COLUMN voice_note;')
      ..execute('ALTER TABLE sessions DROP COLUMN voice_seconds;')
      ..execute('ALTER TABLE sessions DROP COLUMN is_replay;')
      ..execute(
        "INSERT INTO sessions (started_at, emotion, help, minutes, reflection) "
        "VALUES (0, 'hope', 'comfort', 5, 'kept');",
      )
      ..execute('PRAGMA user_version = 5;')
      ..close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);
    final row = await upgraded.select(upgraded.sessions).getSingle();
    expect(row.reflection, 'kept');
    expect(row.voiceNote, isNull);
  });
}
