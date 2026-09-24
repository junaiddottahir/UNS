import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Full-width cream pill, the prototype's `.cta`.
class PrimaryButton extends StatelessWidget {
  /// Its fixed height, for layouts that leave room for it.
  static const double height = 58;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ctaBackground,
          foregroundColor: AppColors.ctaForeground,
          disabledBackgroundColor: AppColors.ctaBackground.withValues(
            alpha: 0.6,
          ),
          disabledForegroundColor: AppColors.ctaForeground,
          shape: const StadiumBorder(),
          textStyle: AppText.button,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.ctaForeground,
                ),
              )
            else if (icon != null)
              Icon(icon, size: 16),
            if (loading || icon != null) const SizedBox(width: 8),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

/// Quiet text action, the prototype's `.tx`.
class TextLink extends StatelessWidget {
  const TextLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        textStyle: AppText.link,
      ),
      child: Text(label),
    );
  }
}
