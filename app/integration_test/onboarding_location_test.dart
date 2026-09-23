import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/alerts/alert_providers.dart';
import 'package:uns/features/alerts/notification_permission.dart';
import 'package:uns/main.dart';

/// Runs on an iOS simulator with the position set to Sydney:
///   xcrun simctl location SIMULATOR_ID set -33.8568,151.2153
///   flutter test integration_test -d SIMULATOR_ID
/// `flutter test` reinstalls the app, so the iOS permission prompt appears.
/// Tap "Allow While Using App", or from another shell run:
///   xcrun simctl privacy SIMULATOR_ID grant location com.uns.uns
/// The real permission prompt would wait for a tap; notifications have
/// their own test in unit 4.
final _noPrompt = notificationPermissionProvider.overrideWithValue(
  _AllowNotifications(),
);

class _AllowNotifications implements NotificationPermission {
  @override
  Future<bool> request() async => true;

  @override
  Future<bool> isGranted() async => true;

  @override
  Future<void> openSettings() async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Reduced motion: the pulsing mood button would keep frames coming, so
  // pumpAndSettle would never finish.
  setUp(() {
    final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
    dispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(dispatcher.clearAccessibilityFeaturesTestValue);
  });

  testWidgets('real device location → Sydney times → home', (tester) async {
    final db = await AppDatabase.open();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _noPrompt,
          settingsStoreProvider.overrideWithValue(await SettingsStore.load(db)),
        ],
        child: const UnsApp(),
      ),
    );
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
    expect(find.text('METHOD · MUSLIM WORLD LEAGUE'), findsOneWidget);

    for (final label in ['Continue', 'Allow notifications', 'Finish']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.textContaining('SYDNEY'), findsOneWidget);
  });
}
