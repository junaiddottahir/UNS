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
  String get homeGreeting => 'Assalamu alaykum';
}
