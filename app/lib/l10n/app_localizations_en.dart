// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Uns';

  @override
  String get welcomeGreeting => 'Assalamu alaykum';

  @override
  String get welcomeHeadline =>
      'Quiet the mind, remember Allah and live with presence.';

  @override
  String get welcomeBegin => 'Begin';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Next';

  @override
  String get intro1Title => 'Pray on time, anywhere';

  @override
  String get intro1Body => 'Accurate times, adhan and qibla.';

  @override
  String get intro2Title => 'Verses for how you feel';

  @override
  String get intro2Body => 'Chosen and reviewed by a scholar.';

  @override
  String get intro3Title => 'Private and always yours';

  @override
  String get intro3Body => 'Stays on your phone. No ads, ever.';

  @override
  String stepOf(int step, int total) {
    return '$step of $total';
  }

  @override
  String get back => 'Back';

  @override
  String get continueLabel => 'Continue';

  @override
  String get locationTitle => 'Where are you?';

  @override
  String get locationBody =>
      'To calculate prayer times and qibla on your phone.';

  @override
  String get locationUseMine => 'Use my location';

  @override
  String get locationFinding => 'Finding you…';

  @override
  String get locationChooseCity => 'Choose a city';

  @override
  String get locationDenied =>
      'Location access is off. You can choose your city instead.';

  @override
  String get locationDeniedForever =>
      'Location access is turned off for Uns. Turn it on in Settings, or choose your city.';

  @override
  String get locationServiceOff =>
      'Location services are off on this phone. Turn them on, or choose your city.';

  @override
  String get locationFailed =>
      'We couldn\'t find your location. Try again, or choose your city.';

  @override
  String get locationOpenSettings => 'Open Settings';

  @override
  String get citySearchTitle => 'Choose a city';

  @override
  String get citySearchHint => 'Search for your city';

  @override
  String citySearchEmpty(String query) {
    return 'No cities match \"$query\".';
  }

  @override
  String get prayerStepTitle => 'Your prayer times';

  @override
  String prayerStepBody(String place) {
    return '$place, today. Updates as you choose.';
  }

  @override
  String get notificationsStepTitle => 'Never miss a prayer';

  @override
  String get notificationsStepBody =>
      'Choose which prayers alert you, and how.';

  @override
  String get reciterStepTitle => 'How you\'ll hear the Quran';

  @override
  String get reciterStepBody => 'Tap a reciter to hear a sample.';

  @override
  String get finish => 'Finish';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get asrLabel => 'Asr';

  @override
  String get asrStandard => 'Standard';

  @override
  String get asrHanafi => 'Hanafi';

  @override
  String get highLatitudeLabel => 'High latitude';

  @override
  String get highLatitudeMiddle => 'Middle of night';

  @override
  String get highLatitudeSeventh => '1/7th';

  @override
  String get highLatitudeAngle => 'Angle';

  @override
  String get methodLabel => 'Method';

  @override
  String get methodTitle => 'Calculation method';

  @override
  String get methodMwl => 'Muslim World League';

  @override
  String get methodUmmAlQura => 'Umm al-Qura, Makkah';

  @override
  String get methodIsna => 'ISNA (North America)';

  @override
  String get methodEgyptian => 'Egyptian General Authority';

  @override
  String get methodKarachi => 'University of Islamic Sciences, Karachi';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodMoonsighting => 'Moonsighting Committee';

  @override
  String get methodSingapore => 'Singapore';

  @override
  String get methodTurkey => 'Diyanet, Türkiye';

  @override
  String get methodTehran => 'University of Tehran';

  @override
  String methodSuggested(String country) {
    return 'Suggested for $country';
  }

  @override
  String methodSummary(String method, String asr) {
    return '$method · $asr Asr';
  }

  @override
  String get prayerSettingsTitle => 'Prayer settings';

  @override
  String get locationLabel => 'Location';

  @override
  String get currentLocation => 'Current location';

  @override
  String get nextPrayer => 'Next prayer';

  @override
  String nextPrayerAt(String time, String duration) {
    return '$time · in $duration';
  }

  @override
  String nextPrayerTag(String duration) {
    return 'Next · $duration';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String dateAndPlace(String date, String place) {
    return '$date · $place';
  }

  @override
  String prayerTimesUnavailable(String place) {
    return 'Prayer times can\'t be calculated for $place today, because the sun doesn\'t rise or set there. Choose a city further from the pole.';
  }

  @override
  String methodLine(String method) {
    return 'Method · $method';
  }

  @override
  String get alertMeFor => 'Alert me for';

  @override
  String get soundLabel => 'Sound';

  @override
  String get soundAdhan => 'Adhan';

  @override
  String get soundAlert => 'Alert';

  @override
  String get soundSilent => 'Silent';

  @override
  String get soundOff => 'Off';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get reciterLabel => 'Reciter';

  @override
  String get reciterAlafasy => 'Mishary Alafasy';

  @override
  String get reciterAbdulBasit => 'Abdul Basit';

  @override
  String get reciterSudais => 'Al-Sudais';

  @override
  String get qibla => 'Qibla';

  @override
  String get tasbih => 'Tasbih';

  @override
  String get moodPrompt => 'How are you feeling today?';

  @override
  String get moodVoice => 'Tell us how you feel';

  @override
  String get tabHome => 'Home';

  @override
  String get tabShama => 'Shama';

  @override
  String get tabTasbih => 'Tasbih';

  @override
  String get tabProfile => 'Profile';

  @override
  String get comingSoon => 'Coming in a later update.';

  @override
  String alertDetail(String time, String place) {
    return '$time · $place';
  }

  @override
  String alertReminderTitle(String prayer, int minutes) {
    return '$prayer in $minutes min';
  }

  @override
  String alertCheckInTitle(String prayer) {
    return 'Did you pray $prayer?';
  }

  @override
  String get prayerAlertsTitle => 'Prayer alerts';

  @override
  String get alertsLabel => 'Alerts';

  @override
  String alertsCount(int count) {
    return '$count of 5';
  }

  @override
  String get atPrayerTime => 'At prayer time';

  @override
  String get remindMeBefore => 'Remind me before';

  @override
  String get askDidYouPray => 'Ask \"did you pray?\"';

  @override
  String get reminderNone => 'None';

  @override
  String reminderMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String alertSummaryBefore(String mode, int minutes) {
    return '$mode · $minutes min before';
  }

  @override
  String get notificationsOff =>
      'Notifications are off for Uns, so alerts won\'t appear.';

  @override
  String get turnOnNotifications => 'Turn on notifications';
}
