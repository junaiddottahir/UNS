import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran/quran_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../reciter/reciter.dart';
import '../reciter/reciter_labels.dart';
import 'quran_screen.dart';
import 'surah.dart';
import 'surah_recitation.dart';

/// One surah to read, every verse with its translation, and to listen to
/// from the start or from any verse.
class SurahScreen extends ConsumerStatefulWidget {
  const SurahScreen({super.key, required this.number});

  final int number;

  @override
  ConsumerState<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends ConsumerState<SurahScreen> {
  final _keys = <int, GlobalKey>{};

  GlobalKey _keyFor(int ayah) => _keys.putIfAbsent(ayah, GlobalKey.new);

  /// Keeps the recited verse in view as the recitation moves on.
  void _follow(int ayah) {
    final target = _keys[ayah]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      alignment: 0.15,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final n = widget.number;
    final surah = ref
        .watch(surahsProvider)
        .value
        ?.where((s) => s.number == n)
        .firstOrNull;
    final text = ref.watch(surahTextProvider(n));
    final recitation = ref.watch(surahRecitationProvider(n));
    final reciting = ref.read(surahRecitationProvider(n).notifier);
    ref.listen(surahRecitationProvider(n), (before, now) {
      final ayah = now.ayah;
      if (ayah != null && ayah != before?.ayah) _follow(ayah);
      if (now.failed && !(before?.failed ?? false)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.recitationFailed)));
      }
    });

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const BackTopBar(),
              Expanded(
                child: switch (text) {
                  AsyncData(:final value) => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      10,
                      AppSpacing.screenH,
                      30,
                    ),
                    itemCount: value.length + 1,
                    itemBuilder: (context, i) => i == 0
                        ? _Header(
                            surah: surah,
                            bismillah: opensWithBismillah(n)
                                ? ref.watch(bismillahProvider).value
                                : null,
                            onListen: () => recitation.ayah == null
                                ? reciting.playFrom(1)
                                : reciting.toggle(),
                            listening: recitation.playing,
                          )
                        : _Verse(
                            key: _keyFor(i),
                            verse: value[i - 1],
                            current: recitation.ayah == i,
                            onTap: () => reciting.playFrom(i),
                          ),
                  ),
                  AsyncError() => _Failed(
                    onRetry: () => ref.invalidate(surahTextProvider(n)),
                  ),
                  _ => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                },
              ),
              if (recitation.ayah != null)
                _PlayerBar(
                  recitation: recitation,
                  reciter: ref.watch(reciterProvider),
                  onToggle: reciting.toggle,
                  onPrevious: reciting.previous,
                  onNext: reciting.next,
                  onStop: reciting.stop,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.surah,
    required this.bismillah,
    required this.onListen,
    required this.listening,
  });

  final Surah? surah;

  /// Shown above the first verse, unless the surah doesn't open with it.
  final String? bismillah;
  final VoidCallback onListen;
  final bool listening;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = surah;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s != null) ...[
            Text(
              l10n.surahNumberLabel(s.number).toUpperCase(),
              style: AppText.label,
            ),
            const SizedBox(height: 14),
            Text(s.name, style: AppText.headline),
            const SizedBox(height: 8),
            Text(
              [
                s.englishName,
                l10n.verseCount(s.ayahs),
                s.meccan ? l10n.meccan : l10n.medinan,
              ].join(' · '),
              style: AppText.body,
            ),
            const SizedBox(height: 22),
          ],
          ActionPill(
            icon: Icon(
              listening ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            label: listening ? l10n.pause : l10n.listen,
            onTap: onListen,
          ),
          const SizedBox(height: 22),
          Text(l10n.arabicSourceLabel.toUpperCase(), style: AppText.sourceTag),
          const SizedBox(height: 4),
          Text(
            l10n.translationSourceLabel.toUpperCase(),
            style: AppText.sourceTag,
          ),
          if (bismillah case final text?) ...[
            const SizedBox(height: 30),
            Text(
              text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: AppText.arabic,
            ),
          ],
        ],
      ),
    );
  }
}

class _Verse extends StatelessWidget {
  const _Verse({
    super.key,
    required this.verse,
    required this.current,
    required this.onTap,
  });

  final VerseText verse;

  /// Being recited now.
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      onTapHint: l10n.playFromVerse(verse.ref.ayah),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            color: current ? AppColors.glassFill : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: current ? AppColors.glassEdge : AppColors.borderDefault,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SurahNumber(verse.ref.ayah, size: 32),
                  const Spacer(),
                  if (current)
                    const Icon(
                      Icons.graphic_eq_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              // Arabic, exactly as the Quran API sent it.
              Text(
                verse.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: AppText.arabic,
              ),
              const SizedBox(height: 14),
              Text(
                verse.translation,
                style: AppText.translation.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The recitation's controls, under the verses while one is playing.
class _PlayerBar extends StatelessWidget {
  const _PlayerBar({
    required this.recitation,
    required this.reciter,
    required this.onToggle,
    required this.onPrevious,
    required this.onNext,
    required this.onStop,
  });

  final Recitation recitation;
  final Reciter reciter;
  final VoidCallback onToggle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget button(IconData icon, String label, VoidCallback onTap) =>
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.textPrimary),
          tooltip: label,
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.tabBar,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.glassEdge),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 6, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.verseNumber(recitation.ayah!),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.reciterName(reciter).toUpperCase(),
                          style: AppText.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  button(
                    Icons.skip_previous_rounded,
                    l10n.previousVerse,
                    onPrevious,
                  ),
                  SizedBox.square(
                    dimension: 48,
                    child: recitation.loading
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              color: AppColors.textPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : button(
                            recitation.playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            recitation.playing ? l10n.pause : l10n.play,
                            onToggle,
                          ),
                  ),
                  button(Icons.skip_next_rounded, l10n.nextVerse, onNext),
                  button(Icons.close_rounded, l10n.stopRecitation, onStop),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.surahLoadFailed, style: AppText.body),
          TextLink(label: l10n.tryAgain, onPressed: onRetry),
        ],
      ),
    );
  }
}
