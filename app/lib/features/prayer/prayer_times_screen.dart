import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_providers.dart';
import 'prayer_background.dart';
import 'prayer_labels.dart';
import 'prayer_providers.dart';
import 'prayer_times_unavailable.dart';

/// Today's five prayer times, with the next one marked.
class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final location = ref.watch(userLocationProvider);
    final schedule = ref.watch(prayerScheduleProvider);
    final settings = ref.watch(prayerSettingsProvider);
    final method = ref.watch(prayerMethodProvider);
    final now = ref.watch(nowProvider);
    final times = schedule?.today(now) ?? const [];
    final next = schedule?.next(now);

    return Scaffold(
      body: AmbientBackground(
        image: prayerBackground(next?.prayer),
        child: SafeArea(
          child: Column(
            children: [
              BackTopBar(
                trailing: IconButton(
                  onPressed: () => context.push(Routes.prayerSettings),
                  icon: const Icon(Icons.tune, color: AppColors.textPrimary),
                  tooltip: l10n.prayerSettingsTitle,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                formatLongDate(context, schedule?.localNow(now) ?? now),
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 6),
              Text(
                (location?.city.shortLabel ?? '').toUpperCase(),
                style: AppText.label,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 50),
                child: Column(
                  children: [
                    if (times.isEmpty)
                      PrayerTimesUnavailable(place: location?.city.name ?? '')
                    else
                      GlassCard(
                        child: Column(
                          children: [
                            for (final (i, t) in times.indexed)
                              _TimeRow(
                                name: l10n.prayerName(t.prayer),
                                time: formatPrayerTime(context, t.time),
                                nextTag:
                                    next != null &&
                                        t.time.isAtSameMomentAs(next.time)
                                    ? l10n.nextPrayerTag(
                                        l10n.untilText(t.time.difference(now)),
                                      )
                                    : null,
                                passed: !t.time.isAfter(now),
                                divider: i < times.length - 1,
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () => context.push(Routes.prayerSettings),
                      child: Text(
                        l10n
                            .methodSummary(
                              l10n.methodName(method),
                              l10n.asrName(settings.asr),
                            )
                            .toUpperCase(),
                        style: AppText.label,
                        textAlign: TextAlign.center,
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

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.name,
    required this.time,
    required this.nextTag,
    required this.passed,
    required this.divider,
  });

  final String name;
  final String time;
  final String? nextTag;
  final bool passed;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: passed ? 0.45 : 1,
      child: GlassRow(
        label: Row(
          children: [
            Text(name),
            if (nextTag != null) ...[
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  nextTag!.toUpperCase(),
                  style: AppText.label.copyWith(color: AppColors.accentPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        value: time,
        valueStyle: AppText.row.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        divider: divider,
      ),
    );
  }
}
