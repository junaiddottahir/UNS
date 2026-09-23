import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/toast.dart';
import '../../l10n/app_localizations.dart';
import 'mood_chat.dart';
import 'shama_labels.dart';
import 'shama_session.dart';

/// "How do you feel now?", then Done saves the session. "Heavier" opens
/// support resources first. Reflections join in units 14–15.
class AfterScreen extends ConsumerStatefulWidget {
  const AfterScreen({super.key});

  @override
  ConsumerState<AfterScreen> createState() => _AfterScreenState();
}

class _AfterScreenState extends ConsumerState<AfterScreen> {
  AfterMood? _mood;

  Future<void> _done() async {
    final l10n = AppLocalizations.of(context);
    await ref.read(shamaSessionProvider.notifier).save(_mood?.name);
    ref.read(moodChatProvider.notifier).reset();
    if (!mounted) return;
    context.go(Routes.home);
    showToast(l10n.sessionSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final emotion = ref.watch(shamaSessionProvider)?.emotion;

    return Scaffold(
      body: AmbientBackground(
        fade: BackgroundFade.bottom,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              78,
              AppSpacing.screenH,
              AppSpacing.screenBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (emotion != null)
                  Text(
                    l10n.beforeMood(l10n.emotionName(emotion)).toUpperCase(),
                    style: AppText.label,
                  ),
                const SizedBox(height: 14),
                Text(l10n.howDoYouFeelNow, style: AppText.headline),
                const Spacer(),
                OptionPills<AfterMood?>(
                  options: AfterMood.values,
                  selected: _mood,
                  labelOf: (m) => l10n.afterMoodName(m!),
                  onSelected: (m) {
                    setState(() => _mood = m);
                    // Feeling heavier: offer support first (prototype).
                    if (m == AfterMood.heavier) context.push(Routes.support);
                  },
                ),
                const SizedBox(height: 30),
                PrimaryButton(label: l10n.done, onPressed: _done),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
