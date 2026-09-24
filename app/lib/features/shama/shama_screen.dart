import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/purchases/premium_store.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../l10n/app_localizations.dart';
import '../library/verse_library.dart';
import '../paywall/quota.dart';
import 'mood_chat.dart';
import 'shama_labels.dart';
import 'voice_input.dart';

/// Shama tab: "How are you feeling?" — type it, or pick a chip. Typed words
/// are checked on the phone for risk, then classified; they're never saved.
class ShamaScreen extends ConsumerStatefulWidget {
  const ShamaScreen({super.key});

  @override
  ConsumerState<ShamaScreen> createState() => _ShamaScreenState();
}

class _ShamaScreenState extends ConsumerState<ShamaScreen> {
  final _draft = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _start(Emotion e) {
    ref.read(moodChatProvider.notifier).reset();
    context.push('${Routes.shamaHelp}?emotion=${e.name}');
  }

  Future<void> _send() async {
    final text = _draft.text;
    if (text.trim().isEmpty) return;
    _draft.clear();
    final outcome = await ref.read(moodChatProvider.notifier).send(text);
    if (outcome == SendOutcome.showSupport && mounted) {
      context.push(Routes.support);
    }
  }

  void _fillFromVoice() {
    final words = ref.read(moodDraftProvider.notifier).take();
    if (words != null) {
      _draft.text = words;
      _draft.selection = TextSelection.collapsed(offset: words.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(moodDraftProvider, (_, words) {
      if (words != null) _fillFromVoice();
    });
    final l10n = AppLocalizations.of(context);
    final chat = ref.watch(moodChatProvider);
    final voice = ref.watch(voiceAvailableProvider);
    final premium = ref.watch(premiumProvider).value ?? false;
    final used = ref.watch(sessionsThisWeekProvider).value;
    final left = used == null ? null : freeSessionsPerWeek - used;
    final String? quotaLabel = premium || left == null
        ? null
        : left > 0
        ? l10n.freeLeft(left, freeSessionsPerWeek)
        : l10n.noFreeLeft;

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
                  child: Row(
                    children: [
                      Text(l10n.tabShama.toUpperCase(), style: AppText.label),
                      const Spacer(),
                      if (quotaLabel != null)
                        TextButton(
                          onPressed: () => context.push(Routes.plans),
                          child: Text(
                            quotaLabel.toUpperCase(),
                            style: AppText.label,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (chat.messages.isEmpty)
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
                    ],
                  ),
                ),
              Expanded(
                child: ListView(
                  // Newest first + reverse: newest sits at the bottom.
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    16,
                    AppSpacing.screenH,
                    0,
                  ),
                  children: [
                    for (final m in chat.messages.reversed)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: switch (m) {
                          UserMessage(:final text) => _Bubble(text),
                          AppMessage(:final reply, :final emotion) => Text(
                            _replyText(l10n, reply, emotion),
                            style: AppText.say,
                          ),
                        },
                      ),
                  ],
                ),
              ),
              Padding(
                // Clears the floating tab bar.
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  16,
                  AppSpacing.screenH,
                  124,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chat.pending case final emotion?)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Chip(
                            label: l10n.yes,
                            selected: true,
                            onTap: () => _start(emotion),
                          ),
                          _Chip(
                            label: l10n.somethingElse,
                            onTap: ref.read(moodChatProvider.notifier).notQuite,
                          ),
                        ],
                      )
                    else
                      // Sessions always open: duas are there even before the
                      // scholar's verses; offline, the player says so.
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final e in moodChips)
                            _Chip(
                              label: l10n.emotionName(e),
                              onTap: () => _start(e),
                            ),
                        ],
                      ),
                    const SizedBox(height: 14),
                    _InputBar(
                      onVoice: voice
                          ? () => context.push(Routes.shamaVoice)
                          : null,
                      controller: _draft,
                      thinking: chat.thinking,
                      onSend: _send,
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

  String _replyText(AppLocalizations l10n, Reply reply, Emotion? emotion) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return switch (reply) {
      Reply.feeling => l10n.replyFeeling(
        emotionInSentence(l10n, emotion!, locale),
      ),
      Reply.tellMore => l10n.replyTellMore,
      Reply.unavailable => l10n.replyUnavailable,
    };
  }
}

/// The user's words, the prototype's glass `.bub` on the end side.
class _Bubble extends StatelessWidget {
  const _Bubble(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            border: Border.all(color: AppColors.glassEdge),
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(22),
              topEnd: Radius.circular(22),
              bottomStart: Radius.circular(22),
              bottomEnd: Radius.circular(6),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// The prototype's glass `.inbar` with the cream send button.
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.onVoice,
    required this.controller,
    required this.thinking,
    required this.onSend,
  });

  /// Opens the voice screen; null hides the mic.
  final VoidCallback? onVoice;
  final TextEditingController controller;
  final bool thinking;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasText = controller.text.trim().isNotEmpty;
    // Stays usable while a reply is pending so the keyboard and focus
    // aren't lost; only Send waits.
    final canSend = !thinking && hasText;
    // Empty box: the button is the mic (prototype), when voice is offered.
    final showMic = !hasText && !thinking && onVoice != null;
    return Container(
      height: 56,
      padding: const EdgeInsetsDirectional.only(start: 20, end: 6),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.glassEdge),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 1000,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => canSend ? onSend() : null,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: l10n.tellMeInYourWords,
                hintStyle: const TextStyle(color: AppColors.textFaint),
                border: InputBorder.none,
                counterText: '',
                isDense: true,
              ),
            ),
          ),
          SizedBox.square(
            dimension: 44,
            child: FilledButton(
              onPressed: showMic ? onVoice : (canSend ? onSend : null),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ctaBackground,
                foregroundColor: AppColors.ctaForeground,
                disabledBackgroundColor: AppColors.ctaBackground.withValues(
                  alpha: 0.35,
                ),
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: thinking
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ctaForeground,
                      ),
                    )
                  : showMic
                  ? Icon(
                      Icons.graphic_eq,
                      size: 18,
                      semanticLabel: l10n.talkInstead,
                    )
                  : Icon(
                      Icons.arrow_upward,
                      size: 18,
                      semanticLabel: l10n.send,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The prototype's small `.opt.sm` pill; [selected] is the cream `.on`.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.ctaForeground
        : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.pillSelected : AppColors.pillFill,
      shape: StadiumBorder(
        side: selected
            ? BorderSide.none
            : const BorderSide(color: AppColors.pillEdge),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          // widthFactor 1: hug the label instead of filling the row.
          child: Center(
            widthFactor: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(Icons.check, size: 13, color: foreground),
                  const SizedBox(width: 6),
                ],
                Text(
                  label.toUpperCase(),
                  style: AppText.pill.copyWith(fontSize: 10, color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
