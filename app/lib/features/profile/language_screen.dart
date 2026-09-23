import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/language.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';

extension LanguageLabels on AppLocalizations {
  /// Each language is named in its own script.
  String languageName(AppLanguage l) => switch (l) {
    AppLanguage.system => languageSystem,
    AppLanguage.en => languageEnglish,
    AppLanguage.ar => languageArabic,
  };
}

/// Profile → Language: the phone's language, English or Arabic.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.language, style: AppText.title2),
                    const SizedBox(height: 14),
                    Text(l10n.languageBody, style: AppText.body),
                    const SizedBox(height: 28),
                    OptionPills<AppLanguage>(
                      options: AppLanguage.values,
                      selected: ref.watch(languageProvider),
                      labelOf: l10n.languageName,
                      onSelected: ref.read(languageProvider.notifier).set,
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
