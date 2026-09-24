import '../library/verse_library.dart';

/// UmmahAPI dua categories offered for each feeling. Picked on the phone,
/// so the feeling itself is never sent. Draft: for the scholar to review.
List<String> duaCategoriesFor(Emotion e, {required bool comfort}) {
  final base = switch (e) {
    Emotion.anxiety => ['distress', 'protection'],
    Emotion.sadness => ['grief', 'distress'],
    Emotion.loneliness => ['distress', 'guidance'],
    Emotion.anger => ['forgiveness', 'protection'],
    Emotion.gratitude => ['gratitude', 'dhikr'],
    Emotion.hope => ['guidance', 'gratitude'],
    Emotion.humility => ['forgiveness', 'gratitude'],
    Emotion.arrogance => ['forgiveness', 'dhikr'],
    Emotion.greed => ['gratitude', 'business'],
  };
  // "Remind me" adds everyday remembrance.
  return comfort || base.contains('dhikr') ? base : [...base, 'dhikr'];
}
