import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// A soft background sound under duas that have no recitation. An
/// interface so tests can fake it.
abstract interface class AmbientPlayer {
  /// Starts, or resumes where it paused.
  void play();
  Future<void> pause();
  Future<void> dispose();
}

class JustAudioAmbientPlayer implements AmbientPlayer {
  /// Original sound made for Uns (not licensed from anyone); replace the
  /// file to change it. It loops seamlessly.
  static const asset = 'assets/audio/ambient.m4a';

  final _player = AudioPlayer();
  Future<void>? _loaded;

  Future<void> _load() => _loaded ??= () async {
    await _player.setAsset(asset);
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(0.6);
  }();

  @override
  void play() => unawaited(_load().then((_) => _player.play()));

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> dispose() => _player.dispose();
}

final ambientPlayerProvider = Provider<AmbientPlayer>((ref) {
  final player = JustAudioAmbientPlayer();
  ref.onDispose(player.dispose);
  return player;
});
