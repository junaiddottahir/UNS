import 'dart:async';
import 'dart:math' as math;

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/features/qibla/compass_source.dart';
import 'package:uns/features/qibla/qibla.dart';

/// Independent great-circle initial bearing, to check the library against.
double _greatCircle(double lat1, double lon1, double lat2, double lon2) {
  double rad(double d) => d * math.pi / 180;
  final dLon = rad(lon2 - lon1);
  final y = math.sin(dLon) * math.cos(rad(lat2));
  final x =
      math.cos(rad(lat1)) * math.sin(rad(lat2)) -
      math.sin(rad(lat1)) * math.cos(rad(lat2)) * math.cos(dLon);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

void main() {
  group('qiblaBearing matches the great-circle bearing to the Kaaba', () {
    const kaaba = (21.4225241, 39.8261818);
    final places = {
      'Sydney': (-33.8678, 151.2073),
      'London': (51.5074, -0.1278),
      'New York': (40.7128, -74.006),
      'Jakarta': (-6.2088, 106.8456),
      'Cape Town': (-33.9249, 18.4241),
      'Reykjavik': (64.1466, -21.9426),
    };
    for (final MapEntry(key: name, value: (lat, lng)) in places.entries) {
      test(name, () {
        expect(
          qiblaBearing(lat, lng),
          closeTo(_greatCircle(lat, lng, kaaba.$1, kaaba.$2), 0.01),
        );
      });
    }

    test('published values (Sydney ≈ 277.5°, London ≈ 119°)', () {
      expect(qiblaBearing(-33.8678, 151.2073), closeTo(277.5, 0.5));
      expect(qiblaBearing(51.5074, -0.1278), closeTo(119.0, 0.5));
    });
  });

  test('turnBy takes the short way round', () {
    expect(turnBy(10, 350), 20);
    expect(turnBy(350, 10), -20);
    expect(turnBy(277, 277), 0);
    expect(turnBy(180, 0), 180);
  });

  test('guidance', () {
    expect(guidanceFor(4), QiblaGuidance.facing);
    expect(guidanceFor(-5), QiblaGuidance.facing);
    expect(guidanceFor(20), QiblaGuidance.slightlyRight);
    expect(guidanceFor(-20), QiblaGuidance.slightlyLeft);
    expect(guidanceFor(90), QiblaGuidance.right);
    expect(guidanceFor(-170), QiblaGuidance.left);
  });

  test('compass points and accuracy', () {
    expect(compassPointFor(277.5), CompassPoint.w);
    expect(compassPointFor(119), CompassPoint.se);
    expect(compassPointFor(359), CompassPoint.n);
    expect(accuracyFor(10), HeadingAccuracy.high);
    expect(accuracyFor(30), HeadingAccuracy.medium);
    expect(accuracyFor(45), HeadingAccuracy.low);
    expect(accuracyFor(null), HeadingAccuracy.unknown);
  });

  group('untilFirst', () {
    test('no first reading → unavailable', () {
      fakeAsync((async) {
        final got = <CompassState>[];
        untilFirst(
          StreamController<CompassState>().stream,
          const Duration(seconds: 3),
        ).listen(got.add);
        async.elapse(const Duration(seconds: 4));
        expect(got.single, isA<CompassUnavailable>());
      });
    });

    test('quiet spells after the first reading are fine', () {
      fakeAsync((async) {
        final source = StreamController<CompassState>();
        final got = <CompassState>[];
        untilFirst(source.stream, const Duration(seconds: 3)).listen(got.add);
        source.add(const CompassReading(90, HeadingAccuracy.high));
        async.elapse(const Duration(minutes: 1));
        expect(got.single, isA<CompassReading>());
      });
    });
  });
}
