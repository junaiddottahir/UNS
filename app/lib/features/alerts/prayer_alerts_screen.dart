import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../prayer/prayer_labels.dart';
import '../prayer/prayer_schedule.dart';
import 'alert_labels.dart';
import 'alert_providers.dart';
import 'notifications_off_notice.dart';

/// Each prayer's alert choice at a glance; tap one to change it.
class PrayerAlertsScreen extends ConsumerWidget {
  const PrayerAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final alerts = ref.watch(alertSettingsProvider);

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
                  0,
                ),
                child: Text(l10n.prayerAlertsTitle, style: AppText.title2),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (alerts.onCount > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: NotificationsOffNotice(),
                      ),
                    GlassCard(
                      child: Column(
                        children: [
                          for (final p in Prayer.values)
                            GlassRow(
                              label: Text(l10n.prayerName(p)),
                              value: l10n.alertSummary(alerts.of(p)),
                              trailing: Icons.chevron_right,
                              divider: p != Prayer.values.last,
                              onTap: () =>
                                  context.push(Routes.prayerAlert(p.name)),
                            ),
                        ],
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
