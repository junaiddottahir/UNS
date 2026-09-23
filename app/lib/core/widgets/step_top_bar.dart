import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Back arrow on the left, "n of 4" on the right.
class StepTopBar extends StatelessWidget {
  const StepTopBar({super.key, required this.step, this.total = 4});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH - 12,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.canPop() ? context.pop() : null,
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              tooltip: l10n.back,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Text(
                l10n.stepOf(step, total).toUpperCase(),
                style: AppText.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
