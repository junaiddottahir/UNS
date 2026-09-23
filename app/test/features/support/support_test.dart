import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/support/support_screen.dart';

import '../../support/test_app.dart';

class _FakeDialer implements Dialer {
  _FakeDialer({this.works = true});
  final bool works;
  final calls = <String>[];

  @override
  Future<bool> call(String number) async {
    calls.add(number);
    return works;
  }
}

void main() {
  Future<void> toAfterScreen(WidgetTester tester, _FakeDialer dialer) async {
    final container = await pumpApp(tester, dialer: dialer);
    container
        .read(userLocationProvider.notifier)
        .set(UserLocation.fromCity(sydney));
    container.read(appRouterProvider).go(Routes.shama);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ANXIOUS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comfort me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('End session'));
    await tester.pumpAndSettle();
  }

  testWidgets('"Heavier" offers support; the helpline comes from config', (
    tester,
  ) async {
    final dialer = _FakeDialer();
    await toAfterScreen(tester, dialer);
    await tester.tap(find.text('HEAVIER'));
    await tester.pumpAndSettle();
    expect(find.text("You don't have to carry this alone"), findsOneWidget);

    await tester.tap(find.text('Emergency · 000'));
    await tester.pumpAndSettle();
    expect(dialer.calls, ['000']);

    await tester.tap(find.text("I'm safe, go back"));
    await tester.pumpAndSettle();
    expect(find.text('How do you feel now?'), findsOneWidget);
  });

  testWidgets('if the call can\'t start, it says to dial', (tester) async {
    final container = await pumpApp(tester, dialer: _FakeDialer(works: false));
    container.read(appRouterProvider).go(Routes.support);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Emergency · 000'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Please dial 000'), findsOneWidget);
  });
}
