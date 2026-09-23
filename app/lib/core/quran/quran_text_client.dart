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
    final uri = Uri.parse(
      '$baseUrl/editions/$edition/${ref.surah}/${ref.ayah}.min.json',
    );
    final http.Response response;
    try {
      response = await _http.get(uri).timeout(const Duration(seconds: 15));
    } on Exception catch (e) {
      throw QuranSourceException('text request failed: $e');
    }
    if (response.statusCode != 200) {
      throw QuranSourceException('text ${response.statusCode} for $ref');
    }
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw QuranSourceException('text for $ref is not JSON');
    }
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
}
