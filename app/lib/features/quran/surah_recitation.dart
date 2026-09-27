import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran/quran_providers.dart';
import '../../core/quran/verse_ref.dart';
import '../reciter/reciter.dart';
import '../shama/verse_player.dart';

/// Listening to a surah: which verse is recited and whether it's playing.
class Recitation {
  const Recitation({
    this.ayah,
    this.playing = false,
    this.loading = false,
    this.failed = false,
  });

  /// The verse being recited (1-based), or null when stopped.
  final int? ayah;
  final bool playing;

  /// Downloading [ayah]'s audio.
  final bool loading;

  /// The last verse's audio couldn't be loaded.
  final bool failed;

  static const stopped = Recitation();
}

/// Its own player, separate from Shama's, that lives only while the surah
/// is open: leaving the reader stops the recitation.
final quranPlayerProvider = Provider.autoDispose<VersePlayer>((ref) {
  final player = JustAudioVersePlayer();
  ref.onDispose(player.dispose);
  return player;
});

final surahRecitationProvider = NotifierProvider.autoDispose
    .family<SurahRecitation, Recitation, int>(SurahRecitation.new);

/// Recites a surah verse by verse in the chosen reciter, from any verse to
/// the end, fetching the next verse's audio while one plays.
class SurahRecitation extends Notifier<Recitation> {
  SurahRecitation(this.surah);

  final int surah;
  late VersePlayer _player;

  /// Bumped on every jump, so a slow download can't start an old verse.
  int _request = 0;

  @override
  Recitation build() {
    _player = ref.watch(quranPlayerProvider);
    final done = _player.completions.listen((_) => next());
    final player = _player;
    ref.onDispose(() {
      _request++;
      unawaited(done.cancel());
      unawaited(player.stop());
    });
    return Recitation.stopped;
  }

  int get _last => ayahCounts[surah - 1];

  Future<void> playFrom(int ayah) async {
    final request = ++_request;
    await _player.stop();
    state = Recitation(ayah: ayah, loading: true);
    final reciter = ref.read(reciterProvider).source;
    final recitations = ref.read(recitationRepositoryProvider);
    try {
      final file = await recitations.audio(reciter, VerseRef(surah, ayah));
      if (request != _request) return;
      await _player.open(file);
      if (request != _request) return;
      _player.play();
      state = Recitation(ayah: ayah, playing: true);
    } on Exception {
      if (request == _request) state = Recitation(ayah: ayah, failed: true);
      return;
    }
    if (ayah < _last) {
      // Ready before it's needed; a failure shows when it's reached.
      unawaited(
        recitations
            .audio(reciter, VerseRef(surah, ayah + 1))
            .then((_) {}, onError: (_) {}),
      );
    }
  }

  /// Play/pause; from the start when nothing has played yet.
  Future<void> toggle() async {
    final ayah = state.ayah;
    if (ayah == null || state.failed) return playFrom(ayah ?? 1);
    if (state.loading) return;
    if (state.playing) {
      await _player.pause();
      state = Recitation(ayah: ayah);
    } else {
      _player.play();
      state = Recitation(ayah: ayah, playing: true);
    }
  }

  /// The next verse; after the last one the recitation ends.
  Future<void> next() async {
    final ayah = state.ayah;
    if (ayah == null) return;
    if (ayah >= _last) return stop();
    await playFrom(ayah + 1);
  }

  Future<void> previous() async {
    final ayah = state.ayah;
    if (ayah == null) return;
    await playFrom(ayah > 1 ? ayah - 1 : 1);
  }

  Future<void> stop() async {
    _request++;
    await _player.stop();
    state = Recitation.stopped;
  }
}
