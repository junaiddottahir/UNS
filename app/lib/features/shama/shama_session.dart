import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/duas/dua.dart';
import '../../core/duas/dua_repository.dart';
import '../../core/quran/quran_providers.dart';
import '../../core/quran/quran_repository.dart';
import '../../core/quran/verse_ref.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/settings_store.dart';
import '../library/library_repository.dart';
import '../library/verse_library.dart';
import '../prayer/prayer_providers.dart';
import '../reciter/reciter.dart';
import 'ambient_player.dart';
import 'dua_categories.dart';
import 'session_store.dart';
import 'verse_player.dart';

/// Session lengths offered, in minutes; [recommendedMinutes] is marked.
const sessionMinutes = [5, 10, 15, 30];
const recommendedMinutes = 10;

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(
    ref.watch(httpClientProvider),
    ref.watch(settingsStoreProvider),
  ),
);

/// The library as known now: the cache, refreshed from the backend when
/// possible. Null when there's neither.
final verseLibraryProvider = FutureProvider<VerseLibrary?>(
  (ref) => ref.watch(libraryRepositoryProvider).refresh(),
);

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SessionStore(ref.watch(appDatabaseProvider)),
);

/// Random source for verse order; overridden in tests.
final sessionRandomProvider = Provider<Random>((ref) => Random());

enum SessionPhase { loading, playing, paused, finished, unavailable }

/// Why a session couldn't start.
enum Unavailable {
  /// Nothing approved for this feeling.
  notApproved,

  /// Offline, with nothing downloaded yet.
  offline,
}

/// One step of a session: a recited verse, or a dua to read.
sealed class SessionItem {
  const SessionItem();
}

class VerseItem extends SessionItem {
  const VerseItem(this.ref);

  final VerseRef ref;

  @override
  bool operator ==(Object other) => other is VerseItem && other.ref == ref;

  @override
  int get hashCode => ref.hashCode;

  @override
  String toString() => '$ref';
}

class DuaItem extends SessionItem {
  const DuaItem(this.dua);

  final Dua dua;

  @override
  bool operator ==(Object other) => other is DuaItem && other.dua.id == dua.id;

  @override
  int get hashCode => dua.id.hashCode;

  @override
  String toString() => 'dua ${dua.id}';
}

/// What's on screen now.
sealed class SessionContent {
  const SessionContent();
}

/// A verse, unchanged from the Quran API, with its recitation playing.
class VerseContent extends SessionContent {
  const VerseContent(this.text);

  final VerseText text;
}

/// A dua. When it's a Quran verse its recitation plays ([recited]);
/// otherwise it's read over a soft ambient sound for [length].
class DuaContent extends SessionContent {
  const DuaContent(this.dua, this.length, {this.recited = false});

  final Dua dua;
  final Duration length;
  final bool recited;
}

/// Whether Quran recitation plays for [c] (a verse, or a dua that is a
/// verse). Otherwise it's read, on a timer, with no audio controls.
bool hasRecitation(SessionContent? c) =>
    c is VerseContent || (c is DuaContent && c.recited);

/// How long a dua stays on screen: time to read it slowly, a little
/// longer when it's said more than once.
Duration readingTime(Dua dua) {
  final words = dua.translation.split(RegExp(r'\s+')).length;
  final once = 8 + words * 0.5;
  final seconds = (once * min(dua.repeat, 3)).clamp(20, 90);
  return Duration(seconds: seconds.round());
}

/// Verses with a dua after every two; either alone when the other is empty.
List<SessionItem> interleave(List<VerseRef> verses, List<Dua> duas) {
  if (verses.isEmpty) return [for (final d in duas) DuaItem(d)];
  final items = <SessionItem>[];
  var next = 0;
  for (final (i, v) in verses.indexed) {
    items.add(VerseItem(v));
    if (i.isOdd && next < duas.length) items.add(DuaItem(duas[next++]));
  }
  return items;
}

class SessionState {
  const SessionState({
    required this.emotion,
    required this.comfort,
    required this.minutes,
    this.replay = false,
    this.phase = SessionPhase.loading,
    this.queue = const [],
    this.index = 0,
    this.content,
    this.played = const [],
    this.completed = 0,
    this.elapsedBefore = Duration.zero,
    this.position = Duration.zero,
    this.unavailable,
    this.sessionId,
    this.moodAfter,
  });

