import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_service.dart';
import '../../core/router/routes.dart';
import '../../core/storage/settings_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../l10n/app_localizations.dart';
import '../reciter/reciter.dart';
import '../reciter/reciter_labels.dart';
import '../reciter/reciter_sample.dart';
import 'onboarding_step.dart';

/// Onboarding step 4: pick a reciter; a tap also plays (or stops) a short
/// sample, downloaded once and cached.
class ReciterStepScreen extends ConsumerWidget {
  const ReciterStepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reciter = ref.watch(reciterProvider);
    final sample = ref.watch(reciterSampleProvider);

    return OnboardingStep(
      step: 4,
      title: l10n.reciterStepTitle,
      body: l10n.reciterStepBody,
      actionLabel: l10n.finish,
      onAction: () {
        final store = ref.read(settingsStoreProvider);
        store.writeBool(SettingKeys.onboardingComplete, true);
        context.go(Routes.home);
        // Offer an account once, never as a gate (ui-context.md).
        if (ref.read(authServiceProvider).available &&
            !store.readBool(SettingKeys.accountOffered)) {
          store.writeBool(SettingKeys.accountOffered, true);
          context.push('${Routes.accountSave}?returnTo=${Routes.home}');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PillSection(
            label: l10n.reciterLabel,
            child: OptionPills<Reciter>(
              options: Reciter.values,
              selected: reciter,
              labelOf: l10n.reciterName,
              iconOf: (r, _) => switch (sample) {
                SampleState(reciter: final s, status: SampleStatus.loading)
                    when s == r =>
                  Icons.more_horiz,
                SampleState(reciter: final s, status: SampleStatus.playing)
                    when s == r =>
                  Icons.graphic_eq,
                _ => Icons.play_arrow_rounded,
              },
              onSelected: (r) {
                ref.read(reciterProvider.notifier).set(r);
                ref.read(reciterSampleProvider.notifier).toggle(r);
              },
            ),
          ),
          if (sample.status == SampleStatus.failed) ...[
            const SizedBox(height: 14),
            Text(l10n.sampleFailed, style: AppText.body),
          ],
        ],
      ),
    );
  }
}
