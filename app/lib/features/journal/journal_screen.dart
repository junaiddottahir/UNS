import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../prayer/prayer_providers.dart';
import 'journal_labels.dart';
import 'journal_providers.dart';
import 'voice_note.dart';

/// Every finished session, newest first, with the start of any
/// reflection. Stays on this phone.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(journalProvider).value ?? const [];
    final now = ref.watch(nowProvider);

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackTopBar(
                trailing: TextButton(
                  onPressed: () => context.push(Routes.plans),
                  child: Text(
                    l10n.insights.toUpperCase(),
                    style: AppText.label,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  22,
                  AppSpacing.screenH,
                  0,
                ),
                child: Text(l10n.journal, style: AppText.title2),
              ),
              Expanded(
                child: entries.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.screenH),
                        child: Text(l10n.journalEmpty, style: AppText.body),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 26, 18, 40),
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final e = entries[i];
                          final body = e.reflection;
                          final voice = e.voiceNote != null;
                          final preview = body != null
                              ? (body.length > 60
                                    ? '${body.substring(0, 60)}…'
                                    : body)
                              : voice
                              ? l10n.voiceReflection(
                                  clockText(e.voiceSeconds ?? 0),
                                )
                              : l10n.sessionOnly;
                          return GlassCard(
                            child: InkWell(
                              onTap: () =>
                                  context.push(Routes.journalEntry(e.id)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            entryDate(
                                              context,
                                              e.startedAt,
                                              now,
                                            ).toUpperCase(),
                                            style: AppText.label,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            entryMoods(l10n, e).toUpperCase(),
                                            style: AppText.label,
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Opacity(
                                      opacity: body == null && !voice
                                          ? 0.55
                                          : 1,
                                      child: Row(
                                        children: [
                                          Icon(
                                            body != null
                                                ? Icons.edit_outlined
                                                : voice
                                                ? Icons.mic_none
                                                : Icons.menu_book_outlined,
                                            size: 16,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              preview,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                height: 1.4,
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
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
