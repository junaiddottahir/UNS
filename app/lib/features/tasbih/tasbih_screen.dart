import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../l10n/app_localizations.dart';
import 'dhikr.dart';
import 'dhikr_labels.dart';
import 'tasbih_providers.dart';

/// Tasbih tab: today's total, the after-prayer set and single dhikr.
class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  void _start(BuildContext context, WidgetRef ref, List<Dhikr> set) {
    ref.read(tasbihSessionProvider.notifier).start(set);
    context.push(Routes.tasbihCounter);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayTasbihProvider).value ?? 0;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                  ),
                  child: Row(
                    children: [
                      Text(l10n.tasbih.toUpperCase(), style: AppText.label),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push(Routes.tasbihHistory),
                        child: Text(
                          l10n.history.toUpperCase(),
                          style: AppText.label,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                    Text(l10n.today.toUpperCase(), style: AppText.label),
                    const SizedBox(height: 10),
                    Text('$today', style: AppText.bearing),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                // Clears the floating tab bar.
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 124),
                child: Column(
                  children: [
                    _AfterPrayerCard(
                      onTap: () => _start(context, ref, afterPrayerSet),
                    ),
                    const SizedBox(height: 10),
                    GlassCard(
                      child: Column(
                        children: [
                          for (final d in Dhikr.values)
                            GlassRow(
                              label: Text(l10n.dhikrName(d)),
                              value: '${d.target}',
                              onTap: () => _start(context, ref, [d]),
                            ),
                          GlassRow(
                            leading: Icons.add,
                            label: Opacity(
                              opacity: 0.7,
                              child: Text(l10n.customDhikr),
                            ),
                            value: l10n.premium.toUpperCase(),
                            valueStyle: AppText.label,
                            divider: false,
                            onTap: () => context.push(Routes.plans),
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

class _AfterPrayerCard extends StatelessWidget {
  const _AfterPrayerCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.startAfterPrayer,
      child: GlassCard(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 14, 0, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.afterPrayer,
                        style: const TextStyle(
                          fontSize: 19,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        afterPrayerSet.map(l10n.dhikrName).join(' · '),
                        style: AppText.body.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.ctaBackground,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.ctaForeground,
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
