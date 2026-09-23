import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Uns'**
  String get appTitle;

  /// No description provided for @welcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Assalamu alaykum'**
  String get welcomeGreeting;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Quiet the mind, remember Allah and live with presence.'**
  String get welcomeHeadline;

  /// No description provided for @welcomeBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get welcomeBegin;

  /// No description provided for @introSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get introNext;

  /// No description provided for @intro1Title.
  ///
  /// In en, this message translates to:
  /// **'Pray on time, anywhere'**
  String get intro1Title;

  /// No description provided for @intro1Body.
  ///
  /// In en, this message translates to:
  /// **'Accurate times, adhan and qibla.'**
  String get intro1Body;

  /// No description provided for @intro2Title.
  ///
  /// In en, this message translates to:
  /// **'Verses for how you feel'**
  String get intro2Title;

  /// No description provided for @intro2Body.
  ///
  /// In en, this message translates to:
  /// **'Chosen and reviewed by a scholar.'**
  String get intro2Body;

  /// No description provided for @intro3Title.
  ///
  /// In en, this message translates to:
  /// **'Private and always yours'**
  String get intro3Title;

  /// No description provided for @intro3Body.
  ///
  /// In en, this message translates to:
  /// **'Stays on your phone. No ads, ever.'**
  String get intro3Body;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'{step} of {total}'**
  String stepOf(int step, int total);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get locationTitle;

  /// No description provided for @locationBody.
  ///
  /// In en, this message translates to:
  /// **'To calculate prayer times and qibla on your phone.'**
  String get locationBody;

  /// No description provided for @locationUseMine.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get locationUseMine;

  /// No description provided for @locationFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding you…'**
  String get locationFinding;

  /// No description provided for @locationChooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get locationChooseCity;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access is off. You can choose your city instead.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location access is turned off for Uns. Turn it on in Settings, or choose your city.'**
  String get locationDeniedForever;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are off on this phone. Turn them on, or choose your city.'**
  String get locationServiceOff;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find your location. Try again, or choose your city.'**
  String get locationFailed;

  /// No description provided for @locationOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get locationOpenSettings;

  /// No description provided for @citySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get citySearchTitle;

  /// No description provided for @citySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for your city'**
  String get citySearchHint;

  /// No description provided for @citySearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cities match \"{query}\".'**
  String citySearchEmpty(String query);

  /// No description provided for @prayerStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Your prayer times'**
  String get prayerStepTitle;

  /// No description provided for @prayerStepBody.
  ///
  /// In en, this message translates to:
  /// **'{place}, today. Updates as you choose.'**
  String prayerStepBody(String place);

  /// No description provided for @notificationsStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss a prayer'**
  String get notificationsStepTitle;

  /// No description provided for @notificationsStepBody.
  ///
  /// In en, this message translates to:
  /// **'Choose which prayers alert you, and how.'**
  String get notificationsStepBody;

  /// No description provided for @reciterStepTitle.
  ///
  /// In en, this message translates to:
  /// **'How you\'ll hear the Quran'**
  String get reciterStepTitle;

  /// No description provided for @reciterStepBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a reciter to hear a sample.'**
  String get reciterStepBody;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @asrLabel.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asrLabel;

  /// No description provided for @asrStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get asrStandard;

  /// No description provided for @asrHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get asrHanafi;

  /// No description provided for @highLatitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'High latitude'**
  String get highLatitudeLabel;

  /// No description provided for @highLatitudeMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle of night'**
  String get highLatitudeMiddle;

  /// No description provided for @highLatitudeSeventh.
  ///
  /// In en, this message translates to:
  /// **'1/7th'**
  String get highLatitudeSeventh;

  /// No description provided for @highLatitudeAngle.
  ///
  /// In en, this message translates to:
  /// **'Angle'**
  String get highLatitudeAngle;

  /// No description provided for @methodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get methodLabel;

  /// No description provided for @methodTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get methodTitle;

  /// No description provided for @methodMwl.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get methodMwl;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura, Makkah'**
  String get methodUmmAlQura;

  /// No description provided for @methodIsna.
  ///
  /// In en, this message translates to:
  /// **'ISNA (North America)'**
  String get methodIsna;

  /// No description provided for @methodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority'**
  String get methodEgyptian;

  /// No description provided for @methodKarachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get methodKarachi;

  /// No description provided for @methodDubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get methodDubai;

  /// No description provided for @methodQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get methodQatar;

  /// No description provided for @methodKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get methodKuwait;

  /// No description provided for @methodMoonsighting.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee'**
  String get methodMoonsighting;

  /// No description provided for @methodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get methodSingapore;

  /// No description provided for @methodTurkey.
  ///
  /// In en, this message translates to:
  /// **'Diyanet, Türkiye'**
  String get methodTurkey;

  /// No description provided for @methodTehran.
  ///
  /// In en, this message translates to:
  /// **'University of Tehran'**
  String get methodTehran;

  /// No description provided for @methodSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested for {country}'**
  String methodSuggested(String country);

  /// No description provided for @methodSummary.
  ///
  /// In en, this message translates to:
  /// **'{method} · {asr} Asr'**
  String methodSummary(String method, String asr);

  /// No description provided for @prayerSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer settings'**
  String get prayerSettingsTitle;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get nextPrayer;

  /// No description provided for @nextPrayerAt.
  ///
  /// In en, this message translates to:
  /// **'{time} · in {duration}'**
  String nextPrayerAt(String time, String duration);

  /// No description provided for @nextPrayerTag.
  ///
  /// In en, this message translates to:
  /// **'Next · {duration}'**
  String nextPrayerTag(String duration);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @dateAndPlace.
  ///
  /// In en, this message translates to:
  /// **'{date} · {place}'**
  String dateAndPlace(String date, String place);

  /// No description provided for @prayerTimesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Prayer times can\'t be calculated for {place} today, because the sun doesn\'t rise or set there. Choose a city further from the pole.'**
  String prayerTimesUnavailable(String place);

  /// No description provided for @methodLine.
  ///
  /// In en, this message translates to:
  /// **'Method · {method}'**
  String methodLine(String method);

  /// No description provided for @alertMeFor.
  ///
  /// In en, this message translates to:
  /// **'Alert me for'**
  String get alertMeFor;

  /// No description provided for @soundLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundLabel;

  /// No description provided for @soundAdhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get soundAdhan;

  /// No description provided for @soundAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get soundAlert;

  /// No description provided for @soundSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get soundSilent;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get soundOff;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// No description provided for @reciterLabel.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get reciterLabel;

  /// No description provided for @reciterAlafasy.
  ///
  /// In en, this message translates to:
  /// **'Mishary Alafasy'**
  String get reciterAlafasy;

  /// No description provided for @reciterAbdulBasit.
  ///
  /// In en, this message translates to:
  /// **'Abdul Basit'**
  String get reciterAbdulBasit;

  /// No description provided for @reciterSudais.
  ///
  /// In en, this message translates to:
  /// **'Al-Sudais'**
  String get reciterSudais;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @tasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbih;

  /// No description provided for @moodPrompt.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get moodPrompt;

  /// No description provided for @moodVoice.
  ///
  /// In en, this message translates to:
  /// **'Tell us how you feel'**
  String get moodVoice;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabShama.
  ///
  /// In en, this message translates to:
  /// **'Shama'**
  String get tabShama;

  /// No description provided for @tabTasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tabTasbih;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @alertDetail.
  ///
  /// In en, this message translates to:
  /// **'{time} · {place}'**
  String alertDetail(String time, String place);

  /// No description provided for @alertReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'{prayer} in {minutes} min'**
  String alertReminderTitle(String prayer, int minutes);

  /// No description provided for @alertCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you pray {prayer}?'**
  String alertCheckInTitle(String prayer);

  /// No description provided for @prayerAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer alerts'**
  String get prayerAlertsTitle;

  /// No description provided for @alertsLabel.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsLabel;

  /// No description provided for @alertsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of 5'**
  String alertsCount(int count);

  /// No description provided for @atPrayerTime.
  ///
  /// In en, this message translates to:
  /// **'At prayer time'**
  String get atPrayerTime;

  /// No description provided for @remindMeBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind me before'**
  String get remindMeBefore;

  /// No description provided for @askDidYouPray.
  ///
  /// In en, this message translates to:
  /// **'Ask \"did you pray?\"'**
  String get askDidYouPray;

  /// No description provided for @reminderNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get reminderNone;

  /// No description provided for @reminderMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String reminderMinutes(int minutes);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @alertSummaryBefore.
  ///
  /// In en, this message translates to:
  /// **'{mode} · {minutes} min before'**
  String alertSummaryBefore(String mode, int minutes);

  /// No description provided for @notificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Uns, so alerts won\'t appear.'**
  String get notificationsOff;

  /// No description provided for @turnOnNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get turnOnNotifications;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla direction'**
  String get qiblaDirection;

  /// No description provided for @compassN.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get compassN;

  /// No description provided for @compassNE.
  ///
  /// In en, this message translates to:
  /// **'NE'**
  String get compassNE;

  /// No description provided for @compassE.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get compassE;

  /// No description provided for @compassSE.
  ///
  /// In en, this message translates to:
  /// **'SE'**
  String get compassSE;

  /// No description provided for @compassS.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get compassS;

  /// No description provided for @compassSW.
  ///
  /// In en, this message translates to:
  /// **'SW'**
  String get compassSW;

  /// No description provided for @compassW.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get compassW;

  /// No description provided for @compassNW.
  ///
  /// In en, this message translates to:
  /// **'NW'**
  String get compassNW;

  /// No description provided for @degrees.
  ///
  /// In en, this message translates to:
  /// **'{value}°'**
  String degrees(int value);

  /// No description provided for @facingQibla.
  ///
  /// In en, this message translates to:
  /// **'You\'re facing the qibla'**
  String get facingQibla;

  /// No description provided for @turnSlightlyLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn slightly left'**
  String get turnSlightlyLeft;

  /// No description provided for @turnSlightlyRight.
  ///
  /// In en, this message translates to:
  /// **'Turn slightly right'**
  String get turnSlightlyRight;

  /// No description provided for @turnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn left'**
  String get turnLeft;

  /// No description provided for @turnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn right'**
  String get turnRight;

  /// No description provided for @calibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate'**
  String get calibrate;

  /// No description provided for @calibrateTitle.
  ///
  /// In en, this message translates to:
  /// **'Move your phone in a figure-8'**
  String get calibrateTitle;

  /// No description provided for @calibrateBody.
  ///
  /// In en, this message translates to:
  /// **'Away from metal and magnets.'**
  String get calibrateBody;

  /// No description provided for @accuracyLine.
  ///
  /// In en, this message translates to:
  /// **'Accuracy · {level}'**
  String accuracyLine(String level);

  /// No description provided for @accuracyHigh.
  ///
  /// In en, this message translates to:
  /// **'high'**
  String get accuracyHigh;

  /// No description provided for @accuracyMedium.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get accuracyMedium;

  /// No description provided for @accuracyLow.
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get accuracyLow;

  /// No description provided for @accuracyUnknown.
  ///
  /// In en, this message translates to:
  /// **'checking'**
  String get accuracyUnknown;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @compassLowAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Compass accuracy is low. Calibrate for a better reading.'**
  String get compassLowAccuracy;

  /// No description provided for @compassUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The compass isn\'t available on this phone. Face {degrees}° from north.'**
  String compassUnavailable(int degrees);

  /// No description provided for @compassNeedsLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location access so the compass can find true north.'**
  String get compassNeedsLocation;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get allowLocation;

  /// No description provided for @kaaba.
  ///
  /// In en, this message translates to:
  /// **'Kaaba'**
  String get kaaba;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @afterPrayer.
  ///
  /// In en, this message translates to:
  /// **'After prayer'**
  String get afterPrayer;

  /// No description provided for @dhikrSubhanAllah.
  ///
  /// In en, this message translates to:
  /// **'SubhanAllah'**
  String get dhikrSubhanAllah;

  /// No description provided for @dhikrAlhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get dhikrAlhamdulillah;

  /// No description provided for @dhikrAllahuAkbar.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get dhikrAllahuAkbar;

  /// No description provided for @customDhikr.
  ///
  /// In en, this message translates to:
  /// **'Custom dhikr'**
  String get customDhikr;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @streaksPremium.
  ///
  /// In en, this message translates to:
  /// **'Streaks · Premium'**
  String get streaksPremium;

  /// No description provided for @singleDhikr.
  ///
  /// In en, this message translates to:
  /// **'Single dhikr'**
  String get singleDhikr;

  /// No description provided for @ofTarget.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String ofTarget(int target);

  /// No description provided for @tapAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere'**
  String get tapAnywhere;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @dhikrComplete.
  ///
  /// In en, this message translates to:
  /// **'Dhikr complete'**
  String get dhikrComplete;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// No description provided for @startAfterPrayer.
  ///
  /// In en, this message translates to:
  /// **'Start after-prayer dhikr'**
  String get startAfterPrayer;

  /// No description provided for @tasbihCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {target}, tap to count'**
  String tasbihCount(int count, int target);

  /// No description provided for @sampleFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play the sample. Check your connection and try again.'**
  String get sampleFailed;

  /// No description provided for @ourSources.
  ///
  /// In en, this message translates to:
  /// **'Our sources'**
  String get ourSources;

  /// No description provided for @sourcesIntro.
  ///
  /// In en, this message translates to:
  /// **'Every verse comes from these sources, unchanged. We never generate or explain the Quran with AI.'**
  String get sourcesIntro;

  /// No description provided for @sourceArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get sourceArabic;

  /// No description provided for @sourceArabicValue.
  ///
  /// In en, this message translates to:
  /// **'Uthmani · Hafs'**
  String get sourceArabicValue;

  /// No description provided for @sourceTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get sourceTranslation;

  /// No description provided for @sourceTranslationValue.
  ///
  /// In en, this message translates to:
  /// **'Sahih International'**
  String get sourceTranslationValue;

  /// No description provided for @sourceRecitation.
  ///
  /// In en, this message translates to:
  /// **'Recitation'**
  String get sourceRecitation;

  /// No description provided for @sourceRecitationValue.
  ///
  /// In en, this message translates to:
  /// **'UmmahAPI'**
  String get sourceRecitationValue;

  /// No description provided for @sourceText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get sourceText;

  /// No description provided for @sourceTextValue.
  ///
  /// In en, this message translates to:
  /// **'fawazahmed0 Quran API'**
  String get sourceTextValue;

  /// No description provided for @sourceReciter.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get sourceReciter;

  /// No description provided for @verseSelection.
  ///
  /// In en, this message translates to:
  /// **'Verse selection'**
  String get verseSelection;

  /// No description provided for @verseSelectionBody.
  ///
  /// In en, this message translates to:
  /// **'Every verse is reviewed and approved by a qualified scholar.'**
  String get verseSelectionBody;

  /// No description provided for @otherData.
  ///
  /// In en, this message translates to:
  /// **'Other data'**
  String get otherData;

  /// No description provided for @sourceCities.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get sourceCities;

  /// No description provided for @sourceCitiesValue.
  ///
  /// In en, this message translates to:
  /// **'GeoNames · CC BY 4.0'**
  String get sourceCitiesValue;

  /// No description provided for @sourceCompass.
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get sourceCompass;

  /// No description provided for @sourceCompassValue.
  ///
  /// In en, this message translates to:
  /// **'NOAA · WMM-2025'**
  String get sourceCompassValue;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodLonely.
  ///
  /// In en, this message translates to:
  /// **'Lonely'**
  String get moodLonely;

  /// No description provided for @moodAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get moodAngry;

  /// No description provided for @moodGrateful.
  ///
  /// In en, this message translates to:
  /// **'Grateful'**
  String get moodGrateful;

  /// No description provided for @moodHopeful.
  ///
  /// In en, this message translates to:
  /// **'Hopeful'**
  String get moodHopeful;

  /// No description provided for @moodHumble.
  ///
  /// In en, this message translates to:
  /// **'Humble'**
  String get moodHumble;

  /// No description provided for @moodArrogant.
  ///
  /// In en, this message translates to:
  /// **'Proud'**
  String get moodArrogant;

  /// No description provided for @moodGreedy.
  ///
  /// In en, this message translates to:
  /// **'Wanting more'**
  String get moodGreedy;

  /// No description provided for @libraryNotReady.
  ///
  /// In en, this message translates to:
  /// **'Sessions open once our scholar has approved the verses.'**
  String get libraryNotReady;

  /// No description provided for @libraryOffline.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet once to download the verses.'**
  String get libraryOffline;

  /// No description provided for @feelingMood.
  ///
  /// In en, this message translates to:
  /// **'Feeling {mood}'**
  String feelingMood(String mood);

  /// No description provided for @whatWouldHelp.
  ///
  /// In en, this message translates to:
  /// **'What would help right now?'**
  String get whatWouldHelp;

  /// No description provided for @comfortMe.
  ///
  /// In en, this message translates to:
  /// **'Comfort me'**
  String get comfortMe;

  /// No description provided for @comfortMeBody.
  ///
  /// In en, this message translates to:
  /// **'Verses of mercy and reassurance'**
  String get comfortMeBody;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// No description provided for @remindMeBody.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders to reset'**
  String get remindMeBody;

  /// No description provided for @helpComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get helpComfort;

  /// No description provided for @helpRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get helpRemind;

  /// No description provided for @moodAndHelp.
  ///
  /// In en, this message translates to:
  /// **'{mood} · {help}'**
  String moodAndHelp(String mood, String help);

  /// No description provided for @howMuchTime.
  ///
  /// In en, this message translates to:
  /// **'How much time do you have?'**
  String get howMuchTime;

  /// No description provided for @timeRecommend.
  ///
  /// In en, this message translates to:
  /// **'We recommend {minutes} minutes, so there\'s time to slow down.'**
  String timeRecommend(int minutes);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @verseLabel.
  ///
  /// In en, this message translates to:
  /// **'Surah · {ref}'**
  String verseLabel(String ref);

  /// No description provided for @arabicSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Arabic · Uthmani · from Quran API'**
  String get arabicSourceLabel;

  /// No description provided for @translationSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation · Sahih International'**
  String get translationSourceLabel;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get endSession;

  /// No description provided for @previousVerse.
  ///
  /// In en, this message translates to:
  /// **'Previous verse'**
  String get previousVerse;

  /// No description provided for @nextVerse.
  ///
  /// In en, this message translates to:
  /// **'Next verse'**
  String get nextVerse;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @preparingVerses.
  ///
  /// In en, this message translates to:
  /// **'Preparing verses…'**
  String get preparingVerses;

  /// No description provided for @beforeMood.
  ///
  /// In en, this message translates to:
  /// **'Before · {mood}'**
  String beforeMood(String mood);

  /// No description provided for @howDoYouFeelNow.
  ///
  /// In en, this message translates to:
  /// **'How do you feel now?'**
  String get howDoYouFeelNow;

  /// No description provided for @afterCalmer.
  ///
  /// In en, this message translates to:
  /// **'Calmer'**
  String get afterCalmer;

  /// No description provided for @afterBetter.
  ///
  /// In en, this message translates to:
  /// **'A little better'**
  String get afterBetter;

  /// No description provided for @afterSame.
  ///
  /// In en, this message translates to:
  /// **'The same'**
  String get afterSame;

  /// No description provided for @afterHeavier.
  ///
  /// In en, this message translates to:
  /// **'Heavier'**
  String get afterHeavier;

  /// No description provided for @sessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Session saved'**
  String get sessionSaved;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to carry this alone'**
  String get supportTitle;

  /// No description provided for @supportBody.
  ///
  /// In en, this message translates to:
  /// **'Talking to someone can help, right now.'**
  String get supportBody;

  /// No description provided for @emergencyCall.
  ///
  /// In en, this message translates to:
  /// **'Emergency · {number}'**
  String emergencyCall(String number);

  /// No description provided for @imSafe.
  ///
  /// In en, this message translates to:
  /// **'I\'m safe, go back'**
  String get imSafe;

  /// No description provided for @callFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start a call here. Please dial {number} from your phone.'**
  String callFailed(String number);

  /// No description provided for @tellMeInYourWords.
  ///
  /// In en, this message translates to:
  /// **'Tell me in your words…'**
  String get tellMeInYourWords;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @replyFeeling.
  ///
  /// In en, this message translates to:
  /// **'It sounds like you\'re feeling {mood}.'**
  String replyFeeling(String mood);

  /// No description provided for @replyTellMore.
  ///
  /// In en, this message translates to:
  /// **'Tell me a little more, or pick a feeling below.'**
  String get replyTellMore;

  /// No description provided for @replyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t read that just now. Pick a feeling below.'**
  String get replyUnavailable;

  /// No description provided for @somethingElse.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get somethingElse;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get listening;

  /// No description provided for @tellMeHowYouFeel.
  ///
  /// In en, this message translates to:
  /// **'Tell me how you feel'**
  String get tellMeHowYouFeel;

  /// No description provided for @speakNaturally.
  ///
  /// In en, this message translates to:
  /// **'Speak naturally. I\'ll listen.'**
  String get speakNaturally;

  /// No description provided for @tapToFinish.
  ///
  /// In en, this message translates to:
  /// **'Tap to finish'**
  String get tapToFinish;

  /// No description provided for @finishListening.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishListening;

  /// No description provided for @talkInstead.
  ///
  /// In en, this message translates to:
  /// **'Speak instead of typing'**
  String get talkInstead;

  /// No description provided for @voiceNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow the microphone and speech recognition for Uns in Settings to talk instead of typing.'**
  String get voiceNoPermission;

  /// No description provided for @voiceUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Voice isn\'t available on this phone. You can type instead.'**
  String get voiceUnsupported;

  /// No description provided for @captureReflection.
  ///
  /// In en, this message translates to:
  /// **'Capture a reflection? · Optional'**
  String get captureReflection;

  /// No description provided for @write.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get write;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @todaysPrompt.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prompt'**
  String get todaysPrompt;

  /// No description provided for @prompt1.
  ///
  /// In en, this message translates to:
  /// **'Which verse stayed with you, and why?'**
  String get prompt1;

  /// No description provided for @prompt2.
  ///
  /// In en, this message translates to:
  /// **'What felt lighter after listening?'**
  String get prompt2;

  /// No description provided for @prompt3.
  ///
  /// In en, this message translates to:
  /// **'What would you like to carry into the rest of today?'**
  String get prompt3;

  /// No description provided for @prompt4.
  ///
  /// In en, this message translates to:
  /// **'What is on your heart right now?'**
  String get prompt4;

  /// No description provided for @writeHint.
  ///
  /// In en, this message translates to:
  /// **'Write a few lines…'**
  String get writeHint;

  /// No description provided for @onlyOnThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Only on this phone'**
  String get onlyOnThisPhone;

  /// No description provided for @reflectionSaved.
  ///
  /// In en, this message translates to:
  /// **'Reflection saved to your journal'**
  String get reflectionSaved;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @journalEmpty.
  ///
  /// In en, this message translates to:
  /// **'Sessions you finish appear here, with anything you write.'**
  String get journalEmpty;

  /// No description provided for @sessionOnly.
  ///
  /// In en, this message translates to:
  /// **'Session only'**
  String get sessionOnly;

  /// No description provided for @moodsBeforeAfter.
  ///
  /// In en, this message translates to:
  /// **'{before} → {after}'**
  String moodsBeforeAfter(String before, String after);

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today {time}'**
  String todayAt(String time);

  /// No description provided for @entryMinutes.
  ///
  /// In en, this message translates to:
  /// **'{date} · {minutes} min'**
  String entryMinutes(String date, int minutes);

  /// No description provided for @noReflection.
  ///
  /// In en, this message translates to:
  /// **'No reflection written for this session.'**
  String get noReflection;

  /// No description provided for @replaySession.
  ///
  /// In en, this message translates to:
  /// **'Replay session'**
  String get replaySession;

  /// No description provided for @playVerse.
  ///
  /// In en, this message translates to:
  /// **'Play {ref}'**
  String playVerse(String ref);

  /// No description provided for @journalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No entries} =1{1 entry} other{{count} entries}}'**
  String journalCount(int count);

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get startRecording;

  /// No description provided for @pauseRecording.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseRecording;

  /// No description provided for @resumeRecording.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeRecording;

  /// No description provided for @discardRecording.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardRecording;

  /// No description provided for @saveRecording.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveRecording;

  /// No description provided for @micNeeded.
  ///
  /// In en, this message translates to:
  /// **'Allow the microphone for Uns in Settings to record a reflection.'**
  String get micNeeded;

  /// No description provided for @voiceReflection.
  ///
  /// In en, this message translates to:
  /// **'Voice reflection · {length}'**
  String voiceReflection(String length);

  /// No description provided for @playVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Play voice reflection'**
  String get playVoiceNote;

  /// No description provided for @stopVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopVoiceNote;

  /// No description provided for @voiceNoteMissing.
  ///
  /// In en, this message translates to:
  /// **'This voice reflection can\'t be opened on this phone.'**
  String get voiceNoteMissing;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @saveYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Save your journey'**
  String get saveYourJourney;

  /// No description provided for @saveJourneyBody.
  ///
  /// In en, this message translates to:
  /// **'Sync your prayer settings and tasbih across your devices. Your journal always stays on this phone.'**
  String get saveJourneyBody;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get continueWithEmail;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get yourEmail;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get emailHint;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @passwordRule.
  ///
  /// In en, this message translates to:
  /// **'8 or more characters'**
  String get passwordRule;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get newHere;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterCode;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to {email}'**
  String codeSentTo(String email);

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String resendIn(String time);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'New code sent'**
  String get codeResent;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get newPassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @journeySaved.
  ///
  /// In en, this message translates to:
  /// **'Journey saved'**
  String get journeySaved;

  /// No description provided for @signedInWith.
  ///
  /// In en, this message translates to:
  /// **'Signed in with {email}'**
  String signedInWith(String email);

  /// No description provided for @syncSettings.
  ///
  /// In en, this message translates to:
  /// **'Sync your settings across devices'**
  String get syncSettings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This removes your account and the settings and tasbih history synced with it. Your journal and everything else on this phone stay here.'**
  String get deleteAccountBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get signedOut;

  /// No description provided for @authWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'That email and password don\'t match.'**
  String get authWrongPassword;

  /// No description provided for @authEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'There\'s already an account with this email. Sign in instead.'**
  String get authEmailTaken;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get authWeakPassword;

  /// No description provided for @authWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t right, or it has expired.'**
  String get authWrongCode;

  /// No description provided for @authTooManyTries.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Wait a minute, then try again.'**
  String get authTooManyTries;

  /// No description provided for @authOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect. Check your connection and try again.'**
  String get authOffline;

  /// No description provided for @authNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Accounts aren\'t available right now.'**
  String get authNotAvailable;

  /// No description provided for @authUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authUnknown;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the account. Check your connection and try again.'**
  String get deleteFailed;

  /// No description provided for @prayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayer;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @recitation.
  ///
  /// In en, this message translates to:
  /// **'Recitation'**
  String get recitation;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Uns is built so what you share stays yours.'**
  String get privacyIntro;

  /// No description provided for @privacyPhone.
  ///
  /// In en, this message translates to:
  /// **'On this phone only, encrypted: your journal, voice reflections, moods, sessions and location.'**
  String get privacyPhone;

  /// No description provided for @privacyClassify.
  ///
  /// In en, this message translates to:
  /// **'When you type or say how you feel, only those words are sent to be understood — with no name or account — and they aren\'t kept.'**
  String get privacyClassify;

  /// No description provided for @privacyAccount.
  ///
  /// In en, this message translates to:
  /// **'If you sign in: your prayer and alert settings, reciter and tasbih history sync to your account. Nothing else.'**
  String get privacyAccount;

  /// No description provided for @privacyNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads, ever.'**
  String get privacyNoAds;

  /// No description provided for @reciterTitle.
  ///
  /// In en, this message translates to:
  /// **'Recitation'**
  String get reciterTitle;

  /// No description provided for @goDeeper.
  ///
  /// In en, this message translates to:
  /// **'Go deeper'**
  String get goDeeper;

  /// No description provided for @goDeeperBody.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Shama sessions, every reciter offline, custom dhikr and mood insights.'**
  String get goDeeperBody;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @planLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get planLifetime;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'{price} / yr'**
  String perYear(String price);

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} / mo'**
  String perMonth(String price);

  /// No description provided for @once.
  ///
  /// In en, this message translates to:
  /// **'{price} once'**
  String once(String price);

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String savePercent(int percent);

  /// No description provided for @noAdsRestore.
  ///
  /// In en, this message translates to:
  /// **'No ads, ever'**
  String get noAdsRestore;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @youHavePremium.
  ///
  /// In en, this message translates to:
  /// **'You have Premium'**
  String get youHavePremium;

  /// No description provided for @premiumThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting Uns.'**
  String get premiumThanks;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get premiumActive;

  /// No description provided for @premiumWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium'**
  String get premiumWelcome;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get restored;

  /// No description provided for @nothingToRestore.
  ///
  /// In en, this message translates to:
  /// **'No purchases to restore'**
  String get nothingToRestore;

  /// No description provided for @buyFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase didn\'t go through. You haven\'t been charged.'**
  String get buyFailed;

  /// No description provided for @plansUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Plans aren\'t available right now. Check your connection and try again.'**
  String get plansUnavailable;

  /// No description provided for @freeLeft.
  ///
  /// In en, this message translates to:
  /// **'{left} of {total} free this week'**
  String freeLeft(int left, int total);

  /// No description provided for @noFreeLeft.
  ///
  /// In en, this message translates to:
  /// **'No free sessions left'**
  String get noFreeLeft;

  /// No description provided for @usedOf.
  ///
  /// In en, this message translates to:
  /// **'{used} of {total} used'**
  String usedOf(int used, int total);

  /// No description provided for @resetsMonday.
  ///
  /// In en, this message translates to:
  /// **'Your free sessions reset on Monday'**
  String get resetsMonday;

  /// No description provided for @alwaysFree.
  ///
  /// In en, this message translates to:
  /// **'Prayer times, tasbih and your journal are always free.'**
  String get alwaysFree;

  /// No description provided for @seePremium.
  ///
  /// In en, this message translates to:
  /// **'See Premium'**
  String get seePremium;

  /// No description provided for @revisitPastSession.
  ///
  /// In en, this message translates to:
  /// **'Revisit a past session'**
  String get revisitPastSession;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone setting'**
  String get languageSystem;

  /// Always in English, whatever the app language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Always in Arabic script, whatever the app language.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageBody.
  ///
  /// In en, this message translates to:
  /// **'Verses always show in Arabic, with the English translation.'**
  String get languageBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
