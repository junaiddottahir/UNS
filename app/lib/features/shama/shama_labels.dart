import '../../l10n/app_localizations.dart';
import '../library/verse_library.dart';

/// The chips on the Shama tab, as in the prototype. The other three
/// categories are reached from free text (unit 12).
const moodChips = [
  Emotion.anxiety,
  Emotion.sadness,
  Emotion.loneliness,
  Emotion.anger,
  Emotion.gratitude,
  Emotion.hope,
];

/// "How do you feel now?" answers, stored by name.
enum AfterMood { calmer, better, same, heavier }

extension ShamaLabels on AppLocalizations {
  String emotionName(Emotion e) => switch (e) {
    Emotion.anxiety => moodAnxious,
    Emotion.sadness => moodSad,
    Emotion.loneliness => moodLonely,
    Emotion.anger => moodAngry,
    Emotion.gratitude => moodGrateful,
    Emotion.hope => moodHopeful,
    Emotion.humility => moodHumble,
    Emotion.arrogance => moodArrogant,
    Emotion.greed => moodGreedy,
  };

  String helpName({required bool comfort}) =>
      comfort ? helpComfort : helpRemind;

  String afterMoodName(AfterMood m) => switch (m) {
    AfterMood.calmer => afterCalmer,
    AfterMood.better => afterBetter,
    AfterMood.same => afterSame,
    AfterMood.heavier => afterHeavier,
  };
}

/// The feeling as it reads mid-sentence ("feeling anxious"): lower case
/// in English, unchanged in Arabic.
String emotionInSentence(AppLocalizations l10n, Emotion e, String locale) {
  final name = l10n.emotionName(e);
  return locale.startsWith('en') ? name.toLowerCase() : name;
}
