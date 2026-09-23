import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/storage/settings_store.dart';
import '../../core/widgets/glass.dart';
import '../../l10n/app_localizations.dart';
import '../reciter/reciter.dart';
import '../reciter/reciter_labels.dart';
import 'onboarding_step.dart';

/// Onboarding step 4: pick a reciter. Samples play once Quran audio lands
/// (unit 8); for now a tap selects.
class ReciterStepScreen extends ConsumerWidget {
  const ReciterStepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reciter = ref.watch(reciterProvider);

    return OnboardingStep(
      step: 4,
      title: l10n.reciterStepTitle,
      body: l10n.reciterStepBody,
      actionLabel: l10n.finish,
      onAction: () {
        ref
            .read(settingsStoreProvider)
            .writeBool(SettingKeys.onboardingComplete, true);
        context.go(Routes.home);
      },
      child: PillSection(
        label: l10n.reciterLabel,
        child: OptionPills<Reciter>(
          options: Reciter.values,
          selected: reciter,
          labelOf: l10n.reciterName,
          iconOf: (_, selected) =>
              selected ? Icons.graphic_eq : Icons.play_arrow_rounded,
          onSelected: ref.read(reciterProvider.notifier).set,
        ),
      ),
    );
  }
}
