import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/purchases/premium_store.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../library/verse_library.dart';
import '../paywall/quota.dart';
import 'shama_labels.dart';
import 'shama_session.dart';

/// "How much time do you have?", then Begin.
class LengthScreen extends ConsumerStatefulWidget {
  const LengthScreen({super.key, required this.emotion, required this.comfort});

  final Emotion emotion;
  final bool comfort;

  @override
  ConsumerState<LengthScreen> createState() => _LengthScreenState();
}

class _LengthScreenState extends ConsumerState<LengthScreen> {
  int _minutes = recommendedMinutes;

  void _begin() {
    // Free users get a few new sessions a week (replays stay free).
    final premium = ref.read(premiumProvider).value ?? false;
    final used = ref.read(sessionsThisWeekProvider).value ?? 0;
    if (!premium && used >= freeSessionsPerWeek) {
      context.push(Routes.limit);
      return;
    }
    ref
        .read(shamaSessionProvider.notifier)
        .start(
          emotion: widget.emotion,
          comfort: widget.comfort,
          minutes: _minutes,
        );
    context.push(Routes.shamaPlay);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AmbientBackground(
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
                        .moodAndHelp(
                          l10n.emotionName(widget.emotion),
                          l10n.helpName(comfort: widget.comfort),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.howMuchTime, style: AppText.headline),
                    const SizedBox(height: 14),
                    Text(
                      l10n.timeRecommend(recommendedMinutes),
                      style: AppText.body,
                    ),
                    const SizedBox(height: 28),
                    OptionPills<int>(
                      options: sessionMinutes,
                      selected: _minutes,
                      labelOf: l10n.minutesShort,
                      onSelected: (m) => setState(() => _minutes = m),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  AppSpacing.screenBottom,
                ),
                child: PrimaryButton(
                  label: l10n.welcomeBegin,
                  onPressed: _begin,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
