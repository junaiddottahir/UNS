import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/step_top_bar.dart';

/// Frame shared by the numbered onboarding steps: "n of 4", title, body,
/// the step's controls, and the main button at the bottom.
class OnboardingStep extends StatelessWidget {
  const OnboardingStep({
    super.key,
    required this.step,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.loading = false,
    this.child,
  });

  final int step;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;
  final bool loading;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepTopBar(step: step),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    30,
                    AppSpacing.screenH,
                    24,
                  ),
                  children: [
                    Text(title, style: AppText.headline),
                    const SizedBox(height: 14),
                    Text(body, style: AppText.body),
                    if (child != null) ...[const SizedBox(height: 28), child!],
                  ],
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
                  label: actionLabel,
                  loading: loading,
                  onPressed: onAction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An uppercase section label above a group of pills.
class PillSection extends StatelessWidget {
  const PillSection({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.label),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
