import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/quran/verse_ref.dart';
import '../../core/router/routes.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../library/verse_library.dart';
import '../prayer/prayer_providers.dart';
import '../shama/shama_labels.dart';
import '../shama/shama_session.dart';
import 'journal_labels.dart';
import 'journal_providers.dart';

/// One journal entry: moods, the reflection, and its verses to replay.
class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key, required this.id});

  final int id;

  void _replay(
    BuildContext context,
    WidgetRef ref,
    Session e,
    List<VerseRef> verses,
  ) {
    final emotion = Emotion.values.asNameMap()[e.emotion];
    if (emotion == null || verses.isEmpty) return;
    ref
        .read(shamaSessionProvider.notifier)
        .start(
          emotion: emotion,
          comfort: e.help == 'comfort',
          minutes: e.minutes,
          replay: verses,
        );
    context.push(Routes.shamaPlay);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(journalProvider).value ?? const [];
    final e = entries.where((s) => s.id == id).firstOrNull;
    if (e == null) {
      return const Scaffold(body: AmbientBackground(child: SizedBox()));
    }
    final now = ref.watch(nowProvider);
    final verses = versesOf(e);
    final before = Emotion.values.asNameMap()[e.emotion];
    final after = AfterMood.values.asNameMap()[e.moodAfter];

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackTopBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    22,
                    AppSpacing.screenH,
                    20,
                  ),
                  children: [
                    Text(
                      l10n
                          .entryMinutes(
                            entryDate(context, e.startedAt, now),
                            e.minutes,
                          )
                          .toUpperCase(),
                      style: AppText.label,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (before != null)
                          _MoodChip(l10n.emotionName(before), selected: false),
                        if (after != null)
                          _MoodChip(l10n.afterMoodName(after), selected: true),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      e.reflection ?? l10n.noReflection,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.45,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (verses.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 50),
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          children: [
                            for (final (i, v) in verses.indexed)
                              Semantics(
                                button: true,
                                label: l10n.playVerse('$v'),
                                excludeSemantics: true,
                                child: GlassRow(
                                  label: Text('$v'),
                                  trailing: Icons.play_arrow_rounded,
                                  divider: i < verses.length - 1,
                                  onTap: () => _replay(context, ref, e, [v]),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        label: l10n.replaySession,
                        onPressed: () => _replay(context, ref, e, verses),
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

class _MoodChip extends StatelessWidget {
  const _MoodChip(this.label, {required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.pillSelected : AppColors.pillFill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: selected ? null : Border.all(color: AppColors.pillEdge),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label.toUpperCase(),
          style: AppText.pill.copyWith(
            fontSize: 10,
            color: selected ? AppColors.ctaForeground : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
