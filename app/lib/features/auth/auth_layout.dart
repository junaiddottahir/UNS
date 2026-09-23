import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/step_top_bar.dart';

/// The prototype's account steps: a title, one field, and the round arrow
/// in the corner (dimmed until the step can go on).
class AuthStep extends StatelessWidget {
  const AuthStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.field,
    this.hint,
    this.error,
    this.links = const [],
    required this.canGo,
    required this.busy,
    required this.onGo,
    required this.goLabel,
  });

  final String title;
  final String? subtitle;
  final Widget field;
  final String? hint;
  final String? error;
  final List<Widget> links;
  final bool canGo;
  final bool busy;
  final VoidCallback onGo;
  final String goLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const BackTopBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    40,
                    AppSpacing.screenH,
                    AppSpacing.screenBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.title2),
                      if (subtitle != null) ...[
                        const SizedBox(height: 12),
                        Text(subtitle!, style: AppText.body),
                      ],
                      const SizedBox(height: 40),
                      field,
                      if (error != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          error!,
                          style: AppText.body.copyWith(
                            fontSize: 13,
                            color: AppColors.accentPrimary,
                          ),
                        ),
                      ] else if (hint != null) ...[
                        const SizedBox(height: 14),
                        Text(hint!, style: AppText.body.copyWith(fontSize: 13)),
                      ],
                      const SizedBox(height: 8),
                      ...links,
                      const Spacer(),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Semantics(
                          button: true,
                          label: goLabel,
                          excludeSemantics: true,
                          child: SizedBox.square(
                            dimension: 64,
                            child: FilledButton(
                              onPressed: canGo && !busy ? onGo : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.ctaBackground,
                                foregroundColor: AppColors.ctaForeground,
                                disabledBackgroundColor: AppColors.glassFill,
                                disabledForegroundColor: AppColors.textFaint,
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                              ),
                              child: busy
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.textPrimary,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_forward, size: 22),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The prototype's `.fin` underlined input.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboard,
    this.autofill,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboard;
  final Iterable<String>? autofill;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      obscureText: obscure,
      keyboardType: keyboard,
      autofillHints: autofill,
      autocorrect: false,
      enableSuggestions: !obscure,
      onSubmitted: (_) => onSubmitted?.call(),
      style: AppText.input.copyWith(letterSpacing: obscure ? 2.4 : null),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.input.copyWith(color: AppColors.textFaint),
        contentPadding: const EdgeInsets.only(bottom: 14),
        isDense: true,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textSubtle),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
