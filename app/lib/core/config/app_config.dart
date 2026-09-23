/// Build-time configuration, passed with
/// `flutter run --dart-define-from-file=config/dev.json`.
abstract final class AppConfig {
  /// RevenueCat public SDK key. `test_` keys use RevenueCat's Test Store and
  /// must never ship in a release build.
  static const revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');

  /// Entitlement that unlocks premium, as named in the RevenueCat dashboard.
  static const premiumEntitlement = 'premium';

  /// Shown on the support resources screen. Per-country numbers come later.
  static const helplineNumber = '000';
}
