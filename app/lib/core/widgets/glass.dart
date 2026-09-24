import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Frosted panel over the background photo, the prototype's `.card.glass`.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AppRadius.card));
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: radius,
            border: Border.all(color: AppColors.glassEdge),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
  }
}

/// A row inside a [GlassCard], the prototype's `.row`: label on the start
/// side, value and an optional trailing icon on the end side.
class GlassRow extends StatelessWidget {
  const GlassRow({
    super.key,
    required this.label,
    this.value,
    this.valueStyle,
    this.leading,
    this.trailing,
    this.trailingColor,
    this.onTap,
    this.divider = true,
  });

  final Widget label;
  final String? value;
  final TextStyle? valueStyle;
  final IconData? leading;
  final IconData? trailing;
  final Color? trailingColor;
  final VoidCallback? onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: divider
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              )
            : null,
        child: Row(
          children: [
            if (leading != null) ...[
              Icon(leading, size: 17, color: AppColors.textMuted),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: DefaultTextStyle(style: AppText.row, child: label),
            ),
            if (value != null)
              ConstrainedBox(
                // Room for the label; long values truncate instead.
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.5,
                ),
                child: Text(
                  value!,
                  style: valueStyle ?? AppText.rowValue,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              Icon(
                trailing,
                size: 16,
                color: trailingColor ?? AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A pill-shaped action with an icon, e.g. home's Qibla shortcut.
class ActionPill extends StatelessWidget {
  const ActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pillFill,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.pillEdge)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: AppColors.textPrimary),
              const SizedBox(width: 9),
              Text(
                label.toUpperCase(),
                style: AppText.pill.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single-choice pills, the prototype's `.opts` of `.opt`. The selected
/// pill shows a check, or [iconOf]'s icon on every pill when given.
class OptionPills<T> extends StatelessWidget {
  const OptionPills({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.iconOf,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final IconData Function(T option, bool selected)? iconOf;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          _Pill(
            label: labelOf(option),
            selected: option == selected,
            icon: iconOf?.call(option, option == selected),
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}

/// Pills that each turn on and off; on pills show a check.
class TogglePills<T> extends StatelessWidget {
  const TogglePills({
    super.key,
    required this.options,
    required this.isOn,
    required this.labelOf,
    required this.onToggle,
  });

  final List<T> options;
  final bool Function(T) isOn;
  final String Function(T) labelOf;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          _Pill(
            label: labelOf(option),
            selected: isOn(option),
            onTap: () => onToggle(option),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.ctaForeground
        : AppColors.textPrimary;
    final shownIcon = icon ?? (selected ? Icons.check : null);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.pillSelected : AppColors.pillFill,
        shape: StadiumBorder(
          side: selected
              ? BorderSide.none
              : const BorderSide(color: AppColors.pillEdge),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (shownIcon != null) ...[
                  Icon(shownIcon, size: 15, color: foreground),
                  const SizedBox(width: 9),
                ],
                Text(
                  label.toUpperCase(),
                  style: AppText.pill.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
