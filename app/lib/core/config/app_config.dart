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

  /// Supabase (optional accounts). The publishable key is public.
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Sign in with Apple / Google need developer accounts and provider set-up
  /// in Supabase first (see progress-tracker.md); their buttons stay hidden
  /// until these are turned on.
  static const appleSignInEnabled = bool.fromEnvironment('APPLE_SIGN_IN');
  static const googleSignInEnabled = bool.fromEnvironment('GOOGLE_SIGN_IN');

  /// Quran text (fawazahmed0 Quran API) and the editions shown. Pending the
  /// scholar's confirmation of the editions (see progress-tracker.md).
  static const quranTextBaseUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';
  static const arabicEdition = 'ara-quranuthmanihaf'; // Uthmani, Hafs
  static const translationEdition = 'eng-ummmuhammad'; // Saheeh International

  /// Per-ayah recitation links (UmmahAPI → EveryAyah MP3s).
  static const recitationBaseUrl = 'https://ummahapi.com/api/quran';

  /// The whole dua collection (UmmahAPI), fetched in one request so the
  /// choice of duas, which follows the user's mood, happens on the phone.
  static const duasUrl = 'https://ummahapi.com/api/duas';

  /// Verse played as a reciter sample in onboarding. Pending the scholar's
  /// confirmation.
  static const reciterSampleSurah = 1;
  static const reciterSampleAyah = 1;
}
