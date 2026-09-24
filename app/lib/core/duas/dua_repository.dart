import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../quran/quran_providers.dart';
import '../storage/app_database.dart';
import 'dua.dart';

/// The dua collection: downloaded whole, kept on the phone, refreshed
/// when older than [maxAge]. Offline, the last copy is used.
class DuaRepository {
  DuaRepository(this._db, this._http, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const maxAge = Duration(days: 30);
  static const _key = 'duas';

  final AppDatabase _db;
  final http.Client _http;
  final DateTime Function() _now;

  /// Every dua; throws if there's no copy and it can't be downloaded.
  Future<List<Dua>> all() async {
    final cached = await (_db.select(
      _db.contentCache,
    )..where((t) => t.key.equals(_key))).getSingleOrNull();
    if (cached != null && _now().difference(cached.fetchedAt) < maxAge) {
      return parseDuas(jsonDecode(cached.body));
    }
    try {
      final response = await _http
          .get(Uri.parse(AppConfig.duasUrl))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw http.ClientException('Duas: HTTP ${response.statusCode}');
      }
      final body = utf8.decode(response.bodyBytes);
      final duas = parseDuas(jsonDecode(body));
      if (duas.isEmpty) throw const FormatException('Empty dua list.');
      await _db
          .into(_db.contentCache)
          .insertOnConflictUpdate(
            ContentCacheCompanion.insert(
              key: _key,
              body: body,
              fetchedAt: _now(),
            ),
          );
      return duas;
    } on Exception {
      if (cached != null) return parseDuas(jsonDecode(cached.body));
      rethrow;
    }
  }
}

final duaRepositoryProvider = Provider<DuaRepository>(
  (ref) => DuaRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(httpClientProvider),
  ),
);
