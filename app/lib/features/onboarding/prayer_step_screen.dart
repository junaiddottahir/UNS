import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_providers.dart';
import '../prayer/prayer_labels.dart';
import '../prayer/prayer_providers.dart';
import '../prayer/prayer_settings.dart';
import '../prayer/prayer_times_unavailable.dart';

/// Onboarding step 2: today's times with the Asr choice and the suggested
/// method, updating as the user changes them.
class PrayerStepScreen extends ConsumerWidget {
  const PrayerStepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final place = ref.watch(userLocationProvider)?.city.name ?? '';
    final settings = ref.watch(prayerSettingsProvider);
    final method = ref.watch(prayerMethodProvider);
    final schedule = ref.watch(prayerScheduleProvider);
    final now = ref.watch(nowProvider);
    final times = schedule?.today(now) ?? const [];
    final next = schedule?.next(now);

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepTopBar(step: 2),
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
                    Text(l10n.prayerStepTitle, style: AppText.headline),
                    const SizedBox(height: 14),
                    Text(l10n.prayerStepBody(place), style: AppText.body),
                    const SizedBox(height: 28),
                    Text(l10n.asrLabel.toUpperCase(), style: AppText.label),
                    const SizedBox(height: 12),
                    OptionPills<AsrMethod>(
                      options: AsrMethod.values,
                      selected: settings.asr,
                      labelOf: l10n.asrName,
                      onSelected: ref
                          .read(prayerSettingsProvider.notifier)
                          .setAsr,
                    ),
                    const SizedBox(height: 30),
                    if (times.isEmpty)
                      PrayerTimesUnavailable(place: place)
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final t in times)
                            Opacity(
                              opacity:
                                  next != null &&
                                      t.time.isAtSameMomentAs(next.time)
                                  ? 1
                                  : 0.6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.prayerName(t.prayer),
                                    style: AppText.timesStrip,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    formatPrayerTime(context, t.time),
                                    style: AppText.timesStrip,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 22),
                    InkWell(
                      onTap: () => context.push(Routes.prayerMethod),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                l10n
                                    .methodLine(l10n.methodName(method))
                                    .toUpperCase(),
                                style: AppText.label,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              size: 15,
                              color: AppColors.textSubtle,
                            ),
                          ],
                        ),
                      ),
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
                  label: l10n.continueLabel,
                  onPressed: () => context.push(Routes.notificationsStep),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
