import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uns/features/library/verse_library.dart';
import 'package:uns/features/shama/classify_client.dart';

void main() {
  test('sends only the text, nothing identifying', () async {
    late http.Request sent;
    final client = ClassifyClient(
      MockClient((req) async {
        sent = req;
        return http.Response('{"category": "anxiety", "risk": false}', 200);
      }),
      baseUrl: 'http://api.test',
    );
    final reading = await client.classify('exams are stressing me');
    expect(reading.emotion, Emotion.anxiety);
    expect(reading.risk, isFalse);
    expect(sent.url.toString(), 'http://api.test/v1/classify');
    expect(jsonDecode(sent.body), {'text': 'exams are stressing me'});
    expect(
      sent.headers.keys.map((k) => k.toLowerCase()),
      isNot(contains('authorization')),
    );
  });

  test('unknown or unexpected categories read as no emotion', () async {
    for (final category in ['unknown', 'boredom', null]) {
      final client = ClassifyClient(
        MockClient(
          (_) async => http.Response(
            jsonEncode({'category': category, 'risk': true}),
            200,
          ),
        ),
      );
      final reading = await client.classify('x');
      expect(reading.emotion, isNull);
      expect(reading.risk, isTrue);
    }
  });

  test('errors, bad answers and offline are "unavailable"', () async {
    for (final response in [
      http.Response('{"error": {}}', 503),
      http.Response('{"error": {}}', 429),
      http.Response('nope', 200),
      http.Response('{"category": "anxiety"}', 200),
    ]) {
      await expectLater(
        ClassifyClient(MockClient((_) async => response)).classify('x'),
        throwsA(isA<ClassifyUnavailable>()),
      );
    }
    await expectLater(
      ClassifyClient(
        MockClient((_) async => throw http.ClientException('offline')),
      ).classify('x'),
      throwsA(isA<ClassifyUnavailable>()),
    );
  });
}
