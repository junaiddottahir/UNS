import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/library/library_repository.dart';
import 'package:uns/features/library/verse_library.dart';

import '../../support/test_app.dart';

Map<String, Object?> _json({
  bool placeholder = false,
  List<(int, int, String, String)> entries = const [(1, 1, 'hope', 'comfort')],
}) => {
  'version': 'v1',
  'placeholder': placeholder,
  'entries': [
    for (final (s, a, c, t) in entries)
      {'surah': s, 'ayah': a, 'category': c, 'tag': t},
  ],
};

void main() {
  group('VerseLibrary.fromJson', () {
    test('an approved library keeps its real verses', () {
      final lib = VerseLibrary.fromJson(
        _json(
          entries: [
            (1, 1, 'hope', 'comfort'),
            (1, 2, 'hope', 'gentle_reminder'),
            (1, 3, 'greed', 'warning'),
          ],
        ),
      );
      expect(lib.placeholder, isFalse);
      expect(lib.versesFor(Emotion.hope, comfort: true), hasLength(1));
      expect(lib.versesFor(Emotion.hope, comfort: false), hasLength(1));
      expect(lib.versesFor(Emotion.greed, comfort: false), hasLength(1));
      expect(lib.versesFor(Emotion.anger, comfort: true), isEmpty);
    });

    test('a placeholder yields no verses at all', () {
      final lib = VerseLibrary.fromJson(
        _json(placeholder: true, entries: [(0, 1, 'hope', 'comfort')]),
      );
      expect(lib.placeholder, isTrue);
      expect(lib.entries, isEmpty);
    });

    test('rejects fake refs in an approved library and unknown labels', () {
      expect(
        () =>
            VerseLibrary.fromJson(_json(entries: [(0, 1, 'hope', 'comfort')])),
        throwsFormatException,
      );
      expect(
        () =>
            VerseLibrary.fromJson(_json(entries: [(1, 8, 'hope', 'comfort')])),
        throwsFormatException,
      );
      expect(
        () =>
            VerseLibrary.fromJson(_json(entries: [(1, 1, 'bored', 'comfort')])),
        throwsFormatException,
      );
      expect(() => VerseLibrary.fromJson('nope'), throwsFormatException);
    });
  });

  group('LibraryRepository', () {
    late SettingsStore store;
    setUp(() async => store = await memoryStore());

    test('saves the library with its ETag and revalidates', () async {
      final seenEtags = <String?>[];
      var status = 200;
      final repo = LibraryRepository(
        MockClient((req) async {
          seenEtags.add(req.headers['If-None-Match']);
          expect(req.url.toString(), 'http://api.test/v1/library');
          return status == 304
              ? http.Response('', 304)
              : http.Response(
                  jsonEncode(_json()),
                  200,
                  headers: {'etag': '"a"'},
                );
        }),
        store,
        baseUrl: 'http://api.test',
      );
      expect((await repo.refresh())!.entries, hasLength(1));
      status = 304;
      expect((await repo.refresh())!.entries, hasLength(1));
      expect(seenEtags, [null, '"a"']);
    });

    test('offline or a bad answer keeps the cached library', () async {
      var mode = 'ok';
      final repo = LibraryRepository(
        MockClient((req) async {
          if (mode == 'offline') throw http.ClientException('offline');
          if (mode == 'bad') return http.Response('{"version": 1}', 200);
          return http.Response(jsonEncode(_json()), 200);
        }),
        store,
        baseUrl: 'http://api.test',
      );
      expect(repo.cached(), isNull);
      await repo.refresh();
      mode = 'offline';
      expect((await repo.refresh())!.version, 'v1');
      mode = 'bad';
      expect((await repo.refresh())!.version, 'v1');
    });

    test('nothing cached and offline → null', () async {
      final repo = LibraryRepository(
        MockClient((_) async => throw http.ClientException('offline')),
        store,
      );
      expect(await repo.refresh(), isNull);
    });
  });
}
