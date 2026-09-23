import '../../core/quran/verse_ref.dart';

/// The scope's fixed emotion categories (mirrors the backend enum).
enum Emotion {
  sadness,
  anxiety,
  anger,
  loneliness,
  gratitude,
  hope,
  humility,
  arrogance,
  greed,
}

/// How a verse helps: "comfort me" uses [comfort]; "remind me" uses the
/// other two.
enum VerseTag { comfort, gentleReminder, warning }

class LibraryEntry {
  const LibraryEntry(this.ref, this.emotion, this.tag);
  final VerseRef ref;
  final Emotion emotion;
  final VerseTag tag;
}

/// The approved verse library: references and tags only.
class VerseLibrary {
  const VerseLibrary({
    required this.version,
    required this.placeholder,
    required this.entries,
  });

  final String version;

  /// True until the scholar's library replaces the stand-in; sessions
  /// never run from a placeholder.
  final bool placeholder;
  final List<LibraryEntry> entries;

  static const _tags = {
    'comfort': VerseTag.comfort,
    'gentle_reminder': VerseTag.gentleReminder,
    'warning': VerseTag.warning,
  };

  /// Parses the backend's JSON. A placeholder may use surah 0; an approved
  /// library must be all real verses. Throws [FormatException] otherwise.
  factory VerseLibrary.fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('library is not an object');
    }
    final version = json['version'];
    final placeholder = json['placeholder'];
    final entries = json['entries'];
    if (version is! String || placeholder is! bool || entries is! List) {
      throw const FormatException('library is missing fields');
    }
    final parsed = <LibraryEntry>[];
    for (final e in entries) {
      if (e is! Map<String, Object?>) {
        throw const FormatException('library entry is not an object');
      }
      final (surah, ayah) = (e['surah'], e['ayah']);
      final emotion = Emotion.values.asNameMap()[e['category']];
      final tag = _tags[e['tag']];
      if (surah is! int || ayah is! int || emotion == null || tag == null) {
        throw FormatException('bad library entry: $e');
      }
      if (placeholder) continue; // stand-in refs aren't verses
      if (!VerseRef.isValid(surah, ayah)) {
        throw FormatException('not a verse: $surah:$ayah');
      }
      parsed.add(LibraryEntry(VerseRef(surah, ayah), emotion, tag));
    }
    return VerseLibrary(
      version: version,
      placeholder: placeholder,
      entries: parsed,
    );
  }

  /// Verses for [emotion]: comfort, or the reminder tags.
  List<VerseRef> versesFor(Emotion emotion, {required bool comfort}) => [
    for (final e in entries)
      if (e.emotion == emotion &&
          (comfort ? e.tag == VerseTag.comfort : e.tag != VerseTag.comfort))
        e.ref,
  ];
}
