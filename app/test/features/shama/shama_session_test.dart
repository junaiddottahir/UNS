import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/quran/quran_providers.dart';
import 'package:uns/core/quran/verse_ref.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/library/verse_library.dart';
import 'package:uns/features/prayer/prayer_providers.dart';
import 'package:uns/features/shama/shama_session.dart';
import 'package:uns/features/shama/verse_player.dart';

import '../../support/test_app.dart';

void main() {
  late AppDatabase db;
  late FakeVersePlayer player;
  late ProviderContainer container;

  Future<void> setUpWith({
    VerseLibrary? library,
    bool noLibrary = false,
    FakeQuran? quran,
    FakeRecitations? recitations,
  }) async {
    db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    player = FakeVersePlayer();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsStoreProvider.overrideWithValue(await SettingsStore.load(db)),
        nowProvider.overrideWith(() => FixedClock(testNow)),
        versePlayerProvider.overrideWithValue(player),
        verseLibraryProvider.overrideWith(
          (ref) async => noLibrary ? null : (library ?? testLibrary()),
        ),
        sessionRandomProvider.overrideWithValue(Random(1)),
        quranRepositoryProvider.overrideWithValue(quran ?? FakeQuran()),
        recitationRepositoryProvider.overrideWithValue(
          recitations ?? FakeRecitations(),
        ),
      ],
    );
    addTearDown(container.dispose);
  }

  ShamaSessionNotifier session() =>
      container.read(shamaSessionProvider.notifier);
  SessionState state() => container.read(shamaSessionProvider)!;

  Future<void> start({bool comfort = true, int minutes = 5}) => session().start(
    emotion: Emotion.anxiety,
    comfort: comfort,
    minutes: minutes,
  );

  Future<void> settle() => pumpEventQueue();

  test('plays only the chosen help\'s approved verses', () async {
    await setUpWith();
    await start();
    expect(state().phase, SessionPhase.playing);
    expect(state().queue.toSet(), {
      VerseRef(1, 1),
      VerseRef(1, 2),
      VerseRef(1, 3),
    });
    expect(state().verse!.arabic, 'arabic ${state().queue.first}');
    expect(player.playing, isTrue);

    await start(comfort: false);
    expect(state().queue, [VerseRef(1, 4)]);
  });

  test('moves verse to verse, then ends when they run out', () async {
    await setUpWith();
    await start(minutes: 30);
    final queue = state().queue;
    for (var i = 0; i < 3; i++) {
      expect(state().index, i);
      player.finishVerse();
      await settle();
    }
    expect(state().phase, SessionPhase.finished);
    expect(state().played, queue);
    expect(state().elapsed, const Duration(seconds: 270));

    final row = await (db.select(db.sessions)).getSingle();
    expect(row.verses, queue.join(','));
    expect(row.help, 'comfort');
    expect(row.minutes, 30);
  });

  test('ends at the chosen time, after the verse playing then', () async {
    await setUpWith();
    player.verseLength = const Duration(minutes: 3);
    await start(minutes: 5);
    player.finishVerse(); // 3 min
    await settle();
    expect(state().phase, SessionPhase.playing);
    player.finishVerse(); // 6 min ≥ 5
    await settle();
    expect(state().phase, SessionPhase.finished);
    expect(state().played, hasLength(2));
    expect(state().progress, 1);
    expect(state().remaining, Duration.zero);
  });

  test('pause, next, previous and end', () async {
    await setUpWith();
    await start(minutes: 30);
    await session().togglePause();
    expect(state().phase, SessionPhase.paused);
    expect(player.playing, isFalse);
    await session().togglePause();
    expect(state().phase, SessionPhase.playing);

    player.advance(const Duration(seconds: 20));
    await settle();
    await session().next();
    expect(state().index, 1);
    expect(state().elapsed, const Duration(seconds: 20));

    // Just started: previous goes back a verse.
    await session().previous();
    expect(state().index, 0);

    // Well into it: previous restarts it.
    player.advance(const Duration(seconds: 10));
    await settle();
    await session().previous();
    expect(state().index, 0);

    await session().end();
    expect(state().phase, SessionPhase.finished);
  });

  test('a placeholder library never plays', () async {
    await setUpWith(library: testLibrary(placeholder: true));
    await start();
    expect(state().phase, SessionPhase.unavailable);
    expect(state().unavailable, Unavailable.notApproved);
    expect(player.opened, isEmpty);
    expect(await db.select(db.sessions).get(), isEmpty);
  });

  test('offline: skips verses not cached; none at all → offline', () async {
    await setUpWith(quran: FakeQuran(offlineRefs: {VerseRef(1, 1)}));
    await start();
    expect(state().phase, SessionPhase.playing);
    expect(state().queue[state().index], isNot(VerseRef(1, 1)));

    await setUpWith(recitations: FakeRecitations(offline: true));
    await start();
    expect(state().unavailable, Unavailable.offline);

    await setUpWith(noLibrary: true);
    await start();
    expect(state().unavailable, Unavailable.offline);
  });

  test('save records the mood after and clears the session', () async {
    await setUpWith();
    await start();
    await session().end();
    session().setMoodAfter('calmer');
    await session().save();
    expect(container.read(shamaSessionProvider), isNull);
    final row = await (db.select(db.sessions)).getSingle();
    expect(row.moodAfter, 'calmer');
    expect(row.endedAt, isNotNull);
  });
}