  final Emotion emotion;
  final bool comfort;
  final int minutes;

  /// Replaying a journal entry: its verses once, in order.
  final bool replay;
  final SessionPhase phase;
  final List<SessionItem> queue;
  final int index;
  final SessionContent? content;

  /// Verses played, for the journal.
  final List<VerseRef> played;

  /// Steps (verses and duas) finished, across repeats of the queue.
  final int completed;

  /// Time spent in steps before the current one.
  final Duration elapsedBefore;

  /// Position within the current step.
  final Duration position;
  final Unavailable? unavailable;
  final int? sessionId;

  /// "How do you feel now?" answer, by name.
  final String? moodAfter;

  Duration get length => Duration(minutes: minutes);
  Duration get elapsed => elapsedBefore + position;
  Duration get remaining {
    final left = length - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  double get progress =>
      (elapsed.inMilliseconds / length.inMilliseconds).clamp(0, 1).toDouble();

  SessionState copyWith({
    SessionPhase? phase,
    List<SessionItem>? queue,
    int? index,
    SessionContent? content,
    List<VerseRef>? played,
    int? completed,
    Duration? elapsedBefore,
    Duration? position,
    Unavailable? unavailable,
    int? sessionId,
    String? moodAfter,
  }) => SessionState(
    emotion: emotion,
    comfort: comfort,
    minutes: minutes,
    replay: replay,
    phase: phase ?? this.phase,
    queue: queue ?? this.queue,
    index: index ?? this.index,
    content: content ?? this.content,
    played: played ?? this.played,
    completed: completed ?? this.completed,
    elapsedBefore: elapsedBefore ?? this.elapsedBefore,
    position: position ?? this.position,
    unavailable: unavailable ?? this.unavailable,
    sessionId: sessionId ?? this.sessionId,
    moodAfter: moodAfter ?? this.moodAfter,
  );
}

final shamaSessionProvider =
    NotifierProvider<ShamaSessionNotifier, SessionState?>(
      ShamaSessionNotifier.new,
    );

/// Runs a session like a meditation: approved verses (recited) and duas
/// (to read) for the feeling and help chosen, in a random order, going
/// round again until the chosen time is up (the step then showing
/// finishes). Only verses in the approved library ever play.
class ShamaSessionNotifier extends Notifier<SessionState?> {
  StreamSubscription<Duration>? _positions;
  StreamSubscription<void>? _completions;
  Timer? _reading;

  /// Which of a recited dua's verses is playing.
  int _duaVerse = 0;

  /// Bumped on every move, so a late completion from an old step is
  /// ignored.
  int _generation = 0;

  static const _tick = Duration(milliseconds: 250);

  @override
  SessionState? build() {
    ref.onDispose(() {
      _unsubscribe();
      _reading?.cancel();
    });
    return null;
  }

  VersePlayer get _player => ref.read(versePlayerProvider);
  AmbientPlayer get _ambient => ref.read(ambientPlayerProvider);

  /// Starts a session. With [replay], plays those verses in that order
  /// (from the journal), keeping only ones still in the approved library.
  Future<void> start({
    required Emotion emotion,
    required bool comfort,
    required int minutes,
    List<VerseRef>? replay,
  }) async {
    await _halt();
    state = SessionState(
      emotion: emotion,
      comfort: comfort,
      minutes: minutes,
      replay: replay != null,
    );

    final library = await ref.read(verseLibraryProvider.future);
    final approved = library == null || library.placeholder
        ? const <VerseRef>{}
        : {for (final e in library.entries) e.ref};
    final random = ref.read(sessionRandomProvider);
    final verses = replay != null
        ? [
            for (final r in replay)
              if (approved.contains(r)) r,
          ]
        : library == null || library.placeholder
        ? const <VerseRef>[]
        : ([...library.versesFor(emotion, comfort: comfort)]..shuffle(random));
    var duasOffline = false;
    final duas = <Dua>[];
    if (replay == null) {
      try {
        final categories = duaCategoriesFor(emotion, comfort: comfort);
        duas.addAll(
          (await ref.read(duaRepositoryProvider).all()).where(
            (d) => categories.contains(d.category),
          ),
        );
        duas.shuffle(random);
      } on Exception {
        duasOffline = true;
      }
    }

    final queue = interleave(verses, duas);
    if (queue.isEmpty) {
      state = state!.copyWith(
        phase: SessionPhase.unavailable,
        unavailable: library == null || duasOffline
            ? Unavailable.offline
            : Unavailable.notApproved,
      );
      return;
    }

    final id = await ref
        .read(sessionStoreProvider)
        .start(
          at: ref.read(nowProvider),
          emotion: emotion,
          comfort: comfort,
          minutes: minutes,
          replay: replay != null,
        );
    state = state!.copyWith(queue: queue, sessionId: id);
    _positions = _player.positions.listen((p) {
      final s = state;
      if (s != null &&
          s.phase == SessionPhase.playing &&
          hasRecitation(s.content)) {
        state = s.copyWith(position: p);
      }
    });
    _completions = _player.completions.listen((_) {
      switch (state?.content) {
        case VerseContent():
          unawaited(_onStepEnd());
        case DuaContent(recited: true):
          unawaited(_onDuaVerseEnd());
        default:
      }
    });
    await _playAt(0);
  }

