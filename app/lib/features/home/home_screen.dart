import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_providers.dart';
import '../prayer/prayer_background.dart';
import '../prayer/prayer_labels.dart';
import '../prayer/prayer_providers.dart';
import '../prayer/prayer_times_unavailable.dart';
import 'mood_orb.dart';

/// Home: date and place, the next prayer with a countdown, qibla and
/// tasbih shortcuts, and the mood check-in.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final location = ref.watch(userLocationProvider);
    final schedule = ref.watch(prayerScheduleProvider);
    final now = ref.watch(nowProvider);
    final next = schedule?.next(now);
    final place = location?.city.name ?? '';

    return Scaffold(
      body: AmbientBackground(
        image: prayerBackground(next?.prayer),
        fade: BackgroundFade.bottom,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n
                            .dateAndPlace(
                              formatShortDate(
                                context,
                                schedule?.localNow(now) ?? now,
                              ),
                              place,
                            )
                            .toUpperCase(),
                        style: AppText.label.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push(Routes.prayerSettings),
                      icon: const Icon(
                        Icons.tune,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: l10n.prayerSettingsTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (next == null)
                  PrayerTimesUnavailable(place: place)
                else
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => context.push(Routes.prayerTimes),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.nextPrayer.toUpperCase(),
                              style: AppText.label.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.prayerName(next.prayer),
                              style: AppText.hero,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    l10n.nextPrayerAt(
                                      formatPrayerTime(context, next.time),
                                      l10n.untilText(next.time.difference(now)),
                                    ),
                                    style: AppText.heroSub,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const _RoundArrow(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionPill(
                      icon: Icons.explore_outlined,
                      label: l10n.qibla,
                      onTap: () => context.push(Routes.qibla),
                    ),
                    ActionPill(
                      icon: Icons.radio_button_checked,
                      label: l10n.tasbih,
                      onTap: () => context.go(Routes.tasbih),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  // Clears the floating tab bar.
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 124),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.welcomeGreeting.toUpperCase(),
                              style: AppText.label.copyWith(
                                color: AppColors.textFaint,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.moodPrompt, style: AppText.moodPrompt),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      MoodOrb(
                        label: l10n.moodVoice,
                        onPressed: () => context.go(Routes.shama),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundArrow extends StatelessWidget {
  const _RoundArrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glassFill,
        border: Border.all(color: AppColors.glassEdge),
      ),
      child: const Icon(
        Icons.arrow_forward,
        size: 14,
        color: AppColors.textPrimary,
      ),
    );
  }
}
