import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../alerts/alert_providers.dart';
import '../location/location_providers.dart';
import 'prayer_labels.dart';
import 'prayer_providers.dart';
import 'prayer_settings.dart';

/// Location, method, alerts, Asr and high-latitude rule.
class PrayerSettingsScreen extends ConsumerWidget {
  const PrayerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final location = ref.watch(userLocationProvider);
    final settings = ref.watch(prayerSettingsProvider);
    final method = ref.watch(prayerMethodProvider);
    final notifier = ref.read(prayerSettingsProvider.notifier);
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
                child: Text(l10n.prayerSettingsTitle, style: AppText.title2),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      child: Column(
                        children: [
                          GlassRow(
                            label: Text(l10n.locationLabel),
                            value: location?.city.name,
                            trailing: Icons.chevron_right,
                            onTap: () => context.push(Routes.prayerLocation),
                          ),
                          GlassRow(
                            label: Text(l10n.methodLabel),
                            value: l10n.methodName(method),
                            trailing: Icons.chevron_right,
                            onTap: () => context.push(Routes.prayerMethod),
                          ),
                          GlassRow(
                            label: Text(l10n.alertsLabel),
                            value: l10n.alertsCount(alerts.onCount),
                            trailing: Icons.chevron_right,
                            onTap: () => context.push(Routes.prayerAlerts),
                            divider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _Section(
                      label: l10n.asrLabel,
                      child: OptionPills<AsrMethod>(
                        options: AsrMethod.values,
                        selected: settings.asr,
                        labelOf: l10n.asrName,
                        onSelected: notifier.setAsr,
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

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.label),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
