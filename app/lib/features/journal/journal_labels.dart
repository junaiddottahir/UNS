import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../core/storage/app_database.dart';
import '../../l10n/app_localizations.dart';
import '../library/verse_library.dart';
import '../shama/shama_labels.dart';

/// "Today 3:40 PM" or "Sun 21 Sep".
String entryDate(BuildContext context, DateTime at, DateTime now) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  final local = at.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  if (!DateTime(local.year, local.month, local.day).isBefore(today)) {
    return l10n.todayAt(DateFormat.jm(locale).format(local));
  }
  return DateFormat('EEE d MMM', locale).format(local);
}

/// "Anxious → Calmer" (a dash when no mood after was chosen).
String entryMoods(AppLocalizations l10n, Session s) {
  final before = Emotion.values.asNameMap()[s.emotion];
  final after = AfterMood.values.asNameMap()[s.moodAfter];
  return l10n.moodsBeforeAfter(
    before == null ? '—' : l10n.emotionName(before),
    after == null ? '—' : l10n.afterMoodName(after),
  );
}
