import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'city.dart';

/// Searches the bundled city list. Everything runs on the phone, so the
/// user's position is never sent to a geocoding service.
class CityRepository {
  CityRepository(this._cities);

  final List<City> _cities;

  static const assetPath = 'assets/data/cities.json';

  static Future<CityRepository> load(AssetBundle bundle) async {
    final raw = await bundle.loadString(assetPath);
    return CityRepository(await compute(parseCities, raw));
  }

  int get length => _cities.length;

  /// Cities whose name starts with [query] come first, then those that
  /// contain it; ties go to the larger city.
  List<City> search(String query, {int limit = 30}) {
    final q = normalizeName(query);
    if (q.length < 2) return const [];

    final prefix = <City>[];
    final contains = <City>[];
    for (final city in _cities) {
      if (city.searchKeys.any((k) => k.startsWith(q))) {
        prefix.add(city);
      } else if (city.searchKeys.any((k) => k.contains(q))) {
        contains.add(city);
      }
      if (prefix.length >= limit) break;
    }
    // The list is sorted by population, so each bucket already is too.
    return [...prefix, ...contains].take(limit).toList();
  }

  /// Extra distance a larger city may be from the user and still be preferred
  /// as the label, so central London reads "London", not a borough.
  static const preferLargerWithinKm = 10.0;

  /// The city to label a position with: the most populous city within
  /// [preferLargerWithinKm] of the nearest one.
  City nearest(double latitude, double longitude) {
    if (_cities.isEmpty) throw StateError('City list is empty.');
    final distances = [
      for (final c in _cities)
        _distanceKm(latitude, longitude, c.latitude, c.longitude),
    ];
    var closest = double.infinity;
    for (final d in distances) {
      if (d < closest) closest = d;
    }
    // The list is sorted by population, so the first match is the largest.
    for (var i = 0; i < _cities.length; i++) {
      if (distances[i] <= closest + preferLargerWithinKm) return _cities[i];
    }
    throw StateError('unreachable');
  }

  static double _distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    return earthRadiusKm * _haversine(lat1, lon1, lat2, lon2);
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const toRad = math.pi / 180;
    final dLat = (lat2 - lat1) * toRad;
    final dLon = (lon2 - lon1) * toRad;
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1 * toRad) *
            math.cos(lat2 * toRad) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * math.asin(math.sqrt(a));
  }
}

/// Parses `cities.json`. Top level so it can run in an isolate.
List<City> parseCities(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final fields = (json['fields'] as List).cast<String>();
  final countries = (json['countries'] as Map).cast<String, String>();
  int idx(String f) {
    final i = fields.indexOf(f);
    if (i < 0) throw FormatException('cities.json missing field "$f"');
    return i;
  }

  final iName = idx('name'), iAscii = idx('ascii'), iRegion = idx('region');
  final iCc = idx('cc'), iLat = idx('lat'), iLng = idx('lng');
  final iTz = idx('tz'), iPop = idx('pop'), iAlt = idx('alt');

  return [
    for (final row in (json['cities'] as List).cast<List<dynamic>>())
      City(
        name: row[iName] as String,
        region: row[iRegion] as String,
        countryCode: row[iCc] as String,
        countryName: countries[row[iCc]] ?? row[iCc] as String,
        latitude: (row[iLat] as num).toDouble(),
        longitude: (row[iLng] as num).toDouble(),
        timeZone: row[iTz] as String,
        population: row[iPop] as int,
        searchKeys: {
          normalizeName(row[iName] as String),
          if ((row[iAscii] as String).isNotEmpty)
            normalizeName(row[iAscii] as String),
          for (final alt in (row[iAlt] as String).split('|'))
            if (alt.isNotEmpty) normalizeName(alt),
        }.toList(),
      ),
  ];
}

final _arabicMarks = RegExp('[ً-ٰٟـ]');
final _latinAccents = <String, String>{
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ā': 'a',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ī': 'i',
  'ñ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ō': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ū': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ş': 's',
  'ș': 's',
  'ğ': 'g',
  'ı': 'i',
  'ţ': 't',
  'ț': 't',
};

/// Lowercases, strips Latin accents and Arabic diacritics, and folds Arabic
/// letter variants so "Mecca", "mécca" and "مكّة" match.
String normalizeName(String input) {
  final lower = input.trim().toLowerCase().replaceAll(_arabicMarks, '');
  final out = StringBuffer();
  for (final ch in lower.split('')) {
    out.write(switch (ch) {
      'أ' || 'إ' || 'آ' => 'ا',
      'ة' => 'ه',
      'ى' => 'ي',
      _ => _latinAccents[ch] ?? ch,
    });
  }
  return out.toString();
}
