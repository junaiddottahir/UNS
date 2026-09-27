import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'verse_ref.dart';

/// Thrown when a Quran source can't be reached or answers unexpectedly.
class QuranSourceException implements Exception {
  QuranSourceException(this.message);
  final String message;

  @override
  String toString() => 'QuranSourceException: $message';
}

/// Fetches verse text from the fawazahmed0 Quran API. The text is returned
/// exactly as received; nothing here alters it.
class QuranTextClient {
  QuranTextClient(this._http, {this.baseUrl = AppConfig.quranTextBaseUrl});

  final http.Client _http;
  final String baseUrl;

  Future<String> fetch(String edition, VerseRef ref) async {
    final json = await _get(
      '$baseUrl/editions/$edition/${ref.surah}/${ref.ayah}.min.json',
      '$ref',
    );
    // Check it's the verse we asked for before trusting it.
    if (json is! Map<String, Object?> ||
        json['chapter'] != ref.surah ||
        json['verse'] != ref.ayah ||
        json['text'] is! String ||
        (json['text'] as String).trim().isEmpty) {
      throw QuranSourceException('unexpected text response for $ref');
    }
    return json['text'] as String;
  }

  /// Every verse of [surah] in order, index 0 being ayah 1.
  Future<List<String>> fetchSurah(String edition, int surah) async {
    final json = await _get(
      '$baseUrl/editions/$edition/$surah.min.json',
      'surah $surah',
      timeout: const Duration(seconds: 30), // Al-Baqarah is ~80 KB
    );
    final verses = json is Map<String, Object?> ? json['chapter'] : null;
    // Check it's the whole surah we asked for, in order, before trusting it.
    if (verses is! List || verses.length != ayahCounts[surah - 1]) {
      throw QuranSourceException('unexpected text response for surah $surah');
    }
    return [
      for (final (i, v) in verses.indexed)
        if (v is Map<String, Object?> &&
            v['chapter'] == surah &&
            v['verse'] == i + 1 &&
            v['text'] is String &&
            (v['text'] as String).trim().isNotEmpty)
          v['text'] as String
        else
          throw QuranSourceException('unexpected verse ${i + 1} of $surah'),
    ];
  }

  Future<Object?> _get(
    String url,
    String what, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final http.Response response;
    try {
      response = await _http.get(Uri.parse(url)).timeout(timeout);
    } on Exception catch (e) {
      throw QuranSourceException('text request failed: $e');
    }
    if (response.statusCode != 200) {
      throw QuranSourceException('text ${response.statusCode} for $what');
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw QuranSourceException('text for $what is not JSON');
    }
  }
}
