import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uns/features/location/city_repository.dart';

void main() {
  late CityRepository repo;

  setUpAll(() {
    final raw = File(CityRepository.assetPath).readAsStringSync();
    repo = CityRepository(parseCities(raw));
  });

  test('bundled list parses', () {
    expect(repo.length, greaterThan(30000));
  });

  group('search', () {
    test('ranks the larger city first for a shared name', () {
      final results = repo.search('Sydney');
      expect(results.first.countryCode, 'AU');
      expect(results.first.timeZone, 'Australia/Sydney');
    });

    test('finds cities by English alternate name', () {
      final results = repo.search('mecca');
      expect(results.map((c) => c.name), contains('Makkah'));
    });

    test('finds cities by Arabic name, ignoring diacritics', () {
      expect(repo.search('مكّة').first.name, 'Makkah');
    });

    test('ignores Latin accents', () {
      expect(repo.search('sao paulo').first.name, 'São Paulo');
    });

    test('needs at least two characters', () {
      expect(repo.search('s'), isEmpty);
    });
  });

  group('nearest', () {
    test('maps Sydney Opera House to Sydney', () {
      expect(repo.nearest(-33.8568, 151.2153).name, 'Sydney');
    });

    test('labels central London as London, not a borough', () {
      expect(repo.nearest(51.5007, -0.1246).name, 'London');
    });

    test('labels Melbourne CBD as Melbourne', () {
      expect(repo.nearest(-37.8136, 144.9631).name, 'Melbourne');
    });

    test('maps the Kaaba to Makkah', () {
      expect(repo.nearest(21.4225, 39.8262).name, 'Makkah');
    });
  });

  test('normalizeName folds Arabic letter variants', () {
    expect(normalizeName('إسلام آباد'), normalizeName('اسلام اباد'));
    expect(normalizeName('مدينة'), 'مدينه');
  });
}
