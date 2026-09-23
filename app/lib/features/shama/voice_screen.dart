import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../l10n/app_localizations.dart';
import 'mood_chat.dart';
import 'voice_input.dart';

/// "Listening": speech becomes text on the phone. Finishing puts the words
/// in the Shama text box, to check before sending.
class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  String _words = '';
  final _levels = List<double>.filled(28, 0.15, growable: true);
  VoiceProblem? _problem;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final problem = await ref
        .read(voiceInputProvider)
        .start(
          VoiceListener(
            onWords: (w) {
              if (mounted) setState(() => _words = w);
            },
            onLevel: (l) {
              if (!mounted) return;
              setState(() {
                _levels
                  ..removeAt(0)
                  ..add(math.max(0.1, l));
              });
            },
            onDone: (p) {
              if (p != null) {
                _fail(p);
              } else {
                _finish();
              }
            },
          ),
        );
    if (problem != null) _fail(problem);
  }

  void _fail(VoiceProblem problem) {
    if (problem == VoiceProblem.unsupported) {
      ref.read(voiceAvailableProvider.notifier).markUnsupported();
    }
    if (mounted) setState(() => _problem = problem);
  }

  Future<void> _finish() async {
    if (_finished || _problem != null) return;
    _finished = true;
    await ref.read(voiceInputProvider).stop();
    ref.read(moodDraftProvider.notifier).set(_words.trim());
    if (mounted) context.pop();
  }

  Future<void> _close() async {
    _finished = true;
    await ref.read(voiceInputProvider).cancel();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AmbientBackground(
        fade: BackgroundFade.bottom,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AppSpacing.screenH - 12,
                    ),
                    child: IconButton(
                      onPressed: _close,
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: l10n.close,
                    ),
                  ),
                ),
              ),
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
                    Text(l10n.listening.toUpperCase(), style: AppText.label),
                    const SizedBox(height: 14),
                    Text(l10n.tellMeHowYouFeel, style: AppText.headline),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                  ),
                  child: _problem != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _problem == VoiceProblem.noPermission
                                  ? l10n.voiceNoPermission
                                  : l10n.voiceUnsupported,
                              style: AppText.body.copyWith(fontSize: 17),
                            ),
                            if (_problem == VoiceProblem.noPermission)
                              TextLink(
                                label: l10n.locationOpenSettings,
                                onPressed: Geolocator.openAppSettings,
                              ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_words.isEmpty)
                              Text(
                                l10n.speakNaturally,
                                style: AppText.body.copyWith(fontSize: 17),
                              )
                            else
                              Text(_words, style: AppText.transcript),
                            const SizedBox(height: 30),
                            SizedBox(
                              height: 64,
                              child: Row(
                                children: [
                                  for (final l in _levels) ...[
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      width: 3,
                                      height: 6 + 58 * l,
                                      decoration: BoxDecoration(
                                        color: AppColors.textPrimary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_problem == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Center(
                    child: Column(
                      children: [
                        Semantics(
                          button: true,
                          label: l10n.finishListening,
                          excludeSemantics: true,
                          child: GestureDetector(
                            onTap: _finish,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.ctaBackground,
                              ),
                              child: Center(
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentDeep,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.tapToFinish.toUpperCase(),
                          style: AppText.label,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
