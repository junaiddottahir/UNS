import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';

/// Where each kind of data lives, in plain words (architecture.md).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final points = [
      (Icons.lock_outline, l10n.privacyPhone),
      (Icons.chat_bubble_outline, l10n.privacyClassify),
      (Icons.sync, l10n.privacyAccount),
      (Icons.block, l10n.privacyNoAds),
    ];
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const BackTopBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  22,
                  AppSpacing.screenH,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.privacy, style: AppText.title2),
                    const SizedBox(height: 14),
                    Text(l10n.privacyIntro, style: AppText.body),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 40),
                child: GlassCard(
                  child: Column(
                    children: [
                      for (final (i, (icon, text)) in points.indexed)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: i < points.length - 1
                              ? const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.borderDefault,
                                    ),
                                  ),
                                )
                              : null,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(icon, size: 18, color: AppColors.textMuted),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.45,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
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
