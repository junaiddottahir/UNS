import 'dart:io';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../storage/app_database.dart';
import 'quran_text_client.dart';
import 'recitation_client.dart';
import 'verse_ref.dart';

/// Arabic and translation for one verse, unchanged from the source.
class VerseText {
  const VerseText({
    required this.ref,
    required this.arabic,
    required this.translation,
  });

  final VerseRef ref;
  final String arabic;
  final String translation;
}

/// Verse text: from the on-device cache, else fetched once and cached.
class QuranRepository {
  QuranRepository(this._db, this._client);

  final AppDatabase _db;
  final QuranTextClient _client;

  Future<VerseText> verse(VerseRef ref) async {
    final (arabic, translation) = await (
      _text(AppConfig.arabicEdition, ref),
      _text(AppConfig.translationEdition, ref),
    ).wait;
    return VerseText(ref: ref, arabic: arabic, translation: translation);
  }

  Future<String> _text(String edition, VerseRef ref) async {
    final cached =
        await (_db.select(_db.verseTexts)..where(
              (t) =>
                  t.edition.equals(edition) &
                  t.surah.equals(ref.surah) &
                  t.ayah.equals(ref.ayah),
            ))
            .getSingleOrNull();
    if (cached != null) return cached.body;

    final body = await _client.fetch(edition, ref);
    await _db
        .into(_db.verseTexts)
        .insertOnConflictUpdate(
          VerseTextsCompanion.insert(
            edition: edition,
            surah: ref.surah,
            ayah: ref.ayah,
            body: body,
          ),
        );
    return body;
  }

  /// Whether both editions of [ref] are cached (usable offline).
  Future<bool> isCached(VerseRef ref) async {
    final count =
        await (_db.selectOnly(_db.verseTexts)
              ..addColumns([_db.verseTexts.edition.count()])
              ..where(
                _db.verseTexts.surah.equals(ref.surah) &
                    _db.verseTexts.ayah.equals(ref.ayah) &
                    _db.verseTexts.edition.isIn([
                      AppConfig.arabicEdition,
                      AppConfig.translationEdition,
                    ]),
              ))
            .map((r) => r.read(_db.verseTexts.edition.count()))
            .getSingle();
    return count == 2;
  }
}

/// Per-ayah recitation files, downloaded once into [directory].
class RecitationRepository {
  RecitationRepository(this._client, this._http, this._directory);

  final RecitationClient _client;
  final http.Client _http;
  final Future<Directory> Function() _directory;

  Future<File> _fileFor(ReciterSource reciter, VerseRef ref) async {
    final dir = await _directory();
    return File('${dir.path}/recitations/${reciter.id}/${ref.paddedKey}.mp3');
  }

  /// The ayah's audio on disk, downloading it first if needed.
  Future<File> audio(ReciterSource reciter, VerseRef ref) async {
    final file = await _fileFor(reciter, ref);
    if (file.existsSync() && file.lengthSync() > 0) return file;

    final url = await _client.audioUrl(reciter, ref);
    final http.Response response;
    try {
      response = await _http.get(url).timeout(const Duration(seconds: 60));
    } on Exception catch (e) {
      throw QuranSourceException('audio download failed: $e');
    }
    final type = response.headers['content-type'] ?? '';
    if (response.statusCode != 200 ||
        response.bodyBytes.isEmpty ||
        !type.startsWith('audio/')) {
      throw QuranSourceException('bad audio for $ref (${response.statusCode})');
    }
    // Write then rename, so a failed download never leaves a partial file.
    await file.parent.create(recursive: true);
    final partial = File('${file.path}.part');
    await partial.writeAsBytes(response.bodyBytes, flush: true);
    return partial.rename(file.path);
  }

  Future<bool> isCached(ReciterSource reciter, VerseRef ref) async {
    final file = await _fileFor(reciter, ref);
    return file.existsSync() && file.lengthSync() > 0;
  }
}
