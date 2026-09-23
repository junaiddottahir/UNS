import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/alerts/alert_providers.dart';
import 'package:uns/features/alerts/notification_permission.dart';
import 'package:uns/main.dart';

/// Real Keychain and encrypted SQLite on the device:
///   flutter test integration_test/persistence_test.dart -d SIMULATOR_ID
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

  testWidgets('choices survive a restart; the file is encrypted', (
    tester,
  ) async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, AppDatabase.fileName));
    if (file.existsSync()) file.deleteSync();

    // First launch: onboard with a manual city.
    var db = await AppDatabase.open();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _noPrompt,
          appDatabaseProvider.overrideWithValue(db),
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
    await tester.tap(find.text('Choose a city'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'makkah');
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('Mecca Region, Saudi Arabia').evaluate().isNotEmpty) break;
    }
    await tester.tap(find.text('Mecca Region, Saudi Arabia').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('HANAFI'));
    await tester.pumpAndSettle();
    for (final label in ['Continue', 'Allow notifications', 'Finish']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(find.text('NEXT PRAYER'), findsOneWidget);

    // "Restart": drop the app, close and reopen the database.
    await tester.pumpWidget(const SizedBox());
    await db.close();

    final bytes = file.readAsBytesSync();
    expect(latin1.decode(bytes.sublist(0, 15)), isNot('SQLite format 3'));
    expect(latin1.decode(bytes).contains('Makkah'), isFalse);

    db = await AppDatabase.open();
    final store = await SettingsStore.load(db);
    expect(store.readJson(SettingKeys.prayer)!['asr'], 'hanafi');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _noPrompt,
          appDatabaseProvider.overrideWithValue(db),
          settingsStoreProvider.overrideWithValue(store),
        ],
        child: const UnsApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.textContaining('MAKKAH'), findsOneWidget);
    await db.close();
  });
}
