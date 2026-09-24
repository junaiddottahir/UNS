import '../quran/verse_ref.dart';

/// A dua exactly as UmmahAPI sends it: Arabic, transliteration and
/// translation, with its hadith source.
class Dua {
  const Dua({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.source,
    this.repeat = 1,
  });

  final int id;

  /// UmmahAPI's category id, e.g. `distress`.
  final String category;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;

  /// Where it's narrated, e.g. "Sahih Al-Bukhari 8:154".
  final String source;

  /// How many times it's traditionally said.
  final int repeat;

  static final _quran = RegExp(r'Quran\s+(\d+):(\d+)(?:-(\d+))?');

  /// The verses this dua is, when its source is the Quran: the first
  /// reference cited (e.g. "Quran 2:285-286" → 2:285, 2:286). Their
  /// recitation plays while it's shown. Empty for duas from hadith.
  List<VerseRef> get quranVerses {
    final m = _quran.firstMatch(source);
    if (m == null) return const [];
    final surah = int.parse(m[1]!);
    final first = int.parse(m[2]!);
    final last = m[3] == null ? first : int.parse(m[3]!);
    if (last < first || last - first > 10) return const [];
    return [
      for (var a = first; a <= last; a++)
        if (VerseRef.isValid(surah, a)) VerseRef(surah, a),
    ];
  }

  /// Null when a field is missing or empty, so a malformed entry is
  /// skipped rather than shown half-filled.
  static Dua? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    String? text(String key) => switch (json[key]) {
      final String s when s.trim().isNotEmpty => s.trim(),
      _ => null,
    };
    final (id, category, title, arabic, translation, source) = (
      json['id'],
      text('category'),
      text('title'),
      text('arabic'),
      text('translation'),
      text('source'),
    );
    if (id is! int ||
        category == null ||
        title == null ||
        arabic == null ||
        translation == null ||
        source == null) {
      return null;
    }
    final repeat = json['repeat'];
    return Dua(
      id: id,
      category: category,
      title: title,
      arabic: arabic,
      transliteration: text('transliteration') ?? '',
      translation: translation,
      source: source,
      repeat: repeat is int && repeat > 0 ? repeat : 1,
    );
  }
}

/// The duas in UmmahAPI's `/api/duas` response body.
List<Dua> parseDuas(Object? body) {
  final data = body is Map<String, Object?> ? body['data'] : null;
  final list = data is Map<String, Object?> ? data['duas'] : null;
  if (list is! List) throw const FormatException('No duas in the response.');
  return [for (final item in list) ?Dua.fromJson(item)];
}
