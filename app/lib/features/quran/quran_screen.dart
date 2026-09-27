import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../l10n/app_localizations.dart';
import 'surah.dart';

/// Quran tab: every surah, opening to read or listen.
class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final surahs = ref.watch(surahsProvider).value ?? const <Surah>[];
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            l10n.tabQuran.toUpperCase(),
                            style: AppText.label,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        30,
                        AppSpacing.screenH,
                        18,
                      ),
                      child: Text(l10n.quranHeadline, style: AppText.headline),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                // Clear of the floating tab bar.
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  124,
                ),
                sliver: SliverList.builder(
                  itemCount: surahs.length,
                  itemBuilder: (context, i) => _SurahRow(
                    surahs[i],
                    onTap: () =>
                        context.push(Routes.quranSurah(surahs[i].number)),
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

class _SurahRow extends StatelessWidget {
  const _SurahRow(this.surah, {required this.onTap});

  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
        ),
        child: Row(
          children: [
            SurahNumber(surah.number),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.name, style: AppText.row),
                  const SizedBox(height: 3),
                  Text(
                    '${surah.englishName} · ${l10n.verseCount(surah.ayahs)}',
                    style: AppText.rowValue,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Names as the Quran API gives them.
            Text(
              surah.arabicName,
              textDirection: TextDirection.rtl,
              softWrap: false,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A surah or verse number in a thin ring.
class SurahNumber extends StatelessWidget {
  const SurahNumber(this.number, {super.key, this.size = 36});

  final int number;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassEdge),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textPrimary,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
