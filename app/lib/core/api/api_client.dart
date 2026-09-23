import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_service.dart';
import '../config/app_config.dart';
import '../quran/quran_providers.dart';

/// The backend couldn't do it (offline, signed out, server error).
class ApiException implements Exception {
  const ApiException(this.status);
  final int? status;
}

/// Calls the Uns backend's signed-in endpoints (`/v1/me…`) with the
/// Supabase access token. Never used for classify (no identifiers there).
class AccountApi {
  AccountApi(this._http, this._auth, {this.baseUrl = AppConfig.apiBaseUrl});

  final http.Client _http;
  final AuthService _auth;
  final String baseUrl;

  Future<Object?> send(String method, String path, {Object? body}) async {
    final token = await _auth.accessToken();
    if (token == null) throw const ApiException(401);
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers['authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _http.send(request).timeout(const Duration(seconds: 20)),
      );
    } on Exception {
      throw const ApiException(null);
    }
    if (response.statusCode >= 300) throw ApiException(response.statusCode);
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }

  /// Deletes the account and everything synced with it.
  Future<void> deleteAccount() => send('DELETE', '/v1/me');

  Future<Map<String, Object?>> putSettings(
    Map<String, Object?> settings,
    DateTime changedAt,
  ) async => (await send(
    'PUT',
    '/v1/me/settings',
    body: {
      'settings': settings,
      'updated_at': changedAt.toUtc().toIso8601String(),
    },
  )) as Map<String, Object?>;

  Future<Map<String, Object?>> getSettings() async =>
      (await send('GET', '/v1/me/settings')) as Map<String, Object?>;

  /// Sends daily totals; returns the account's full history.
  Future<List<Object?>> putTasbih(List<Map<String, Object?>> days) async =>
      ((await send('PUT', '/v1/me/tasbih', body: {'days': days}))
              as Map<String, Object?>)['days']
          as List<Object?>;
}

final accountApiProvider = Provider<AccountApi>(
  (ref) =>
      AccountApi(ref.watch(httpClientProvider), ref.watch(authServiceProvider)),
);
