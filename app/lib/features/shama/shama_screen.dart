import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../l10n/app_localizations.dart';
import 'shama_labels.dart';
import 'shama_session.dart';

/// Shama tab: "How are you feeling?" with emotion chips. Typed and voice
/// input join in units 12–13.
class ShamaScreen extends ConsumerWidget {
  const ShamaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(verseLibraryProvider);
    final notice = switch (library) {
      AsyncData(value: null) => l10n.libraryOffline,
      AsyncData(:final value?) when value.placeholder => l10n.libraryNotReady,
      _ => null,
    };

    return Scaffold(
      body: AmbientBackground(
        fade: BackgroundFade.bottom,
        child: SafeArea(
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
                      l10n.tabShama.toUpperCase(),
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
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeGreeting.toUpperCase(),
                      style: AppText.label,
                    ),
                    const SizedBox(height: 14),
                    Text(l10n.howAreYouFeeling, style: AppText.headline),
                    if (notice != null) ...[
                      const SizedBox(height: 14),
                      Text(notice, style: AppText.body),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  16,
                  AppSpacing.screenH,
                  124,
                ),
                child: Opacity(
                  opacity: notice == null ? 1 : 0.45,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in moodChips)
                        _Chip(
                          label: l10n.emotionName(e),
                          onTap: notice != null
                              ? null
                              : () => context.push(
                                  '${Routes.shamaHelp}?emotion=${e.name}',
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

/// The prototype's small `.opt.sm` pill.
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pillFill,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.pillEdge)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          // widthFactor 1: hug the label instead of filling the row.
          child: Center(
            widthFactor: 1,
            child: Text(
              label.toUpperCase(),
              style: AppText.pill.copyWith(
                fontSize: 10,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
