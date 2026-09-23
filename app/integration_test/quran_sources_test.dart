import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uns/core/config/app_config.dart';
import 'package:uns/core/quran/quran_repository.dart';
import 'package:uns/core/quran/quran_text_client.dart';
import 'package:uns/core/quran/recitation_client.dart';
import 'package:uns/core/quran/verse_ref.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/features/reciter/reciter.dart';

/// Hits the real Quran text API and UmmahAPI (needs a network):
///   flutter test integration_test/quran_sources_test.dart -d SIMULATOR_ID
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final sample = VerseRef(
    AppConfig.reciterSampleSurah,
    AppConfig.reciterSampleAyah,
  );

  testWidgets('verse text is fetched and cached in the encrypted database', (
    tester,
  ) async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/${AppDatabase.fileName}');
    if (file.existsSync()) file.deleteSync();
    final db = await AppDatabase.open();
    final client = http.Client();
    final repo = QuranRepository(db, QuranTextClient(client));

    final verse = await repo.verse(sample);
    expect(verse.arabic.trim(), isNotEmpty);
    expect(verse.translation.trim(), isNotEmpty);
    expect(await repo.isCached(sample), isTrue);

    // Offline now: the cache answers, identical to what was fetched.
    client.close();
    final offline = QuranRepository(
      db,
      QuranTextClient(http.Client()..close()),
    );
    final cached = await offline.verse(sample);
    expect(cached.arabic, verse.arabic);
    expect(cached.translation, verse.translation);
    await db.close();
  });

  testWidgets('each offered reciter\'s sample downloads and plays', (
    tester,
  ) async {
    final dir = await getApplicationSupportDirectory();
    final audioDir = Directory('${dir.path}/recitations');
    if (audioDir.existsSync()) audioDir.deleteSync(recursive: true);
    final client = http.Client();
    final repo = RecitationRepository(
      RecitationClient(client),
      client,
      getApplicationSupportDirectory,
    );
    final player = AudioPlayer();
    for (final reciter in Reciter.values) {
      final file = await repo.audio(reciter.source, sample);
      expect(file.lengthSync(), greaterThan(10000), reason: reciter.name);
      final duration = await player.setFilePath(file.path);
      expect(duration, isNotNull, reason: reciter.name);
      expect(duration!.inMilliseconds, greaterThan(1000), reason: reciter.name);
    }
    await player.dispose();
    client.close();
  });
}
