import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_providers.dart';

/// Placeholder home; prayer times and shortcuts arrive in unit 2.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final location = ref.watch(userLocationProvider);

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              30,
              AppSpacing.screenH,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (location != null)
                  Text(
                    location.city.shortLabel.toUpperCase(),
                    style: AppText.label,
                  ),
                const SizedBox(height: 14),
                Text(l10n.homeGreeting, style: AppText.headline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
