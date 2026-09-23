import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/glass.dart';
import '../alerts/alert_labels.dart';
import '../alerts/alert_providers.dart';
import '../alerts/alert_settings.dart';
import '../prayer/prayer_labels.dart';
import '../prayer/prayer_schedule.dart';
import 'onboarding_step.dart';

/// Onboarding step 3: which prayers alert, and with what sound. The
/// button asks for notification permission; either answer continues.
class NotificationsStepScreen extends ConsumerStatefulWidget {
  const NotificationsStepScreen({super.key});

  @override
  ConsumerState<NotificationsStepScreen> createState() =>
      _NotificationsStepScreenState();
}

class _NotificationsStepScreenState
    extends ConsumerState<NotificationsStepScreen> {
  bool _asking = false;

  Future<void> _allow() async {
    setState(() => _asking = true);
    try {
      await ref.read(notificationPermissionProvider).request();
      ref.read(permissionCheckProvider.notifier).recheck();
    } finally {
      if (mounted) setState(() => _asking = false);
    }
    if (mounted) context.push(Routes.reciterStep);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final alerts = ref.watch(alertSettingsProvider);
    final notifier = ref.read(alertSettingsProvider.notifier);

    return OnboardingStep(
      step: 3,
      title: l10n.notificationsStepTitle,
      body: l10n.notificationsStepBody,
      actionLabel: l10n.allowNotifications,
      loading: _asking,
      onAction: _allow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PillSection(
            label: l10n.alertMeFor,
            child: TogglePills<Prayer>(
              options: Prayer.values,
              isOn: alerts.isOn,
              labelOf: l10n.prayerName,
              onToggle: notifier.toggle,
            ),
          ),
          const SizedBox(height: 28),
          PillSection(
            label: l10n.soundLabel,
            child: OptionPills<AlertMode>(
              options: const [
                AlertMode.adhan,
                AlertMode.notification,
                AlertMode.silent,
              ],
              selected: alerts.sound,
              labelOf: l10n.alertModeName,
              iconOf: (mode, _) => alertModeIcon(mode),
              onSelected: notifier.setSound,
            ),
          ),
        ],
      ),
    );
  }
}
