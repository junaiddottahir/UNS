import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
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
    await ref.read(shamaSessionProvider.notifier).save();
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
                    ref
                        .read(shamaSessionProvider.notifier)
                        .setMoodAfter(m?.name);
                    // Feeling heavier: offer support first (prototype).
                    if (m == AfterMood.heavier) context.push(Routes.support);
                  },
                ),
                const SizedBox(height: 30),
                Text(
                  l10n.captureReflection.toUpperCase(),
                  style: AppText.label,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _GlassButton(
                        icon: Icons.edit_outlined,
                        label: l10n.write,
                        onTap: () => context.push(Routes.shamaWrite),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GlassButton(
                        icon: Icons.mic_none,
                        label: l10n.record,
                        onTap: () => context.push(Routes.shamaRecord),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                PrimaryButton(label: l10n.done, onPressed: _done),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The prototype's `.gbtn.glass`: an icon and label in a glass pill.
class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.glassFill,
          side: const BorderSide(color: AppColors.glassEdge),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}
