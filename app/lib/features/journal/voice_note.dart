// StreamAudioSource is marked experimental in just_audio, but it's the only
// way to play a decrypted note from memory; the alternative writes the
// plain audio back to disk. Re-check on just_audio upgrades.
// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Records a voice note. An interface so tests can fake it.
abstract interface class VoiceRecorder {
  /// False if microphone access is refused.
  Future<bool> ensurePermission();

  /// Starts a new recording into a temporary file.
  Future<void> start();
  Future<void> pause();
  Future<void> resume();

  /// Stops and returns the (plain, temporary) recording.
  Future<File?> stop();

  /// Stops and throws the recording away.
  Future<void> discard();

  /// Loudness for the wave, 0–1.
  Stream<double> get levels;

  Future<void> dispose();
}

class DeviceVoiceRecorder implements VoiceRecorder {
  final _recorder = AudioRecorder();

  @override
  Future<bool> ensurePermission() => _recorder.hasPermission();

  @override
  Future<void> start() async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/note_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
      path: path,
    );
  }

  @override
  Future<void> pause() => _recorder.pause();

  @override
  Future<void> resume() => _recorder.resume();

  @override
  Future<File?> stop() async {
    final path = await _recorder.stop();
    return path == null ? null : File(path);
  }

  @override
  Future<void> discard() => _recorder.cancel();

  @override
  Stream<double> get levels => _recorder
      .onAmplitudeChanged(const Duration(milliseconds: 120))
      // dBFS, about -45 (quiet) to 0 (loud).
      .map((a) => ((a.current + 45) / 45).clamp(0, 1).toDouble());

  @override
  Future<void> dispose() => _recorder.dispose();
}

final voiceRecorderProvider = Provider.autoDispose<VoiceRecorder>((ref) {
  final recorder = DeviceVoiceRecorder();
  ref.onDispose(recorder.dispose);
  return recorder;
});

/// Plays a decrypted voice note from memory. An interface for tests.
abstract interface class NotePlayer {
  /// Completes when playback ends or is stopped.
  Future<void> play(Uint8List audio);
  Future<void> stop();
}

class JustAudioNotePlayer implements NotePlayer {
  final _player = AudioPlayer();

  @override
  Future<void> play(Uint8List audio) async {
    await _player.setAudioSource(_MemorySource(audio));
    await _player.play();
  }

  @override
  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}

/// Serves bytes held in memory, so a decrypted note never touches disk.
class _MemorySource extends StreamAudioSource {
  _MemorySource(this._bytes);

  final Uint8List _bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final from = start ?? 0;
    final to = end ?? _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: to - from,
      offset: from,
      stream: Stream.value(_bytes.sublist(from, to)),
      // iOS won't open audio whose declared type doesn't match.
      contentType: audioTypeOf(_bytes),
    );
  }
}

/// MP4/AAC recordings have `ftyp` at byte 4; MP3 starts with an ID3 tag
/// or a frame sync.
String audioTypeOf(Uint8List b) {
  if (b.length > 8 && String.fromCharCodes(b.sublist(4, 8)) == 'ftyp') {
    return 'audio/mp4';
  }
  if (b.length > 3 &&
      (String.fromCharCodes(b.sublist(0, 3)) == 'ID3' ||
          (b[0] == 0xFF && (b[1] & 0xE0) == 0xE0))) {
    return 'audio/mpeg';
  }
  return 'audio/mp4';
}

final notePlayerProvider = Provider<NotePlayer>((ref) {
  final player = JustAudioNotePlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// "0:48".
String clockText(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
