import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/safety/safety_check.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/step_top_bar.dart';
import '../../core/widgets/toast.dart';
import '../../l10n/app_localizations.dart';
import '../prayer/prayer_providers.dart';
import '../shama/mood_chat.dart';
import '../shama/shama_session.dart';
import 'reflection_prompts.dart';

/// A written reflection after a session, or (with [entryId]) editing a
/// journal entry's. It stays on the phone (encrypted) and is never read by
/// AI; the on-device phrase check still runs, and a match shows the
/// helpline after the entry is saved.
class WriteScreen extends ConsumerStatefulWidget {
  const WriteScreen({super.key, this.entryId});

  /// The journal entry being edited; null right after a session.
  final int? entryId;

  @override
  ConsumerState<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends ConsumerState<WriteScreen> {
  final _text = TextEditingController();
  bool _saving = false;

  bool get _editing => widget.entryId != null;

  @override
  void initState() {
    super.initState();
    if (widget.entryId case final id?) {
      ref.read(sessionStoreProvider).byId(id).then((entry) {
        if (!mounted || _text.text.isNotEmpty) return;
        _text.text = entry?.reflection ?? '';
      });
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final text = _text.text.trim();
    final risky =
        text.isNotEmpty &&
        (await ref.read(safetyCheckProvider.future)).isRisky(text);
    // The entry saves either way (architecture.md).
    if (widget.entryId case final id?) {
      await ref
          .read(sessionStoreProvider)
          .updateReflection(id, text.isEmpty ? null : text);
      if (!mounted) return;
      context.pop();
      if (risky) {
        context.push(Routes.support);
      } else {
        showToast(l10n.reflectionUpdated);
      }
      return;
    }
    await ref.read(shamaSessionProvider.notifier).save(reflection: text);
    ref.read(moodChatProvider.notifier).reset();
    if (!mounted) return;
    context.go(Routes.home);
    if (risky) {
      context.push(Routes.support);
    } else {
      showToast(text.isEmpty ? l10n.sessionSaved : l10n.reflectionSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prompt = reflectionPromptFor(l10n, ref.watch(nowProvider));
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const BackTopBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    30,
                    AppSpacing.screenH,
                    AppSpacing.screenBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (_editing ? l10n.editReflection : l10n.todaysPrompt)
                            .toUpperCase(),
                        style: AppText.label,
                      ),
                      const SizedBox(height: 12),
                      Text(prompt, style: AppText.title2),
                      Expanded(
                        child: TextField(
                          controller: _text,
                          autofocus: true,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.writeHint,
                            hintStyle: const TextStyle(
                              color: AppColors.textFaint,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(top: 24),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 13,
                            color: AppColors.textSubtle,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.onlyOnThisPhone.toUpperCase(),
                              style: AppText.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: _saving ? null : _finish,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.ctaBackground,
                                foregroundColor: AppColors.ctaForeground,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: Text(
                                _editing ? l10n.saveRecording : l10n.finish,
                              ),
                            ),
                          ),
                        ],
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
