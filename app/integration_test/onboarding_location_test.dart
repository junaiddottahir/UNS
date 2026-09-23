import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uns/main.dart';

/// Runs on an iOS simulator with the position set to Sydney:
///   xcrun simctl location SIMULATOR_ID set -33.8568,151.2153
///   flutter test integration_test -d SIMULATOR_ID
/// `flutter test` reinstalls the app, so the iOS permission prompt appears.
/// Tap "Allow While Using App", or from another shell run:
///   xcrun simctl privacy SIMULATOR_ID grant location com.uns.uns
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('real device location resolves to Sydney', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: UnsApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use my location'));

    // Real GPS + parsing the bundled city list in an isolate.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('Your prayer times').evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();
    expect(find.text('Sydney, today. Updates as you choose.'), findsOneWidget);
  });
}
