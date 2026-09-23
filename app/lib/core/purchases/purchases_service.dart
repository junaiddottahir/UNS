import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_config.dart';

/// Configures the RevenueCat SDK. Paywall and entitlement checks are built
/// in unit 19 on top of this.
abstract final class PurchasesService {
  static bool _configured = false;

  static bool get isConfigured => _configured;

  static Future<void> configure() async {
    const key = AppConfig.revenueCatApiKey;
    if (key.isEmpty) {
      debugPrint('RevenueCat: no API key set, purchases disabled.');
      return;
    }
    if (kReleaseMode && key.startsWith('test_')) {
      throw StateError('RevenueCat Test Store key used in a release build.');
    }

    if (kDebugMode) await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(key));
    _configured = true;
  }
}
