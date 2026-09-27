import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran/quran_providers.dart';
import '../../core/quran/quran_repository.dart';

/// A surah as the Quran API's info.json names it (bundled in
/// `assets/data/surahs.json` by `tools/quran/build_surahs.py`).
class Surah {
  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.arabicName,
    required this.meccan,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, Object?> json) => Surah(
    number: json['number']! as int,
    name: json['name']! as String,
    englishName: json['englishName']! as String,
    arabicName: json['arabicName']! as String,
    meccan: json['revelation'] == 'Mecca',
    ayahs: json['ayahs']! as int,
  );

  final int number;

  /// Transliterated, e.g. "Al-Faatiha".
  final String name;

  /// Meaning, e.g. "The Opening".
  final String englishName;
  final String arabicName;
  final bool meccan;
  final int ayahs;
}

const surahsAsset = 'assets/data/surahs.json';

final surahsProvider = FutureProvider<List<Surah>>((ref) async {
  final raw = await rootBundle.loadString(surahsAsset);
  return [
    for (final s in jsonDecode(raw) as List)
      Surah.fromJson(s as Map<String, Object?>),
  ];
});

/// A surah's verses, from the cache or fetched once.
final surahTextProvider = FutureProvider.autoDispose
    .family<List<VerseText>, int>(
      (ref, surah) => ref.read(quranRepositoryProvider).surah(surah),
    );
