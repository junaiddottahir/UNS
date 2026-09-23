import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../reciter/reciter.dart';
import '../reciter/reciter_labels.dart';
import '../reciter/reciter_sample.dart';

/// Profile → Recitation: pick the reciter; a tap plays a sample.
class ReciterSettingsScreen extends ConsumerWidget {
  const ReciterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reciter = ref.watch(reciterProvider);
    final sample = ref.watch(reciterSampleProvider);
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
                    Text(l10n.reciterTitle, style: AppText.title2),
                    const SizedBox(height: 14),
                    Text(l10n.reciterStepBody, style: AppText.body),
                    const SizedBox(height: 28),
                    OptionPills<Reciter>(
                      options: Reciter.values,
                      selected: reciter,
                      labelOf: l10n.reciterName,
                      iconOf: (r, _) => switch (sample) {
                        SampleState(
                          reciter: final s,
                          status: SampleStatus.loading,
                        )
                            when s == r =>
                          Icons.more_horiz,
                        SampleState(
                          reciter: final s,
                          status: SampleStatus.playing,
                        )
                            when s == r =>
                          Icons.graphic_eq,
                        _ => Icons.play_arrow_rounded,
                      },
                      onSelected: (r) {
                        ref.read(reciterProvider.notifier).set(r);
                        ref.read(reciterSampleProvider.notifier).toggle(r);
                      },
                    ),
                    if (sample.status == SampleStatus.failed) ...[
                      const SizedBox(height: 14),
                      Text(l10n.sampleFailed, style: AppText.body),
                    ],
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
