import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../reciter/reciter.dart';
import '../reciter/reciter_labels.dart';

/// Credits every source of religious content, the chosen reciter, the
/// review process, and other data the app bundles.
class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reciter = ref.watch(reciterProvider);

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
                    Text(l10n.ourSources, style: AppText.title2),
                    const SizedBox(height: 14),
                    Text(l10n.sourcesIntro, style: AppText.body),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 30, 18, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      child: Column(
                        children: [
                          _row(l10n.sourceArabic, l10n.sourceArabicValue),
                          _row(
                            l10n.sourceTranslation,
                            l10n.sourceTranslationValue,
                          ),
                          _row(
                            l10n.sourceRecitation,
                            l10n.sourceRecitationValue,
                          ),
                          _row(l10n.sourceReciter, l10n.reciterName(reciter)),
                          _row(
                            l10n.sourceText,
                            l10n.sourceTextValue,
                            divider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.verseSelection.toUpperCase(),
                              style: AppText.label,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.verseSelectionBody,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        l10n.otherData.toUpperCase(),
                        style: AppText.label,
                      ),
                    ),
                    GlassCard(
                      child: Column(
                        children: [
                          _row(l10n.sourceCities, l10n.sourceCitiesValue),
                          _row(
                            l10n.sourceCompass,
                            l10n.sourceCompassValue,
                            divider: false,
                          ),
                        ],
                      ),
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

  static Widget _row(String label, String value, {bool divider = true}) =>
      GlassRow(label: Text(label), value: value, divider: divider);
}
