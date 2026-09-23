import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../l10n/app_localizations.dart';
import 'quota.dart';

/// Shown instead of a 4th free session in a week.
class LimitScreen extends StatelessWidget {
  const LimitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AmbientBackground(
        fade: BackgroundFade.bottom,
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
                          .usedOf(freeSessionsPerWeek, freeSessionsPerWeek)
                          .toUpperCase(),
                      style: AppText.label,
                    ),
                    const SizedBox(height: 14),
                    Text(l10n.resetsMonday, style: AppText.headline),
                    const SizedBox(height: 14),
                    Text(l10n.alwaysFree, style: AppText.body),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  AppSpacing.screenBottom,
                ),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: l10n.seePremium,
                      onPressed: () => context.pushReplacement(Routes.plans),
                    ),
                    const SizedBox(height: 6),
                    TextLink(
                      label: l10n.revisitPastSession,
                      onPressed: () => context.pushReplacement(Routes.journal),
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
