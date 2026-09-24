import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uns/core/duas/dua.dart';
import 'package:uns/core/duas/dua_repository.dart';
import 'package:uns/core/storage/app_database.dart';

String _body(List<Map<String, Object?>> duas) => jsonEncode({
  'success': true,
  'data': {'total': duas.length, 'categories': [], 'duas': duas},
});

Map<String, Object?> _dua(int id) => {
  'id': id,
  'category': 'distress',
  'title': 'Dua $id',
  'arabic': 'عربي',
  'transliteration': 'translit',
  'translation': 'Meaning $id',
  'source': 'Sahih Muslim',
  'repeat': 3,
};

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('parses entries and skips malformed ones', () {
    final duas = parseDuas(
      jsonDecode(
        _body([
          _dua(1),
          {'id': 2, 'title': 'no text'},
        ]),
      ),
    );
    expect(duas, hasLength(1));
    expect(duas.single.repeat, 3);
    expect(() => parseDuas({'data': {}}), throwsFormatException);
  });

  test(
    'downloads once, then serves the copy until it is 30 days old',
    () async {
      var calls = 0;
      var now = DateTime(2026, 9, 1);
      final client = MockClient((request) async {
        calls++;
        expect(request.url.toString(), 'https://ummahapi.com/api/duas');
        return http.Response.bytes(utf8.encode(_body([_dua(calls)])), 200);
      });
      final repo = DuaRepository(db, client, now: () => now);

      expect((await repo.all()).single.id, 1);
      now = now.add(const Duration(days: 29));
      expect((await repo.all()).single.id, 1);
      expect(calls, 1);

      now = now.add(const Duration(days: 2));
      expect((await repo.all()).single.id, 2);
      expect(calls, 2);
    },
  );

  test('offline: the old copy is used; with none, it throws', () async {
    var online = true;
    var now = DateTime(2026, 9, 1);
    final client = MockClient((_) async {
      if (!online) throw http.ClientException('offline');
      return http.Response.bytes(utf8.encode(_body([_dua(7)])), 200);
    });
    final repo = DuaRepository(db, client, now: () => now);
    await repo.all();

    online = false;
    now = now.add(const Duration(days: 60));
    expect((await repo.all()).single.id, 7);

    final empty = AppDatabase(NativeDatabase.memory());
    addTearDown(empty.close);
    expect(
      () => DuaRepository(empty, client).all(),
      throwsA(isA<http.ClientException>()),
    );
  });
}
