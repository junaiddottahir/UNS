import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/storage/voice_note_vault.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../core/widgets/toast.dart';
import '../../l10n/app_localizations.dart';
import '../prayer/prayer_providers.dart';
import '../shama/mood_chat.dart';
import '../shama/shama_session.dart';
import 'reflection_prompts.dart';
import 'voice_note.dart';

/// Longest voice note, to keep files small.
const maxNoteLength = Duration(minutes: 5);

enum _Rec { idle, recording, paused }

/// Records a voice reflection. It's encrypted on save, stays on the phone,
/// and is never transcribed or read by AI.
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  late final VoiceRecorder _recorder = ref.read(voiceRecorderProvider);
  _Rec _state = _Rec.idle;
  int _seconds = 0;
  Timer? _tick;
  StreamSubscription<double>? _levelSub;
  final _levels = List<double>.filled(28, 0.2, growable: true);
  bool _noMic = false;
  bool _saving = false;

  @override
  void dispose() {
    _tick?.cancel();
    _levelSub?.cancel();
    // Leaving without saving throws the recording away.
    if (_state != _Rec.idle && !_saving) unawaited(_recorder.discard());
    super.dispose();
  }

  void _startTicking() {
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
      if (_seconds >= maxNoteLength.inSeconds) _toggle();
    });
  }

  Future<void> _toggle() async {
    switch (_state) {
      case _Rec.idle:
        if (!await _recorder.ensurePermission()) {
          setState(() => _noMic = true);
          return;
        }
        await _recorder.start();
        _levelSub = _recorder.levels.listen((l) {
          if (!mounted) return;
          setState(() {
            _levels
              ..removeAt(0)
              ..add(l.clamp(0.1, 1));
          });
        });
        setState(() => _state = _Rec.recording);
        _startTicking();
      case _Rec.recording:
        _tick?.cancel();
        await _recorder.pause();
        setState(() => _state = _Rec.paused);
      case _Rec.paused:
        if (_seconds >= maxNoteLength.inSeconds) return;
        await _recorder.resume();
        setState(() => _state = _Rec.recording);
        _startTicking();
    }
  }

  Future<void> _discard() async {
    _tick?.cancel();
    // Nothing depends on the cancel finishing, so don't wait for it.
    final levels = _levelSub;
    _levelSub = null;
    if (levels != null) unawaited(levels.cancel());
    if (_state != _Rec.idle) await _recorder.discard();
    setState(() {
      _state = _Rec.idle;
      _seconds = 0;
    });
  }

  Future<void> _save() async {
    if (_state == _Rec.idle || _seconds == 0 || _saving) return;
    _saving = true;
    _tick?.cancel();
    final l10n = AppLocalizations.of(context);
    final file = await _recorder.stop();
    if (file == null) return;
    final session = ref.read(shamaSessionProvider);
    final name =
        'note_${session?.sessionId ?? 0}_'
        '${ref.read(nowProvider).millisecondsSinceEpoch}.enc';
    await ref.read(voiceNoteVaultProvider).store(file, name: name);
    await ref
        .read(shamaSessionProvider.notifier)
        .save(voiceNote: name, voiceSeconds: _seconds);
    ref.read(moodChatProvider.notifier).reset();
    if (!mounted) return;
    context.go(Routes.home);
    showToast(l10n.reflectionSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recording = _state == _Rec.recording;
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackTopBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  30,
                  AppSpacing.screenH,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.todaysPrompt.toUpperCase(), style: AppText.label),
                    const SizedBox(height: 12),
                    Text(
                      reflectionPromptFor(l10n, ref.watch(nowProvider)),
                      style: AppText.title2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _noMic
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.screenH),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.micNeeded,
                                style: AppText.body,
                                textAlign: TextAlign.center,
                              ),
                              TextLink(
                                label: l10n.locationOpenSettings,
                                onPressed: Geolocator.openAppSettings,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(clockText(_seconds), style: AppText.bearing),
                            const SizedBox(height: 26),
                            SizedBox(
                              height: 64,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final l in _levels) ...[
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      width: 3,
                                      height: 6 + 58 * (recording ? l : l / 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.textPrimary.withValues(
                                          alpha: recording ? 1 : 0.3,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 26),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  size: 13,
                                  color: AppColors.textSubtle,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.onlyOnThisPhone.toUpperCase(),
                                  style: AppText.label,
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  60,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RoundButton(
                      icon: Icons.delete_outline,
                      label: l10n.discardRecording,
                      onTap: _state == _Rec.idle ? null : _discard,
                    ),
                    Semantics(
                      button: true,
                      label: switch (_state) {
                        _Rec.idle => l10n.startRecording,
                        _Rec.recording => l10n.pauseRecording,
                        _Rec.paused => l10n.resumeRecording,
                      },
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: _toggle,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.ctaBackground,
                          ),
                          child: Center(
                            // Red dot to record; rounded square while
                            // recording (tap to pause).
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: recording ? 26 : 30,
                              height: recording ? 26 : 30,
                              decoration: BoxDecoration(
                                color: AppColors.accentDeep,
                                borderRadius: BorderRadius.circular(
                                  recording ? 7 : 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _RoundButton(
                      icon: Icons.check,
                      label: l10n.saveRecording,
                      onTap: _seconds == 0 ? null : _save,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Material(
        color: AppColors.glassFill,
        shape: const CircleBorder(side: BorderSide(color: AppColors.glassEdge)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 56,
            child: Icon(
              icon,
              size: 20,
              color: AppColors.textPrimary,
              semanticLabel: label,
            ),
          ),
        ),
      ),
    );
  }
}
