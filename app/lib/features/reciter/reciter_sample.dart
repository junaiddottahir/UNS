import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/config/app_config.dart';
import '../../core/quran/quran_providers.dart';
import '../../core/quran/verse_ref.dart';
import 'reciter.dart';

/// Plays a local audio file. An interface so tests can fake it.
abstract interface class SamplePlayer {
  /// Completes when playback ends or is stopped.
  Future<void> play(File file);
  Future<void> stop();
  Future<void> dispose();
}

class JustAudioSamplePlayer implements SamplePlayer {
  final _player = AudioPlayer();

  @override
  Future<void> play(File file) async {
    await _player.setFilePath(file.path);
    await _player.play(); // resolves when playback completes or pauses
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}

final samplePlayerProvider = Provider<SamplePlayer>((ref) {
  final player = JustAudioSamplePlayer();
  ref.onDispose(player.dispose);
  return player;
});

enum SampleStatus { idle, loading, playing, failed }

class SampleState {
  const SampleState(this.reciter, this.status);
  static const idle = SampleState(null, SampleStatus.idle);

  final Reciter? reciter;
  final SampleStatus status;
}

/// The sample being played in onboarding step 4, if any.
final reciterSampleProvider =
    NotifierProvider.autoDispose<ReciterSampleNotifier, SampleState>(
      ReciterSampleNotifier.new,
    );

class ReciterSampleNotifier extends Notifier<SampleState> {
  @override
  SampleState build() {
    // Stop the sample when leaving the step (can't read providers here
    // during disposal, so keep the player from now).
    final player = ref.read(samplePlayerProvider);
    ref.onDispose(() => unawaited(player.stop()));
    return SampleState.idle;
  }

  /// Plays [reciter]'s sample, or stops it if it is already playing.
  Future<void> toggle(Reciter reciter) async {
    final player = ref.read(samplePlayerProvider);
    if (state.reciter == reciter && state.status != SampleStatus.failed) {
      await player.stop();
      state = SampleState.idle;
      return;
    }
    await player.stop();
    state = SampleState(reciter, SampleStatus.loading);
    try {
      final file = await ref
          .read(recitationRepositoryProvider)
          .audio(
            reciter.source,
            VerseRef(AppConfig.reciterSampleSurah, AppConfig.reciterSampleAyah),
          );
      if (state.reciter != reciter) return; // another tap won meanwhile
      state = SampleState(reciter, SampleStatus.playing);
      await player.play(file);
      if (state.reciter == reciter) state = SampleState.idle;
    } on Exception {
      if (state.reciter == reciter) {
        state = SampleState(reciter, SampleStatus.failed);
      }
    }
  }
}
