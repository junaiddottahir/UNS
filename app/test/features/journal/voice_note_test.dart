import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';

import '../../support/test_app.dart';

Future<void> _toRecord(
  WidgetTester tester, {
  FakeVoiceRecorder? recorder,
  FakeVault? vault,
  FakeNotePlayer? player,
  AppDatabase? db,
}) async {
  final container = await pumpApp(
    tester,
    recorder: recorder,
    vault: vault,
    notePlayer: player,
    database: db,
  );
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  container.read(appRouterProvider).go(Routes.shama);
  await tester.pumpAndSettle();
  await tester.tap(find.text('ANXIOUS'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Comfort me'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Begin'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('End session'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Record'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('record → save (encrypted) → journal → play', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final vault = FakeVault();
    final player = FakeNotePlayer();
    await _toRecord(tester, vault: vault, player: player, db: db);
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('ONLY ON THIS PHONE'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Start recording'));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('0:03'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('0:03'), findsOneWidget); // paused
    await tester.tap(find.bySemanticsLabel('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Reflection saved to your journal'), findsOneWidget);
    expect(vault.notes, hasLength(1));

    final row = (await tester.runAsync(
      () => db.select(db.sessions).getSingle(),
    ))!;
    expect(row.voiceNote, vault.notes.keys.single);
    expect(row.voiceSeconds, 3);
    expect(row.reflection, isNull);

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();
    expect(find.text('Voice reflection · 0:03'), findsOneWidget);
    await tester.tap(find.text('Voice reflection · 0:03'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voice reflection · 0:03'));
    await tester.pumpAndSettle();
    expect(player.played, hasLength(1));
  });

  testWidgets('discard starts over; nothing saved', (tester) async {
    final recorder = FakeVoiceRecorder();
    final vault = FakeVault();
    await _toRecord(tester, recorder: recorder, vault: vault);
    await tester.tap(find.bySemanticsLabel('Start recording'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('0:00'), findsOneWidget);
    expect(recorder.discards, 1);
    expect(vault.notes, isEmpty);
  });

  testWidgets('no microphone access: explains', (tester) async {
    await _toRecord(tester, recorder: FakeVoiceRecorder(allowed: false));
    await tester.tap(find.bySemanticsLabel('Start recording'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Allow the microphone'), findsOneWidget);
  });

  testWidgets('a note that can\'t be opened says so', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final vault = FakeVault();
    await _toRecord(tester, vault: vault, db: db);
    await tester.tap(find.bySemanticsLabel('Start recording'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.bySemanticsLabel('Save'));
    await tester.pumpAndSettle();
    vault.notes.clear(); // e.g. key lost after restoring to a new phone
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voice reflection · 0:01'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voice reflection · 0:01'));
    await tester.pumpAndSettle();
    expect(find.textContaining("can't be opened"), findsOneWidget);
  });
}
