import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran/quran_providers.dart';
import '../../core/quran/quran_repository.dart';
import '../../core/quran/verse_ref.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/settings_store.dart';
import '../library/library_repository.dart';
import '../library/verse_library.dart';
import '../prayer/prayer_providers.dart';
import '../reciter/reciter.dart';
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
  /// The library is still the placeholder, or has no verses for this.
  notApproved,

  /// Offline, and none of the verses are cached yet.
  offline,
}

class SessionState {
  const SessionState({
    required this.emotion,
    required this.comfort,
    required this.minutes,
    this.phase = SessionPhase.loading,
    this.queue = const [],
    this.index = 0,
    this.verse,
    this.played = const [],
    this.elapsedBefore = Duration.zero,
    this.position = Duration.zero,
    this.unavailable,
    this.sessionId,
  });

  final Emotion emotion;
  final bool comfort;
  final int minutes;
  final SessionPhase phase;
  final List<VerseRef> queue;
  final int index;

  /// The verse on screen, unchanged from the Quran API.
  final VerseText? verse;
  final List<VerseRef> played;

  /// Time spent in verses before the current one.
  final Duration elapsedBefore;

  /// Position within the current verse.
  final Duration position;
  final Unavailable? unavailable;
  final int? sessionId;

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
    List<VerseRef>? queue,
    int? index,
    VerseText? verse,
    List<VerseRef>? played,
    Duration? elapsedBefore,
    Duration? position,
    Unavailable? unavailable,
    int? sessionId,
  }) => SessionState(
    emotion: emotion,
    comfort: comfort,
    minutes: minutes,
    phase: phase ?? this.phase,
    queue: queue ?? this.queue,
    index: index ?? this.index,
    verse: verse ?? this.verse,
    played: played ?? this.played,
    elapsedBefore: elapsedBefore ?? this.elapsedBefore,
    position: position ?? this.position,
    unavailable: unavailable ?? this.unavailable,
    sessionId: sessionId ?? this.sessionId,
  );
}

final shamaSessionProvider =
    NotifierProvider<ShamaSessionNotifier, SessionState?>(
      ShamaSessionNotifier.new,
    );

/// Runs a session: approved verses for the emotion and help chosen, in a
/// random order, until the chosen time is up (the verse playing then
/// finishes). Only verses in the approved library ever play.
class ShamaSessionNotifier extends Notifier<SessionState?> {
  StreamSubscription<Duration>? _positions;
  StreamSubscription<void>? _completions;

  /// Bumped on every move, so a late completion from an old verse is
  /// ignored.
  int _generation = 0;

  @override
  SessionState? build() {
    ref.onDispose(_unsubscribe);
    return null;
  }

  VersePlayer get _player => ref.read(versePlayerProvider);

  Future<void> start({
    required Emotion emotion,
    required bool comfort,
    required int minutes,
  }) async {
    await _halt();
    state = SessionState(emotion: emotion, comfort: comfort, minutes: minutes);

    final library = await ref.read(verseLibraryProvider.future);
    final verses = library == null || library.placeholder
        ? const <VerseRef>[]
        : library.versesFor(emotion, comfort: comfort);
    if (library == null || verses.isEmpty) {
      state = state!.copyWith(
        phase: SessionPhase.unavailable,
        unavailable: library == null
            ? Unavailable.offline
            : Unavailable.notApproved,
      );
      return;
    }

    final queue = [...verses]..shuffle(ref.read(sessionRandomProvider));
    final id = await ref
        .read(sessionStoreProvider)
        .start(
          at: ref.read(nowProvider),
          emotion: emotion,
          comfort: comfort,
          minutes: minutes,
        );
    state = state!.copyWith(queue: queue, sessionId: id);
    _positions = _player.positions.listen((p) {
      final s = state;
      if (s != null && s.phase == SessionPhase.playing) {
        state = s.copyWith(position: p);
      }
    });
    _completions = _player.completions.listen((_) => _onVerseEnd());
    await _playAt(0);
  }

  Future<void> _playAt(int index) async {
    final generation = ++_generation;
    var i = index;
    final reciter = ref.read(reciterProvider).source;
    while (true) {
      final s = state;
      if (s == null) return;
      if (i >= s.queue.length || s.elapsed >= s.length) {
        await _end();
        return;
      }
      state = s.copyWith(index: i, phase: SessionPhase.loading);
      try {
        final verseRef = s.queue[i];
        final (text, file) = await (
          ref.read(quranRepositoryProvider).verse(verseRef),
          ref.read(recitationRepositoryProvider).audio(reciter, verseRef),
        ).wait;
        if (generation != _generation) return;
        await _player.open(file);
        if (generation != _generation) return;
        state = state!.copyWith(
          verse: text,
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
        if (i >= state!.queue.length && state!.played.isEmpty) {
          state = state!.copyWith(
            phase: SessionPhase.unavailable,
            unavailable: Unavailable.offline,
          );
          return;
        }
      }
    }
  }

  Future<void> _onVerseEnd() async {
    final s = state;
    if (s == null || s.phase != SessionPhase.playing) return;
    await _countCurrent(s);
    await _playAt(state!.index + 1);
  }

  /// Adds the current verse to the time and the played list.
  Future<void> _countCurrent(SessionState s) async {
    final played = [...s.played, s.queue[s.index]];
    state = s.copyWith(
      played: played,
      elapsedBefore: s.elapsedBefore + s.position,
      position: Duration.zero,
    );
    if (s.sessionId != null) {
      await ref.read(sessionStoreProvider).recordVerses(s.sessionId!, played);
    }
  }

  Future<void> togglePause() async {
    final s = state;
    if (s == null) return;
    if (s.phase == SessionPhase.playing) {
      await _player.pause();
      state = s.copyWith(phase: SessionPhase.paused);
    } else if (s.phase == SessionPhase.paused) {
      state = s.copyWith(phase: SessionPhase.playing);
      _player.play();
    }
  }

  Future<void> next() async {
    final s = state;
    if (s == null || s.verse == null) return;
    await _player.stop();
    await _countCurrent(s);
    await _playAt(s.index + 1);
  }

  /// Restarts the verse, or goes back one if it has only just begun.
  Future<void> previous() async {
    final s = state;
    if (s == null || s.verse == null) return;
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
    if (s.phase == SessionPhase.playing || s.phase == SessionPhase.paused) {
      await _player.stop();
      await _countCurrent(s);
    }
    await _end();
  }

  Future<void> _end() async {
    _generation++;
    _unsubscribe();
    await _player.stop();
    final s = state;
    if (s == null) return;
    state = s.copyWith(phase: SessionPhase.finished);
  }

  /// Saves the mood after and clears the session.
  Future<void> save(String? moodAfter) async {
    final id = state?.sessionId;
    if (id != null) {
      await ref
          .read(sessionStoreProvider)
          .finish(id, at: ref.read(nowProvider), moodAfter: moodAfter);
    }
    state = null;
  }

  Future<void> _halt() async {
    _generation++;
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
