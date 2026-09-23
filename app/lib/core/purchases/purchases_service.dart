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

  /// Links purchases to the signed-in account (its Supabase ID), or back to
  /// an anonymous ID when signed out.
  static Future<void> identify(String? userId) async {
    if (!_configured) return;
    try {
      if (userId != null) {
        await Purchases.logIn(userId);
      } else if (!await Purchases.isAnonymous) {
        await Purchases.logOut();
      }
    } on Exception catch (e) {
      debugPrint('RevenueCat identify failed: $e');
    }
  }
}