  Future<void> _playAt(int index) async {
    final generation = ++_generation;
    var i = index;
    // Steps tried in a row without one working (offline, not cached).
    var failures = 0;
    final reciter = ref.read(reciterProvider).source;
    while (true) {
      final s = state;
      if (s == null) return;
      if (s.elapsed >= s.length) {
        await _end();
        return;
      }
      if (i >= s.queue.length) {
        // Round again until the time is up; a replay plays once.
        if (s.replay) {
          await _end();
          return;
        }
        i = 0;
      }
      if (failures >= s.queue.length) {
        if (s.completed == 0) {
          state = s.copyWith(
            phase: SessionPhase.unavailable,
            unavailable: Unavailable.offline,
          );
        } else {
          await _end();
        }
        return;
      }
      state = s.copyWith(index: i, phase: SessionPhase.loading);
      switch (s.queue[i]) {
        case DuaItem(:final dua):
          final verses = dua.quranVerses;
          if (verses.isNotEmpty) {
            try {
              final file = await ref
                  .read(recitationRepositoryProvider)
                  .audio(reciter, verses.first);
              if (generation != _generation) return;
              await _player.open(file);
              if (generation != _generation) return;
              _duaVerse = 0;
              state = state!.copyWith(
                content: DuaContent(dua, readingTime(dua), recited: true),
                position: Duration.zero,
                phase: SessionPhase.playing,
              );
              _player.play();
              return;
            } on Exception {
              if (generation != _generation) return;
              // No recitation offline: read it instead.
            }
          }
          state = state!.copyWith(
            content: DuaContent(dua, readingTime(dua)),
            position: Duration.zero,
            phase: SessionPhase.playing,
          );
          _startReading();
          return;
        case VerseItem(ref: final verseRef):
          try {
            final (text, file) = await (
              ref.read(quranRepositoryProvider).verse(verseRef),
              ref.read(recitationRepositoryProvider).audio(reciter, verseRef),
            ).wait;
            if (generation != _generation) return;
            await _player.open(file);
            if (generation != _generation) return;
            state = state!.copyWith(
              content: VerseContent(text),
              position: Duration.zero,
              phase: SessionPhase.playing,
            );
            _player.play();
            return;
          } on Object catch (e) {
            if (generation != _generation) return;
            if (e is! Exception && e is! ParallelWaitError) rethrow;
            // Not cached and can't be fetched (offline): try the next one.
            i++;
            failures++;
          }
      }
    }
  }

  /// A recited dua spanning several verses plays them in turn.
  Future<void> _onDuaVerseEnd() async {
    final s = state;
    final content = s?.content;
    if (s == null || s.phase != SessionPhase.playing) return;
    if (content is! DuaContent) return;
    final verses = content.dua.quranVerses;
    if (_duaVerse + 1 >= verses.length) return _onStepEnd();
    final generation = _generation;
    _duaVerse++;
    state = s.copyWith(
      elapsedBefore: s.elapsedBefore + s.position,
      position: Duration.zero,
    );
    try {
      final file = await ref
          .read(recitationRepositoryProvider)
          .audio(ref.read(reciterProvider).source, verses[_duaVerse]);
      if (generation != _generation) return;
      await _player.open(file);
      if (generation != _generation) return;
      _player.play();
    } on Exception {
      if (generation == _generation) await _onStepEnd();
    }
  }

