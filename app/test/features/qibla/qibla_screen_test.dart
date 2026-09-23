import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/qibla/compass_source.dart';
import 'package:uns/features/qibla/qibla.dart';

import '../../support/test_app.dart';

Future<FakeCompass> _openQibla(WidgetTester tester) async {
  final compass = FakeCompass();
  final container = await pumpApp(tester, compass: compass);
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  container.read(appRouterProvider).go(Routes.home);
  await tester.pumpAndSettle();
  await tester.tap(find.text('QIBLA'));
  await tester.pumpAndSettle();
  return compass;
}

Future<void> _emit(WidgetTester tester, FakeCompass c, CompassState s) async {
  c.states.add(s);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the bearing and guides the user round', (tester) async {
    final compass = await _openQibla(tester);
    expect(find.text('SYDNEY'), findsOneWidget);
    expect(find.textContaining('278°'), findsOneWidget);
    expect(find.textContaining(' W'), findsOneWidget);

    await _emit(
      tester,
      compass,
      const CompassReading(260, HeadingAccuracy.high),
    );
    expect(find.text('Turn slightly right'), findsOneWidget);
    await _emit(
      tester,
      compass,
      const CompassReading(279, HeadingAccuracy.high),
    );
    expect(find.text("You're facing the qibla"), findsOneWidget);
    await _emit(
      tester,
      compass,
      const CompassReading(20, HeadingAccuracy.high),
    );
    expect(find.text('Turn left'), findsOneWidget);

    // Facing the qibla puts the dial's Kaaba at the top.
    await _emit(
      tester,
      compass,
      const CompassReading(277.5, HeadingAccuracy.high),
    );
    final kaaba = tester.getCenter(find.bySemanticsLabel('Kaaba'));
    final dial = tester.getCenter(find.byType(AnimatedRotation));
    expect(kaaba.dx, closeTo(dial.dx, 2));
    expect(kaaba.dy, lessThan(dial.dy));
  });

  testWidgets('low accuracy suggests calibrating; calibrate shows it', (
    tester,
  ) async {
    final compass = await _openQibla(tester);
    await _emit(
      tester,
      compass,
      const CompassReading(100, HeadingAccuracy.low),
    );
    expect(find.textContaining('accuracy is low'), findsOneWidget);

    await tester.tap(find.text('CALIBRATE'));
    await tester.pumpAndSettle();
    expect(find.text('Move your phone in a figure-8'), findsOneWidget);
    expect(find.text('ACCURACY · LOW'), findsOneWidget);
    await _emit(
      tester,
      compass,
      const CompassReading(100, HeadingAccuracy.high),
    );
    expect(find.text('ACCURACY · HIGH'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('QIBLA DIRECTION'), findsOneWidget);
  });

  testWidgets('no compass: the bearing still helps', (tester) async {
    final compass = await _openQibla(tester);
    await _emit(tester, compass, const CompassUnavailable());
    expect(find.textContaining('Face 278° from north'), findsOneWidget);
    expect(find.text('CALIBRATE'), findsNothing);
  });

  testWidgets('iOS without location asks for it', (tester) async {
    final compass = await _openQibla(tester);
    await _emit(
      tester,
      compass,
      const CompassNeedsLocation(permanently: false),
    );
    expect(find.textContaining('find true north'), findsOneWidget);
    await tester.tap(find.text('Allow location'));
    await tester.pumpAndSettle();
    expect(compass.locationRequests, 1);
  });
}
