import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/features/reciter/reciter.dart';

import '../../support/test_app.dart';

void main() {
  testWidgets('tapping a reciter selects it and plays its sample', (
    tester,
  ) async {
    final player = FakeSamplePlayer();
    final container = await pumpApp(tester, player: player);
    container.read(appRouterProvider).go(Routes.reciterStep);
    await tester.pumpAndSettle();

    await tester.tap(find.text('AL-SUDAIS'));
    await tester.pumpAndSettle();
    expect(container.read(reciterProvider), Reciter.sudais);
    // Al-Sudais is UmmahAPI reciter 2; the sample is 1:1.
    expect(player.played, ['/audio/2/001001.mp3']);

    // Tapping again stops it.
    await tester.tap(find.text('AL-SUDAIS'));
    await tester.pumpAndSettle();
    expect(player.stops, greaterThan(0));

    // Another reciter plays its own sample.
    await tester.tap(find.text('ABDUL BASIT'));
    await tester.pumpAndSettle();
    expect(player.played.last, '/audio/3/001001.mp3');
    player.finish();
  });

  testWidgets('offline, the sample says so and selection still works', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      recitations: FakeRecitations(offline: true),
    );
    container.read(appRouterProvider).go(Routes.reciterStep);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ABDUL BASIT'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Couldn't play the sample"), findsOneWidget);
    expect(container.read(reciterProvider), Reciter.abdulBasit);
  });
}
