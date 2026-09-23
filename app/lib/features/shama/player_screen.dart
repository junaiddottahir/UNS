import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../l10n/app_localizations.dart';
import '../reciter/reciter.dart';
import '../reciter/reciter_labels.dart';
import 'shama_session.dart';

/// The session: Arabic above the translation with their sources,
/// progress, reciter, time left and controls.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  static String _mmss(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(shamaSessionProvider.select((s) => s?.phase), (_, phase) {
      if (phase == SessionPhase.finished) {
        context.pushReplacement(Routes.shamaAfter);
      }
    });
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(shamaSessionProvider);
    final session = ref.read(shamaSessionProvider.notifier);
    if (s == null) return const Scaffold();

    if (s.phase == SessionPhase.unavailable) {
      return _Unavailable(
        message: s.unavailable == Unavailable.offline
            ? l10n.libraryOffline
            : l10n.libraryNotReady,
      );
    }

    final verse = s.verse;
    final dashes = s.queue.length.clamp(1, 12);
    return Scaffold(
      body: AmbientBackground(
        image: 'assets/images/bg_session.jpg',
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH - 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: session.end,
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textPrimary,
                        ),
                        tooltip: l10n.endSession,
                      ),
                      const SizedBox(width: 10),
                      for (var i = 0; i < dashes; i++) ...[
                        if (i > 0) const SizedBox(width: 5),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color: i <= s.index
                                  ? AppColors.textPrimary
                                  : AppColors.track,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: verse == null
                    ? Center(
                        child: Text(l10n.preparingVerses, style: AppText.body),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenH,
                          40,
                          AppSpacing.screenH,
                          20,
                        ),
                        children: [
                          Text(
                            l10n.verseLabel('${verse.ref}').toUpperCase(),
                            style: AppText.label,
                          ),
                          const SizedBox(height: 30),
                          // Arabic, exactly as the Quran API sent it.
                          Text(
                            verse.arabic,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: AppText.arabic,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              l10n.arabicSourceLabel.toUpperCase(),
                              style: AppText.sourceTag,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(verse.translation, style: AppText.translation),
                          const SizedBox(height: 10),
                          Text(
                            l10n.translationSourceLabel.toUpperCase(),
                            style: AppText.sourceTag,
                          ),
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
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: s.progress,
                        minHeight: 3,
                        color: AppColors.textPrimary,
                        backgroundColor: AppColors.track,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_mmss(s.elapsed), style: AppText.label),
                        Text(
                          l10n
                              .reciterName(ref.watch(reciterProvider))
                              .toUpperCase(),
                          style: AppText.label,
                        ),
                        Text('−${_mmss(s.remaining)}', style: AppText.label),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Round(
                          icon: Icons.skip_previous_rounded,
                          label: l10n.previousVerse,
                          onTap: session.previous,
                        ),
                        const SizedBox(width: 28),
                        SizedBox.square(
                          dimension: 72,
                          child: FilledButton(
                            onPressed: session.togglePause,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.ctaBackground,
                              foregroundColor: AppColors.ctaForeground,
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(
                              s.phase == SessionPhase.paused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              size: 30,
                              semanticLabel: s.phase == SessionPhase.paused
                                  ? l10n.play
                                  : l10n.pause,
                            ),
                          ),
                        ),
                        const SizedBox(width: 28),
                        _Round(
                          icon: Icons.skip_next_rounded,
                          label: l10n.nextVerse,
                          onTap: session.next,
                        ),
                      ],
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

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassFill,
      shape: const CircleBorder(side: BorderSide(color: AppColors.glassEdge)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(
          dimension: 52,
          child: Icon(
            icon,
            size: 22,
            color: AppColors.textPrimary,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              78,
              AppSpacing.screenH,
              AppSpacing.screenBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: AppText.title2),
                const Spacer(),
                PrimaryButton(
                  label: l10n.back,
                  onPressed: () => context.go(Routes.shama),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
