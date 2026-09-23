import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../library/verse_library.dart';

/// What the backend made of the user's words.
class MoodReading {
  const MoodReading({required this.emotion, required this.risk});

  /// Null when the backend couldn't place it ("unknown").
  final Emotion? emotion;
  final bool risk;
}

/// Thrown when classification isn't available (offline, no key, rate
/// limited); the chat then asks the user to pick a feeling.
class ClassifyUnavailable implements Exception {
  const ClassifyUnavailable();
}

/// Sends typed (or transcribed) mood text to `POST /v1/classify` — the
/// text only, with no user ID, token or device details.
class ClassifyClient {
  ClassifyClient(this._http, {this.baseUrl = AppConfig.apiBaseUrl});

  final http.Client _http;
  final String baseUrl;

  Future<MoodReading> classify(String text) async {
    final http.Response response;
    try {
      response = await _http
          .post(
            Uri.parse('$baseUrl/v1/classify'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 20));
    } on Exception {
      throw const ClassifyUnavailable();
    }
    if (response.statusCode != 200) throw const ClassifyUnavailable();
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ClassifyUnavailable();
    }
    if (json is! Map<String, Object?> || json['risk'] is! bool) {
      throw const ClassifyUnavailable();
    }
    return MoodReading(
      // Anything outside the fixed list counts as unknown.
      emotion: Emotion.values.asNameMap()[json['category']],
      risk: json['risk'] as bool,
    );
  }
}
