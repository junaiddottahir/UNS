import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_providers.dart';
import 'prayer_labels.dart';
import 'prayer_providers.dart';
import 'prayer_settings.dart';

/// Pick the calculation method. The one suggested for the location's
/// country is marked.
class MethodScreen extends ConsumerWidget {
  const MethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(prayerMethodProvider);
    final suggested = ref.watch(suggestedMethodProvider);
    final country = ref.watch(userLocationProvider)?.city.countryName ?? '';
    const methods = PrayerMethod.values;

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
                child: Text(l10n.methodTitle, style: AppText.title2),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 40),
                child: GlassCard(
                  child: Column(
                    children: [
                      for (final (i, m) in methods.indexed)
                        GlassRow(
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.methodName(m)),
                              if (m == suggested) ...[
                                const SizedBox(height: 4),
                                Text(
                                  l10n.methodSuggested(country).toUpperCase(),
                                  style: AppText.label.copyWith(
                                    color: AppColors.accentPrimary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: m == current ? Icons.check : null,
                          divider: i < methods.length - 1,
                          onTap: () {
                            ref
                                .read(prayerSettingsProvider.notifier)
                                .setMethod(m);
                            context.pop();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
