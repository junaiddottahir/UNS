import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uns/core/quran/quran_repository.dart';
import 'package:uns/core/quran/quran_text_client.dart';
import 'package:uns/core/quran/recitation_client.dart';
import 'package:uns/core/quran/verse_ref.dart';
import 'package:uns/core/storage/app_database.dart';

// Sample strings for parsing tests only (Arabic with diacritics and a
// combining mark, to prove bytes pass through unchanged).
const _arabic = 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ';
const _english = '[All] praise is [due] to Allah, Lord of the worlds -';

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

final _ref = VerseRef(1, 2);

void main() {
  group('VerseRef', () {
    test('Hafs counts', () {
      expect(ayahCounts.length, 114);
      expect(ayahCounts.reduce((a, b) => a + b), 6236);
    });

    test('only real verses', () {
      expect(VerseRef.isValid(2, 286), isTrue);
      expect(VerseRef.isValid(2, 287), isFalse);
      expect(VerseRef.isValid(0, 1), isFalse);
      expect(() => VerseRef(115, 1), throwsArgumentError);
      expect(VerseRef(2, 255).paddedKey, '002255');
    });
  });

  group('QuranTextClient', () {
    test('returns the text byte for byte', () async {
      final client = QuranTextClient(
        MockClient((req) async {
          expect(
            req.url.path,
            endsWith('/editions/ara-quranuthmanihaf/1/2.min.json'),
          );
          return _json({'chapter': 1, 'verse': 2, 'text': _arabic});
        }),
      );
      final text = await client.fetch('ara-quranuthmanihaf', _ref);
      expect(utf8.encode(text), utf8.encode(_arabic));
    });

    test('rejects a different verse, a bad status or bad JSON', () async {
      Future<void> expectRejected(http.Response r) => expectLater(
        QuranTextClient(MockClient((_) async => r)).fetch('e', _ref),
        throwsA(isA<QuranSourceException>()),
      );
      await expectRejected(_json({'chapter': 1, 'verse': 3, 'text': 'x'}));
      await expectRejected(_json({'chapter': 1, 'verse': 2, 'text': ''}));
      await expectRejected(_json({'error': 'nope'}, 404));
      await expectRejected(http.Response('<html>', 200));
    });
  });

  group('RecitationClient', () {
    Map<String, Object?> body(List<Map<String, Object?>> reciters) => {
      'success': true,
      'data': {'verse_key': '1:2', 'reciters': reciters},
    };
    const alafasy = ReciterSource(id: 1, nameContains: 'Alafasy');

    test('finds the reciter\'s https link', () async {
      final client = RecitationClient(
        MockClient(
          (_) async => _json(
            body([
              {
                'id': 1,
                'name': 'Mishary Rashid Alafasy',
                'audio_url': 'https://everyayah.com/data/A/001002.mp3',
              },
            ]),
          ),
        ),
      );
      final url = await client.audioUrl(alafasy, _ref);
      expect(url.toString(), 'https://everyayah.com/data/A/001002.mp3');
    });

    test('rejects a renamed reciter, http links and missing reciters', () {
      Future<void> expectRejected(List<Map<String, Object?>> reciters) =>
          expectLater(
            RecitationClient(MockClient((_) async => _json(body(reciters))))
                .audioUrl(alafasy, _ref),
            throwsA(isA<QuranSourceException>()),
          );
      return Future.wait([
        expectRejected([
          {'id': 1, 'name': 'Someone Else', 'audio_url': 'https://x/a.mp3'},
        ]),
        expectRejected([
          {'id': 1, 'name': 'Alafasy', 'audio_url': 'http://x/a.mp3'},
        ]),
        expectRejected([
          {'id': 2, 'name': 'Alafasy', 'audio_url': 'https://x/a.mp3'},
        ]),
      ]);
    });
  });

  group('QuranRepository', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('fetches once, then serves from the cache offline', () async {
      var calls = 0;
      var online = true;
      final repo = QuranRepository(
        db,
        QuranTextClient(
          MockClient((req) async {
            if (!online) throw const SocketException('offline');
            calls++;
            final arabic = req.url.path.contains('ara-');
            return _json({
              'chapter': 1,
              'verse': 2,
              'text': arabic ? _arabic : _english,
            });
          }),
        ),
      );
      expect(await repo.isCached(_ref), isFalse);
      final first = await repo.verse(_ref);
      expect(calls, 2);
      expect(await repo.isCached(_ref), isTrue);

      online = false;
      final again = await repo.verse(_ref);
      expect(calls, 2);
      expect(utf8.encode(again.arabic), utf8.encode(_arabic));
      expect(again.translation, first.translation);
    });
  });

  group('RecitationRepository', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('uns_audio'));
    tearDown(() => dir.deleteSync(recursive: true));
    const reciter = ReciterSource(id: 1, nameContains: 'Alafasy');

    RecitationRepository repo(http.Client http) =>
        RecitationRepository(RecitationClient(http), http, () async => dir);

    MockClient server({required String audioType, List<int>? audio}) =>
        MockClient((req) async {
          if (req.url.host == 'ummahapi.com') {
            return _json({
              'data': {
                'verse_key': '1:2',
                'reciters': [
                  {
                    'id': 1,
                    'name': 'Mishary Rashid Alafasy',
                    'audio_url': 'https://everyayah.com/001002.mp3',
                  },
                ],
              },
            });
          }
          return http.Response.bytes(
            audio ?? [1, 2, 3],
            200,
            headers: {'content-type': audioType},
          );
        });

    test('downloads once and reuses the file', () async {
      final first = await repo(server(audioType: 'audio/mpeg'))
          .audio(reciter, _ref);
      expect(first.path, endsWith('recitations/1/001002.mp3'));
      expect(first.readAsBytesSync(), [1, 2, 3]);

      final offline = repo(
        MockClient((_) async => throw const SocketException('offline')),
      );
      expect((await offline.audio(reciter, _ref)).path, first.path);
      expect(await offline.isCached(reciter, _ref), isTrue);
    });

    test('a non-audio answer leaves nothing behind', () async {
      await expectLater(
        repo(server(audioType: 'text/html')).audio(reciter, _ref),
        throwsA(isA<QuranSourceException>()),
      );
      expect(dir.listSync(recursive: true).whereType<File>(), isEmpty);
    });
  });
}
