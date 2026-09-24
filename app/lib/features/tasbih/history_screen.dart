import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../prayer/prayer_providers.dart';
import 'tasbih_providers.dart';

/// Daily totals, today first. [justFinished] shows "Dhikr complete".
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key, this.justFinished = false});

  final bool justFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = ref.watch(nowProvider);
    final today = DateTime(now.year, now.month, now.day);
    final todayCount = ref.watch(todayTasbihProvider).value ?? 0;
    final past = (ref.watch(tasbihHistoryProvider).value ?? const [])
        .where((d) => d.date.isBefore(today))
        .toList();

    String dayName(DateTime d) => today.difference(d).inDays < 7
        ? DateFormat.EEEE(locale).format(d)
        : DateFormat.MMMd(locale).format(d);

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const BackTopBar(),
              if (justFinished)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tabBar,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.glassEdge),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check,
                          size: 15,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.dhikrComplete,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  22,
                  AppSpacing.screenH,
                  0,
                ),
                child: Text(l10n.history, style: AppText.title2),
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
                            label: Text(l10n.today),
                            value: '$todayCount',
                            valueStyle: AppText.rowValue.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            divider: past.isNotEmpty,
                          ),
                          for (final (i, d) in past.indexed)
                            GlassRow(
                              label: Text(dayName(d.date)),
                              value: '${d.count}',
                              divider: i < past.length - 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: ActionPill(
                        icon: const Icon(Icons.local_fire_department_outlined),
                        label: l10n.streaksPremium,
                        onTap: () => context.push(Routes.plans),
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
