import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../l10n/app_localizations.dart';
import 'compass_source.dart';
import 'qibla.dart';
import 'qibla_labels.dart';
import 'qibla_providers.dart';

/// How to calibrate the compass, with live accuracy.
class CalibrationScreen extends ConsumerWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(compassProvider).value;
    final accuracy = state is CompassReading
        ? state.accuracy
        : HeadingAccuracy.unknown;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AppSpacing.screenH - 12,
                    ),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: l10n.close,
                    ),
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
                    Text(
                      l10n
                          .accuracyLine(l10n.accuracyName(accuracy))
                          .toUpperCase(),
                      style: AppText.label,
                    ),
                    const SizedBox(height: 14),
                    Text(l10n.calibrateTitle, style: AppText.headline),
                    const SizedBox(height: 14),
                    Text(l10n.calibrateBody, style: AppText.body),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: Icon(
                    Icons.all_inclusive,
                    size: 96,
                    color: AppColors.textFaint,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  AppSpacing.screenBottom,
                ),
                child: PrimaryButton(
                  label: l10n.done,
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
