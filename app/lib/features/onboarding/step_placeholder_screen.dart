import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/step_top_bar.dart';

/// Frame for onboarding steps 3–4 until their units are built
/// (notifications: unit 4, reciter: unit 8).
class StepPlaceholderScreen extends StatelessWidget {
  const StepPlaceholderScreen({
    super.key,
    required this.step,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final int step;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepTopBar(step: step),
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
                    Text(title, style: AppText.headline),
                    const SizedBox(height: 14),
                    Text(body, style: AppText.body),
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
                child: PrimaryButton(label: actionLabel, onPressed: onAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
