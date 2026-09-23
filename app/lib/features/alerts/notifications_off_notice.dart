import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../l10n/app_localizations.dart';
import 'alert_providers.dart';

/// Whether the OS currently allows notifications. Re-read on demand.
final notificationsGrantedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationPermissionProvider).isGranted(),
);

/// Shown when alerts are on but the OS blocks notifications.
class NotificationsOffNotice extends ConsumerWidget {
  const NotificationsOffNotice({super.key});

  Future<void> _turnOn(WidgetRef ref) async {
    final permission = ref.read(notificationPermissionProvider);
    // iOS prompts only once; after a "no", Settings is the only way.
    if (!await permission.request()) await permission.openSettings();
    ref.invalidate(notificationsGrantedProvider);
    ref.read(permissionCheckProvider.notifier).recheck();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final granted = ref.watch(notificationsGrantedProvider).value ?? true;
    if (granted) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.notificationsOff, style: AppText.body),
          TextLink(
            label: l10n.turnOnNotifications,
            onPressed: () => _turnOn(ref),
          ),
        ],
      ),
    );
  }
}
