import '../../l10n/app_localizations.dart';

/// The day's reflection prompt, rotating through a short list (the first
/// is the prototype's). Pending review, see progress-tracker.md.
String reflectionPromptFor(AppLocalizations l10n, DateTime day) {
  final prompts = [l10n.prompt1, l10n.prompt2, l10n.prompt3, l10n.prompt4];
  final dayNumber = DateTime.utc(
    day.year,
    day.month,
    day.day,
  ).difference(DateTime.utc(2026)).inDays;
  return prompts[dayNumber % prompts.length];
}
