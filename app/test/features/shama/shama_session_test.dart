import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/duas/dua_repository.dart';
import 'package:uns/core/quran/quran_providers.dart';
import 'package:uns/core/quran/verse_ref.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/library/verse_library.dart';
import 'package:uns/features/prayer/prayer_providers.dart';
import 'package:uns/features/shama/ambient_player.dart';
import 'package:uns/features/shama/shama_session.dart';
import 'package:uns/features/shama/verse_player.dart';

import '../../support/test_app.dart';

void main() {
  late AppDatabase db;
  late FakeVersePlayer player;
  late FakeAmbientPlayer ambient;
  late ProviderContainer container;

  Future<void> setUpWith({
    VerseLibrary? library,
    bool noLibrary = false,
    FakeQuran? quran,
    FakeRecitations? recitations,
    FakeDuas? duas,
  }) async {
    db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    player = FakeVersePlayer();
    ambient = FakeAmbientPlayer();
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
        duaRepositoryProvider.overrideWithValue(duas ?? FakeDuas()),
        ambientPlayerProvider.overrideWithValue(ambient),
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

  /// The queue's verses, in order.
  List<VerseRef> verses() => [
    for (final item in state().queue)
      if (item is VerseItem) item.ref,
  ];

  test('plays only the chosen help\'s approved verses', () async {
    await setUpWith();
    await start();
    expect(state().phase, SessionPhase.playing);
    expect(verses().toSet(), {VerseRef(1, 1), VerseRef(1, 2), VerseRef(1, 3)});
    expect(
      (state().content! as VerseContent).text.arabic,
      'arabic ${verses().first}',
    );
    expect(player.playing, isTrue);

    await start(comfort: false);
    expect(verses(), [VerseRef(1, 4)]);
  });

  test('goes verse to verse, round again, until the time is up', () async {
    await setUpWith();
    await start(minutes: 5); // 3 verses of 90 s are 4½ min: one more.
    final queue = verses();
    for (var i = 0; i < 3; i++) {
      expect(state().index, i);
      player.finishVerse();
      await settle();
    }
    expect(state().phase, SessionPhase.playing);
    expect(state().index, 0);
    player.finishVerse();
    await settle();
    expect(state().phase, SessionPhase.finished);
    expect(state().played, [...queue, queue.first]);
    expect(state().elapsed, const Duration(seconds: 360));

    final row = await (db.select(db.sessions)).getSingle();
    expect(row.verses, [...queue, queue.first].join(','));
    expect(row.help, 'comfort');
    expect(row.minutes, 5);
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
    expect(state().queue[state().index], isNot(VerseItem(VerseRef(1, 1))));

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

  group('duas', () {
    final duas = [
      testDua(1),
      testDua(2, category: 'protection'),
      testDua(3, category: 'food'), // not for anxiety
      testDua(4, category: 'grief'), // sadness, not anxiety
    ];

    test('interleave: a dua after every two verses', () {
      final items = interleave(
        [VerseRef(1, 1), VerseRef(1, 2), VerseRef(1, 3), VerseRef(1, 4)],
        [testDua(1), testDua(2)],
      );
      expect(items.map((i) => '$i'), [
        '1:1',
        '1:2',
        'dua 1',
        '1:3',
        '1:4',
        'dua 2',
      ]);
      expect(interleave([], [testDua(1)]), [DuaItem(testDua(1))]);
    });

    test('recited first: verses and Quran duas, then duas to read', () {
      final quran1 = testDua(10, source: 'Quran 21:87');
      final quran2 = testDua(11, source: 'Quran 3:173, Sahih Al-Bukhari');
      final items = sessionQueue(
        [VerseRef(1, 1), VerseRef(1, 2)],
        [testDua(1), quran1, testDua(2), quran2],
      );
      expect(items.map((i) => '$i'), [
        '1:1',
        '1:2',
        'dua 10',
        'dua 11',
        'dua 1',
        'dua 2',
      ]);
      expect(sessionQueue([], [testDua(1), quran1]).map((i) => '$i'), [
        'dua 10',
        'dua 1',
      ]);
    });

    test('left tap goes back a step even well into it', () async {
      await setUpWith();
      await start(minutes: 30);
      await session().next();
      player.advance(const Duration(seconds: 30));
      await settle();
      await session().previous(restart: false);
      expect(state().index, 0);
      // At the first step it just starts it again.
      await session().previous(restart: false);
      expect(state().index, 0);
    });

    test(
      'with no approved verses, a session is duas for the feeling',
      () async {
        await setUpWith(
          library: testLibrary(placeholder: true),
          duas: FakeDuas(duas),
        );
        await start();
        expect(state().phase, SessionPhase.playing);
        expect(state().queue.map((i) => (i as DuaItem).dua.id).toSet(), {1, 2});
        expect(state().content, isA<DuaContent>());
        expect(player.opened, isEmpty);
      },
    );

    test('verses and duas mix when both are there', () async {
      await setUpWith(duas: FakeDuas(duas));
      await start();
      expect(state().queue.whereType<VerseItem>(), hasLength(3));
      // Both anxiety duas are to read, so they come after the verses.
      expect(state().queue.whereType<DuaItem>(), hasLength(2));
      expect(state().queue.take(3), everyElement(isA<VerseItem>()));
    });

    test('offline with no copy of the duas and no verses', () async {
      await setUpWith(
        library: testLibrary(placeholder: true),
        duas: FakeDuas(const [], true),
      );
      await start();
      expect(state().unavailable, Unavailable.offline);
    });

    test('reading time: slow reading, longer when repeated', () {
      expect(readingTime(testDua(1)), const Duration(seconds: 20));
      final long = testDua(1, repeat: 3);
      expect(readingTime(long), const Duration(seconds: 30));
      expect(
        readingTime(testDua(1, repeat: 100)).inSeconds,
        lessThanOrEqualTo(90),
      );
    });

    test('a dua from the Quran knows its verses', () {
      expect(
        testDua(
          1,
          source: 'Quran 2:285-286, Sahih Al-Bukhari 5:345',
        ).quranVerses,
        [VerseRef(2, 285), VerseRef(2, 286)],
      );
      expect(testDua(1, source: 'Quran 27:19, 46:15').quranVerses, [
        VerseRef(27, 19),
      ]);
      expect(testDua(1, source: 'Sahih Muslim 4:2092').quranVerses, isEmpty);
      expect(testDua(1, source: 'Quran 1:9').quranVerses, isEmpty);
    });

    test('a Quran dua plays its recitation, verse by verse', () async {
      await setUpWith(
        library: testLibrary(placeholder: true),
        duas: FakeDuas([
          testDua(1, source: 'Quran 2:285-286, Sahih Al-Bukhari 5:345'),
        ]),
      );
      await start();
      final content = state().content! as DuaContent;
      expect(content.recited, isTrue);
      expect(hasRecitation(content), isTrue);
      expect(player.opened, hasLength(1));
      expect(player.playing, isTrue);
      expect(ambient.playing, isFalse);

      player.finishVerse(); // 2:285 → 2:286, same step
      await settle();
      expect(player.opened, hasLength(2));
      expect(state().completed, 0);
      player.finishVerse(); // the dua is done
      await settle();
      expect(state().completed, 1);
      expect(state().elapsed, const Duration(seconds: 180));
    });

    test('offline, a Quran dua without its recitation is read', () async {
      await setUpWith(
        library: testLibrary(placeholder: true),
        duas: FakeDuas([testDua(1, source: 'Quran 21:87')]),
        recitations: FakeRecitations(offline: true),
      );
      await start();
      expect((state().content! as DuaContent).recited, isFalse);
      expect(ambient.playing, isTrue);
    });

    testWidgets('a dua runs on a timer, pauses, and the session goes on', (
      tester,
    ) async {
      await tester.runAsync(
        () => setUpWith(
          library: testLibrary(placeholder: true),
          duas: FakeDuas(duas),
        ),
      );
      await session().start(
        emotion: Emotion.anxiety,
        comfort: true,
        minutes: 1,
      );
      await tester.pump();
      final first = state().index;
      expect(ambient.playing, isTrue);
      expect(hasRecitation(state().content), isFalse);
      await tester.pump(const Duration(seconds: 10));
      expect(state().position, const Duration(seconds: 10));

      await session().togglePause();
      expect(ambient.playing, isFalse);
      await tester.pump(const Duration(seconds: 30));
      expect(state().position, const Duration(seconds: 10));
      await session().togglePause();
      expect(ambient.playing, isTrue);

      // 20 s each: the next dua, then round again, then the minute is up.
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();
      expect(state().index, isNot(first));
      expect(state().completed, 1);
      await tester.pump(const Duration(seconds: 20));
      await tester.pump();
      expect(state().completed, 2);
      expect(state().phase, SessionPhase.playing);
      await tester.pump(const Duration(seconds: 20));
      await tester.pump();
      expect(state().phase, SessionPhase.finished);
      expect(ambient.playing, isFalse);
      expect(state().played, isEmpty); // duas aren't journal verses
    });
  });
}
