import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Why listening couldn't start.
enum VoiceProblem {
  /// Microphone or speech permission refused.
  noPermission,

  /// This phone can't recognise speech on the device.
  unsupported,
}

/// Callbacks while listening.
class VoiceListener {
  const VoiceListener({
    required this.onWords,
    required this.onLevel,
    required this.onDone,
  });

  /// The words so far (partial), replaced as recognition improves.
  final void Function(String words) onWords;

  /// Loudness for the wave, roughly 0–1.
  final void Function(double level) onLevel;

  /// Listening ended (finished, silence, or an error).
  final void Function(VoiceProblem? problem) onDone;
}

/// Speech-to-text that runs on the phone only; audio never leaves the
/// device (architecture.md invariant 8). An interface so tests can fake it.
abstract interface class VoiceInput {
  /// Whether this platform can guarantee on-device recognition.
  bool get supported;

  /// Starts listening; null if it started, else why not.
  Future<VoiceProblem?> start(VoiceListener listener);

  /// Stops and delivers the final words.
  Future<void> stop();

  Future<void> cancel();
}

class DeviceVoiceInput implements VoiceInput {
  final _speech = SpeechToText();
  VoiceListener? _listener;
  bool _ready = false;

  /// iOS enforces on-device recognition (`requiresOnDeviceRecognition`).
  /// On Android the package falls back to a cloud recogniser when no
  /// on-device one exists, so voice stays off there until that can be
  /// guaranteed (see progress-tracker.md).
  @override
  bool get supported => Platform.isIOS;

  @override
  Future<VoiceProblem?> start(VoiceListener listener) async {
    if (!supported) return VoiceProblem.unsupported;
    _listener = listener;
    if (!_ready) {
      final asked = !await _speech.hasPermission;
      _ready = await _speech.initialize(
        onError: _onError,
        onStatus: (status) {
          if (status == SpeechToText.doneStatus) _listener?.onDone(null);
        },
      );
      if (!_ready) {
        return await _speech.hasPermission
            ? VoiceProblem.unsupported
            : VoiceProblem.noPermission;
      }
      // iOS says "granted" while its permission alert is still closing; a
      // mic started then records silence for the whole first try.
      if (asked) await _backInForeground();
      if (_listener != listener) return null; // closed while waiting
    }
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult r) =>
            _listener?.onWords(r.recognizedWords),
        // iOS reports dBFS: about -60 in a quiet room, -15 speaking up.
        onSoundLevelChange: (level) =>
            _listener?.onLevel(((level + 60) / 45).clamp(0, 1).toDouble()),
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(minutes: 2),
          pauseFor: const Duration(seconds: 10),
          onDevice: true,
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
      );
    } on Exception {
      return VoiceProblem.unsupported;
    }
    return null;
  }

  static Future<void> _backInForeground() async {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      final resumed = Completer<void>();
      final watch = AppLifecycleListener(
        onResume: () {
          if (!resumed.isCompleted) resumed.complete();
        },
      );
      await resumed.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      );
      watch.dispose();
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  void _onError(SpeechRecognitionError error) {
    final text = error.errorMsg.toLowerCase();
    _listener?.onDone(
      text.contains('device') || text.contains('recognizer')
          ? VoiceProblem.unsupported
          : null,
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() {
    _listener = null;
    return _speech.cancel();
  }
}

final voiceInputProvider = Provider<VoiceInput>((ref) => DeviceVoiceInput());

/// Whether to offer the mic: the platform can, and it hasn't failed as
/// unsupported on this phone.
final voiceAvailableProvider = NotifierProvider<VoiceAvailable, bool>(
  VoiceAvailable.new,
);

class VoiceAvailable extends Notifier<bool> {
  @override
  bool build() => ref.watch(voiceInputProvider).supported;

  void markUnsupported() => state = false;
}
