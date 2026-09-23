import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';

import '../../support/test_app.dart';

void main() {
  testWidgets('Profile → Our sources credits every source', (tester) async {
    final container = await pumpApp(tester);
    container
        .read(userLocationProvider.notifier)
        .set(UserLocation.fromCity(sydney));
    container.read(appRouterProvider).go(Routes.profile);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Our sources'));
    await tester.pumpAndSettle();
    expect(find.textContaining('unchanged'), findsOneWidget);
    for (final value in [
      'Uthmani · Hafs',
      'Sahih International',
      'UmmahAPI',
      'Mishary Alafasy',
      'fawazahmed0 Quran API',
      'GeoNames · CC BY 4.0',
    ]) {
      expect(find.text(value), findsOneWidget, reason: value);
    }
    expect(find.textContaining('approved by a qualified scholar'), findsOne);
  });

  testWidgets('Profile → Prayer reaches prayer settings', (tester) async {
    final container = await pumpApp(tester);
    container
        .read(userLocationProvider.notifier)
        .set(UserLocation.fromCity(sydney));
    container.read(appRouterProvider).go(Routes.profile);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prayer'));
    await tester.pumpAndSettle();
    expect(find.text('HIGH LATITUDE'), findsOneWidget);
  });
}
