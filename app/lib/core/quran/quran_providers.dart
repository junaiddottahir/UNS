import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../storage/app_database.dart';
import 'quran_repository.dart';
import 'quran_text_client.dart';
import 'recitation_client.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final quranRepositoryProvider = Provider<QuranRepository>(
  (ref) => QuranRepository(
    ref.watch(appDatabaseProvider),
    QuranTextClient(ref.watch(httpClientProvider)),
  ),
);

final recitationRepositoryProvider = Provider<RecitationRepository>((ref) {
  final http = ref.watch(httpClientProvider);
  return RecitationRepository(
    RecitationClient(http),
    http,
    getApplicationSupportDirectory,
  );
});
