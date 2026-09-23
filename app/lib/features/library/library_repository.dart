import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/storage/settings_store.dart';
import 'verse_library.dart';

/// The verse library from the Uns backend, cached on the device so
/// sessions work offline. Revalidated with the ETag.
class LibraryRepository {
  LibraryRepository(
    this._http,
    this._store, {
    this.baseUrl = AppConfig.apiBaseUrl,
  });

  final http.Client _http;
  final SettingsStore _store;
  final String baseUrl;

  /// The cached library, if any.
  VerseLibrary? cached() {
    final json = _store.readJson(SettingKeys.library);
    if (json == null) return null;
    try {
      return VerseLibrary.fromJson(json['body']);
    } on FormatException {
      return null;
    }
  }

  /// Fetches a newer library if there is one; falls back to the cache
  /// when offline. Null only when there's neither.
  Future<VerseLibrary?> refresh() async {
    final stored = _store.readJson(SettingKeys.library);
    final etag = stored?['etag'];
    try {
      final response = await _http
          .get(
            Uri.parse('$baseUrl/v1/library'),
            headers: {if (etag is String) 'If-None-Match': etag},
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 304) return cached();
      if (response.statusCode != 200) return cached();
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      final library = VerseLibrary.fromJson(body); // validate before saving
      _store.writeJson(SettingKeys.library, {
        'etag': response.headers['etag'],
        'body': body,
      });
      return library;
    } on Exception {
      return cached();
    }
  }
}
