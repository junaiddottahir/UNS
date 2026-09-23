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

  /// Uns backend (verse library, later classification and sync).
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Quran text (fawazahmed0 Quran API) and the editions shown. Pending the
  /// scholar's confirmation of the editions (see progress-tracker.md).
  static const quranTextBaseUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';
  static const arabicEdition = 'ara-quranuthmanihaf'; // Uthmani, Hafs
  static const translationEdition = 'eng-ummmuhammad'; // Saheeh International

  /// Per-ayah recitation links (UmmahAPI → EveryAyah MP3s).
  static const recitationBaseUrl = 'https://ummahapi.com/api/quran';

  /// Verse played as a reciter sample in onboarding. Pending the scholar's
  /// confirmation.
  static const reciterSampleSurah = 1;
  static const reciterSampleAyah = 1;
}
