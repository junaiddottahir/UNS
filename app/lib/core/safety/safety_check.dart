import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Looks for self-harm language on the phone. A plain phrase match, not
/// AI, so it can run on journal text too (architecture.md). A match shows
/// support resources instead of a session.
class SafetyCheck {
  SafetyCheck(Iterable<String> phrases)
    : _phrases = [
        for (final p in phrases)
          if (normalizeForSafety(p).isNotEmpty)
            (normalizeForSafety(p), stem: p.trim().endsWith('*')),
      ];

  static const assetPath = 'assets/data/safety_phrases.json';

  final List<(String, {bool stem})> _phrases;

  static Future<SafetyCheck> load(AssetBundle bundle) async {
    final json = jsonDecode(await bundle.loadString(assetPath));
    if (json is! Map<String, Object?>) {
      throw const FormatException('safety phrases: not an object');
    }
    List<String> list(String key) {
      final v = json[key];
      if (v is! List || v.any((e) => e is! String)) {
        throw FormatException('safety phrases: "$key" is not a string list');
      }
      return v.cast<String>();
    }

    return SafetyCheck([...list('en'), ...list('ar')]);
  }

  /// Whether [text] contains a listed phrase as whole words ("want to
  /// die", not "want to diet"). A stem (listed with a trailing `*`) may
  /// continue: "suicid*" catches "suicide" and "suicidal".
  bool isRisky(String text) {
    final t = ' ${normalizeForSafety(text)} ';
    for (final (phrase, :stem) in _phrases) {
      var from = 0;
      while (true) {
        final i = t.indexOf(phrase, from);
        if (i < 0) break;
        final end = i + phrase.length;
        final start = t.lastIndexOf(' ', i) + 1;
        final attached = t.substring(start, i);
        final startsWord =
            attached.isEmpty ||
            (_isArabic(phrase) && _arabicPrefixes.contains(attached));
        if (startsWord && (stem || t[end] == ' ')) return true;
        from = i + 1;
      }
    }
    return false;
  }
}

/// Arabic words carry attached prefixes ("the", "and", "with"…), e.g.
/// الانتحار = "the suicide"; a phrase may follow one of these.
const _arabicPrefixes = {
  'ال', 'و', 'ف', 'ب', 'ل', 'ك', 'لل', //
  'وال', 'فال', 'بال', 'كال', 'ول', 'وب', 'فب', 'وسا', 'سا',
};

bool _isArabic(String s) => s.runes.any((r) => r >= 0x0600 && r <= 0x06FF);

final _arabicMarks = RegExp('[ؐ-ًؚ-ٰٟۖ-ۭـ]');
final _notWord = RegExp(r"[^\p{L}\p{N}]+", unicode: true);

/// Lowercases; drops apostrophes ("don't" → "dont"); strips Arabic
/// diacritics and tatweel; folds Arabic letter variants; turns everything
/// else that isn't a letter or digit into single spaces.
String normalizeForSafety(String input) {
  final lower = input
      .toLowerCase()
      .replaceAll(RegExp("['’‘`]"), '')
      .replaceAll(_arabicMarks, '');
  final folded = StringBuffer();
  for (final ch in lower.split('')) {
    folded.write(switch (ch) {
      'أ' || 'إ' || 'آ' || 'ٱ' => 'ا',
      'ؤ' => 'و',
      'ئ' || 'ى' => 'ي',
      'ة' => 'ه',
      _ => ch,
    });
  }
  return folded.toString().replaceAll(_notWord, ' ').trim();
}

final safetyCheckProvider = FutureProvider<SafetyCheck>(
  (ref) => SafetyCheck.load(rootBundle),
);
