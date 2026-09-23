import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'quran_text_client.dart';
import 'verse_ref.dart';

/// A reciter as UmmahAPI lists it. [nameContains] guards against the API
/// renumbering its reciters.
class ReciterSource {
  const ReciterSource({required this.id, required this.nameContains});
  final int id;
  final String nameContains;
}

/// Finds per-ayah MP3 links via UmmahAPI.
class RecitationClient {
  RecitationClient(this._http, {this.baseUrl = AppConfig.recitationBaseUrl});

  final http.Client _http;
  final String baseUrl;

  Future<Uri> audioUrl(ReciterSource reciter, VerseRef ref) async {
    final uri = Uri.parse('$baseUrl/audio/${ref.surah}/${ref.ayah}');
    final http.Response response;
    try {
      response = await _http.get(uri).timeout(const Duration(seconds: 15));
    } on Exception catch (e) {
      throw QuranSourceException('recitation request failed: $e');
    }
    if (response.statusCode != 200) {
      throw QuranSourceException('recitation ${response.statusCode} for $ref');
    }
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw QuranSourceException('recitation for $ref is not JSON');
    }
    final data = json is Map<String, Object?> ? json['data'] : null;
    final reciters = data is Map<String, Object?> ? data['reciters'] : null;
    if (data is! Map<String, Object?> ||
        data['verse_key'] != '$ref' ||
        reciters is! List) {
      throw QuranSourceException('unexpected recitation response for $ref');
    }
    for (final r in reciters) {
      if (r is Map<String, Object?> && r['id'] == reciter.id) {
        final name = r['name'];
        final url = r['audio_url'];
        if (name is! String || !name.contains(reciter.nameContains)) {
          throw QuranSourceException('reciter ${reciter.id} is now "$name"');
        }
        final audio = url is String ? Uri.tryParse(url) : null;
        if (audio == null || audio.scheme != 'https' || audio.host.isEmpty) {
          throw QuranSourceException('no usable audio for $ref');
        }
        return audio;
      }
    }
    throw QuranSourceException('reciter ${reciter.id} not offered for $ref');
  }
}
