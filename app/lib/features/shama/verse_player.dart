import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Plays one verse's audio at a time. An interface so tests can fake it.
abstract interface class VersePlayer {
  /// Loads [file]; returns its duration if known.
  Future<Duration?> open(File file);

  /// Starts or resumes; returns without waiting for the end.
  void play();
  Future<void> pause();
  Future<void> stop();

  Stream<Duration> get positions;

  /// Fires when the loaded verse plays to its end.
  Stream<void> get completions;

  Future<void> dispose();
}

class JustAudioVersePlayer implements VersePlayer {
  JustAudioVersePlayer() {
    // Recitation is the main audio: plays with the ring switch on silent
    // and carries on when the screen locks (UIBackgroundModes: audio).
    unawaited(
      AudioSession.instance.then(
        (s) => s.configure(const AudioSessionConfiguration.speech()),
      ),
    );
  }

  final _player = AudioPlayer();

  @override
  Future<Duration?> open(File file) => _player.setFilePath(file.path);

  @override
  void play() => unawaited(_player.play());

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Stream<Duration> get positions => _player.positionStream;

  @override
  Stream<void> get completions => _player.playerStateStream
      .where((s) => s.processingState == ProcessingState.completed)
      .map((_) {});

  @override
  Future<void> dispose() => _player.dispose();
}

final versePlayerProvider = Provider<VersePlayer>((ref) {
  final player = JustAudioVersePlayer();
  ref.onDispose(player.dispose);
  return player;
});