  /// A dua without recitation: its time runs on a timer while not paused,
  /// with the ambient sound under it.
  void _startReading() {
    _reading?.cancel();
    _ambient.play();
    final generation = _generation;
    _reading = Timer.periodic(_tick, (_) {
      final s = state;
      if (s == null || generation != _generation) {
        _reading?.cancel();
        return;
      }
      if (s.phase != SessionPhase.playing) return;
      final content = s.content;
      if (content is! DuaContent) return;
      final position = s.position + _tick;
      state = s.copyWith(position: position);
      if (position >= content.length) {
        _reading?.cancel();
        unawaited(_onStepEnd());
      }
    });
  }

  /// Stops the reading timer and the ambient sound under it.
  Future<void> _quiet() async {
    _reading?.cancel();
    await _ambient.pause();
  }

  Future<void> _onStepEnd() async {
    final s = state;
    if (s == null || s.phase != SessionPhase.playing) return;
    await _quiet();
    await _countCurrent(s);
    await _playAt(state!.index + 1);
  }

  /// Adds the current step to the time (and a verse to the played list).
  Future<void> _countCurrent(SessionState s) async {
    final item = s.queue[s.index];
    final played = item is VerseItem ? [...s.played, item.ref] : s.played;
    state = s.copyWith(
      played: played,
      completed: s.completed + 1,
      elapsedBefore: s.elapsedBefore + s.position,
      position: Duration.zero,
    );
    if (item is VerseItem && s.sessionId != null) {
      await ref.read(sessionStoreProvider).recordVerses(s.sessionId!, played);
    }
  }

  Future<void> togglePause() async {
    final s = state;
    if (s == null) return;
    final reading = !hasRecitation(s.content);
    if (s.phase == SessionPhase.playing) {
      if (reading) {
        await _ambient.pause();
      } else {
        await _player.pause();
      }
      state = s.copyWith(phase: SessionPhase.paused);
    } else if (s.phase == SessionPhase.paused) {
      state = s.copyWith(phase: SessionPhase.playing);
      if (reading) {
        _ambient.play();
      } else {
        _player.play();
      }
    }
  }

  Future<void> next() async {
    final s = state;
    if (s == null || s.content == null) return;
    await _quiet();
    await _player.stop();
    await _countCurrent(s);
    await _playAt(s.index + 1);
  }

  /// Restarts the step, or goes back one if it has only just begun.
  Future<void> previous() async {
    final s = state;
    if (s == null || s.content == null) return;
    await _quiet();
    await _player.stop();
    final back = s.position < const Duration(seconds: 3) && s.index > 0;
    state = s.copyWith(
      elapsedBefore: s.elapsedBefore + s.position,
      position: Duration.zero,
    );
    await _playAt(back ? s.index - 1 : s.index);
  }

  /// Ends the session now (the X button, or time's up).
  Future<void> end() async {
    final s = state;
    if (s == null) return;
    await _quiet();
    if (s.phase == SessionPhase.playing || s.phase == SessionPhase.paused) {
      await _player.stop();
      await _countCurrent(s);
    }
    await _end();
  }

  Future<void> _end() async {
    _generation++;
    await _quiet();
    _unsubscribe();
    await _player.stop();
    final s = state;
    if (s == null) return;
    state = s.copyWith(phase: SessionPhase.finished);
  }

  void setMoodAfter(String? mood) {
    final s = state;
    if (s != null) state = s.copyWith(moodAfter: mood);
  }

  /// Saves the session to the journal (mood after, optional reflection)
  /// and clears it.
  Future<void> save({
    String? reflection,
    String? voiceNote,
    int? voiceSeconds,
  }) async {
    final s = state;
    final id = s?.sessionId;
    if (id != null) {
      await ref
          .read(sessionStoreProvider)
          .finish(
            id,
            at: ref.read(nowProvider),
            moodAfter: s!.moodAfter,
            reflection: reflection == null || reflection.trim().isEmpty
                ? null
                : reflection.trim(),
            voiceNote: voiceNote,
            voiceSeconds: voiceSeconds,
          );
    }
    state = null;
  }

  Future<void> _halt() async {
    _generation++;
    await _quiet();
    _unsubscribe();
    if (state != null) await _player.stop();
  }

  void _unsubscribe() {
    unawaited(_positions?.cancel());
    unawaited(_completions?.cancel());
    _positions = null;
    _completions = null;
  }
}
