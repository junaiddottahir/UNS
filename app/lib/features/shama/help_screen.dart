import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../library/verse_library.dart';
import 'shama_labels.dart';

/// "What would help right now?": comfort or a reminder.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key, required this.emotion});

  final Emotion emotion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    void pick(bool comfort) => context.push(
      '${Routes.shamaLength}?emotion=${emotion.name}&help=${comfort ? 'comfort' : 'remind'}',
    );
    final mood = l10n.emotionName(emotion);

    return Scaffold(
      body: AmbientBackground(
        fade: BackgroundFade.bottom,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const BackTopBar(),
                  Text(
                    l10n
                        .feelingMood(
                          locale.startsWith('en') ? mood.toLowerCase() : mood,
                        )
                        .toUpperCase(),
                    style: AppText.label,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  30,
                  AppSpacing.screenH,
                  0,
                ),
                child: Text(l10n.whatWouldHelp, style: AppText.headline),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 50),
                child: Column(
                  children: [
                    _Option(
                      title: l10n.comfortMe,
                      body: l10n.comfortMeBody,
                      onTap: () => pick(true),
                    ),
                    const SizedBox(height: 10),
                    _Option(
                      title: l10n.remindMe,
                      body: l10n.remindMeBody,
                      onTap: () => pick(false),
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

class _Option extends StatelessWidget {
  const _Option({required this.title, required this.body, required this.onTap});

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(body, style: AppText.body.copyWith(fontSize: 14)),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
