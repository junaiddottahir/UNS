abstract final class Routes {
  static const welcome = '/';
  static const intro = '/intro';
  static const location = '/onboarding/location';
  static const citySearch = '/onboarding/city';
  static const prayerStep = '/onboarding/prayer';
  static const notificationsStep = '/onboarding/notifications';
  static const reciterStep = '/onboarding/reciter';
  static const home = '/home';
  static const shama = '/shama';
  static const tasbih = '/tasbih';
  static const profile = '/profile';
  static const qibla = '/qibla';
  static const tasbihCounter = '/tasbih/count';
  static const tasbihHistory = '/tasbih/history';
  static const plans = '/plans';
  static const sources = '/sources';
  static const shamaHelp = '/shama/help';
  static const shamaVoice = '/shama/voice';
  static const shamaLength = '/shama/length';
  static const shamaPlay = '/shama/play';
  static const shamaAfter = '/shama/after';
  static const support = '/support';
  static const shamaWrite = '/shama/write';
  static const shamaRecord = '/shama/record';
  static const journal = '/journal';

  /// One journal entry, e.g. `/journal/12`.
  static String journalEntry(int id) => '$journal/$id';
  static const qiblaCalibrate = '/qibla/calibrate';
  static const prayerTimes = '/prayer/times';
  static const prayerSettings = '/prayer/settings';
  static const prayerMethod = '/prayer/method';
  static const prayerLocation = '/prayer/location';
  static const prayerAlerts = '/prayer/alerts';

  /// One prayer's alert choices, e.g. `/prayer/alerts/fajr`.
  static String prayerAlert(String prayer) => '$prayerAlerts/$prayer';
}
