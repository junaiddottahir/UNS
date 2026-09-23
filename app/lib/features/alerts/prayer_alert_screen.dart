import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../onboarding/onboarding_step.dart';
import '../prayer/prayer_labels.dart';
import '../prayer/prayer_providers.dart';
import '../prayer/prayer_schedule.dart';
import 'alert_labels.dart';
import 'alert_providers.dart';
import 'alert_settings.dart';
import 'notifications_off_notice.dart';

/// One prayer's alert: sound at prayer time, reminder, and check-in.
class PrayerAlertScreen extends ConsumerWidget {
  const PrayerAlertScreen({super.key, required this.prayer});

  final Prayer prayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final alert = ref.watch(alertSettingsProvider).of(prayer);
    final notifier = ref.read(alertSettingsProvider.notifier);
    void update(PrayerAlert Function(PrayerAlert) change) =>
        notifier.updatePrayer(prayer, change);

    final today = ref
        .watch(prayerScheduleProvider)
        ?.today(ref.watch(nowProvider))
        .where((t) => t.prayer == prayer)
        .firstOrNull;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const BackTopBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  22,
                  AppSpacing.screenH,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (today != null)
                      Text(
                        formatPrayerTime(context, today.time),
                        style: AppText.label,
                      ),
                    const SizedBox(height: 10),
                    Text(l10n.prayerName(prayer), style: AppText.headline),
                    const SizedBox(height: 30),
                    const NotificationsOffNotice(),
                    PillSection(
                      label: l10n.atPrayerTime,
                      child: OptionPills<AlertMode>(
                        options: const [
                          AlertMode.adhan,
                          AlertMode.notification,
                          AlertMode.silent,
                          AlertMode.off,
                        ],
                        selected: alert.mode,
                        labelOf: l10n.alertModeName,
                        iconOf: (m, _) => alertModeIcon(m),
                        onSelected: (m) => update((a) => a.copyWith(mode: m)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    PillSection(
                      label: l10n.remindMeBefore,
                      child: OptionPills<int>(
                        options: reminderChoices,
                        selected: alert.remindBefore,
                        labelOf: l10n.reminderName,
                        onSelected: (m) =>
                            update((a) => a.copyWith(remindBefore: m)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    PillSection(
                      label: l10n.askDidYouPray,
                      child: OptionPills<bool>(
                        options: const [true, false],
                        selected: alert.checkIn,
                        labelOf: (v) => v ? l10n.yes : l10n.no,
                        onSelected: (v) =>
                            update((a) => a.copyWith(checkIn: v)),
                      ),
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
