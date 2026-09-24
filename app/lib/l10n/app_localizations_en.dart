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

  @override
  String get qiblaDirection => 'Qibla direction';

  @override
  String get compassN => 'N';

  @override
  String get compassNE => 'NE';

  @override
  String get compassE => 'E';

  @override
  String get compassSE => 'SE';

  @override
  String get compassS => 'S';

  @override
  String get compassSW => 'SW';

  @override
  String get compassW => 'W';

  @override
  String get compassNW => 'NW';

  @override
  String degrees(int value) {
    return '$value°';
  }

  @override
  String get facingQibla => 'You\'re facing the qibla';

  @override
  String get turnSlightlyLeft => 'Turn slightly left';

  @override
  String get turnSlightlyRight => 'Turn slightly right';

  @override
  String get turnLeft => 'Turn left';

  @override
  String get turnRight => 'Turn right';

  @override
  String get calibrate => 'Calibrate';

  @override
  String get calibrateTitle => 'Move your phone in a figure-8';

  @override
  String get calibrateBody => 'Away from metal and magnets.';

  @override
  String accuracyLine(String level) {
    return 'Accuracy · $level';
  }

  @override
  String get accuracyHigh => 'high';

  @override
  String get accuracyMedium => 'medium';

  @override
  String get accuracyLow => 'low';

  @override
  String get accuracyUnknown => 'checking';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get compassLowAccuracy =>
      'Compass accuracy is low. Calibrate for a better reading.';

  @override
  String compassUnavailable(int degrees) {
    return 'The compass isn\'t available on this phone. Face $degrees° from north.';
  }

  @override
  String get compassNeedsLocation =>
      'Allow location access so the compass can find true north.';

  @override
  String get allowLocation => 'Allow location';

  @override
  String get kaaba => 'Kaaba';

  @override
  String get history => 'History';

  @override
  String get today => 'Today';

  @override
  String get afterPrayer => 'After prayer';

  @override
  String get dhikrSubhanAllah => 'SubhanAllah';

  @override
  String get dhikrAlhamdulillah => 'Alhamdulillah';

  @override
  String get dhikrAllahuAkbar => 'Allahu Akbar';

  @override
  String get customDhikr => 'Custom dhikr';

  @override
  String get premium => 'Premium';

  @override
  String get streaksPremium => 'Streaks · Premium';

  @override
  String get singleDhikr => 'Single dhikr';

  @override
  String ofTarget(int target) {
    return 'of $target';
  }

  @override
  String get tapAnywhere => 'Tap anywhere';

  @override
  String get complete => 'Complete';

  @override
  String get dhikrComplete => 'Dhikr complete';

  @override
  String get startOver => 'Start over';

  @override
  String get startAfterPrayer => 'Start after-prayer dhikr';

  @override
  String tasbihCount(int count, int target) {
    return '$count of $target, tap to count';
  }

  @override
  String get sampleFailed =>
      'Couldn\'t play the sample. Check your connection and try again.';

  @override
  String get ourSources => 'Our sources';

  @override
  String get sourcesIntro =>
      'Every verse comes from these sources, unchanged. We never generate or explain the Quran with AI.';

  @override
  String get sourceArabic => 'Arabic';

  @override
  String get sourceArabicValue => 'Uthmani · Hafs';

  @override
  String get sourceTranslation => 'Translation';

  @override
  String get sourceTranslationValue => 'Sahih International';

  @override
  String get sourceRecitation => 'Recitation';

  @override
  String get sourceRecitationValue => 'UmmahAPI';

  @override
  String get sourceText => 'Text';

  @override
  String get sourceTextValue => 'fawazahmed0 Quran API';

  @override
  String get sourceReciter => 'Reciter';

  @override
  String get verseSelection => 'Verse selection';

  @override
  String get verseSelectionBody =>
      'Every verse is reviewed and approved by a qualified scholar.';

  @override
  String get otherData => 'Other data';

  @override
  String get sourceCities => 'Cities';

  @override
  String get sourceCitiesValue => 'GeoNames · CC BY 4.0';

  @override
  String get sourceCompass => 'Compass';

  @override
  String get sourceCompassValue => 'NOAA · WMM-2025';

  @override
  String get howAreYouFeeling => 'How are you feeling?';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodLonely => 'Lonely';

  @override
  String get moodAngry => 'Angry';

  @override
  String get moodGrateful => 'Grateful';

  @override
  String get moodHopeful => 'Hopeful';

  @override
  String get moodHumble => 'Humble';

  @override
  String get moodArrogant => 'Proud';

  @override
  String get moodGreedy => 'Wanting more';

  @override
  String get libraryNotReady =>
      'There\'s nothing for this feeling yet. Try another.';

  @override
  String get libraryOffline =>
      'Connect to the internet once to download your session.';

  @override
  String feelingMood(String mood) {
    return 'Feeling $mood';
  }

  @override
  String get whatWouldHelp => 'What would help right now?';

  @override
  String get comfortMe => 'Comfort me';

  @override
  String get comfortMeBody => 'Verses of mercy and reassurance';

  @override
  String get remindMe => 'Remind me';

  @override
  String get remindMeBody => 'Gentle reminders to reset';

  @override
  String get helpComfort => 'Comfort';

  @override
  String get helpRemind => 'Remind';

  @override
  String moodAndHelp(String mood, String help) {
    return '$mood · $help';
  }

  @override
  String get howMuchTime => 'How much time do you have?';

  @override
  String timeRecommend(int minutes) {
    return 'We recommend $minutes minutes, so there\'s time to slow down.';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String verseLabel(String ref) {
    return 'Surah · $ref';
  }

  @override
  String get arabicSourceLabel => 'Arabic · Uthmani · from Quran API';

  @override
  String get translationSourceLabel => 'Translation · Sahih International';

  @override
  String get endSession => 'End session';

  @override
  String get previousVerse => 'Previous';

  @override
  String get nextVerse => 'Next';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get preparingVerses => 'Preparing your session…';

  @override
  String beforeMood(String mood) {
    return 'Before · $mood';
  }

  @override
  String get howDoYouFeelNow => 'How do you feel now?';

  @override
  String get afterCalmer => 'Calmer';

  @override
  String get afterBetter => 'A little better';

  @override
  String get afterSame => 'The same';

  @override
  String get afterHeavier => 'Heavier';

  @override
  String get sessionSaved => 'Session saved';

  @override
  String get supportTitle => 'You don\'t have to carry this alone';

  @override
  String get supportBody => 'Talking to someone can help, right now.';

  @override
  String emergencyCall(String number) {
    return 'Emergency · $number';
  }

  @override
  String get imSafe => 'I\'m safe, go back';

  @override
  String callFailed(String number) {
    return 'Couldn\'t start a call here. Please dial $number from your phone.';
  }

  @override
  String get tellMeInYourWords => 'Tell me in your words…';

  @override
  String get send => 'Send';

  @override
  String replyFeeling(String mood) {
    return 'It sounds like you\'re feeling $mood.';
  }

  @override
  String get replyTellMore => 'Tell me a little more, or pick a feeling below.';

  @override
  String get replyUnavailable =>
      'I couldn\'t read that just now. Pick a feeling below.';

  @override
  String get somethingElse => 'Something else';

  @override
  String get listening => 'Listening';

  @override
  String get tellMeHowYouFeel => 'Tell me how you feel';

  @override
  String get speakNaturally => 'Speak naturally. I\'ll listen.';

  @override
  String get tapToFinish => 'Tap to finish';

  @override
  String get finishListening => 'Finish';

  @override
  String get talkInstead => 'Speak instead of typing';

  @override
  String get voiceNoPermission =>
      'Allow the microphone and speech recognition for Uns in Settings to talk instead of typing.';

  @override
  String get voiceUnsupported =>
      'Voice isn\'t available on this phone. You can type instead.';

  @override
  String get captureReflection => 'Capture a reflection? · Optional';

  @override
  String get write => 'Write';

  @override
  String get record => 'Record';

  @override
  String get todaysPrompt => 'Today\'s prompt';

  @override
  String get prompt1 => 'Which verse stayed with you, and why?';

  @override
  String get prompt2 => 'What felt lighter after listening?';

  @override
  String get prompt3 => 'What would you like to carry into the rest of today?';

  @override
  String get prompt4 => 'What is on your heart right now?';

  @override
  String get writeHint => 'Write a few lines…';

  @override
  String get onlyOnThisPhone => 'Only on this phone';

  @override
  String get reflectionSaved => 'Reflection saved to your journal';

  @override
  String get journal => 'Journal';

  @override
  String get insights => 'Insights';

  @override
  String get journalEmpty =>
      'Sessions you finish appear here, with anything you write.';

  @override
  String get sessionOnly => 'Session only';

  @override
  String moodsBeforeAfter(String before, String after) {
    return '$before → $after';
  }

  @override
  String todayAt(String time) {
    return 'Today $time';
  }

  @override
  String entryMinutes(String date, int minutes) {
    return '$date · $minutes min';
  }

  @override
  String get noReflection => 'No reflection written for this session.';

  @override
  String get replaySession => 'Replay session';

  @override
  String playVerse(String ref) {
    return 'Play $ref';
  }

  @override
  String journalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: 'No entries',
    );
    return '$_temp0';
  }

  @override
  String get startRecording => 'Start recording';

  @override
  String get pauseRecording => 'Pause';

  @override
  String get resumeRecording => 'Resume';

  @override
  String get discardRecording => 'Discard';

  @override
  String get saveRecording => 'Save';

  @override
  String get micNeeded =>
      'Allow the microphone for Uns in Settings to record a reflection.';

  @override
  String voiceReflection(String length) {
    return 'Voice reflection · $length';
  }

  @override
  String get playVoiceNote => 'Play voice reflection';

  @override
  String get stopVoiceNote => 'Stop';

  @override
  String get voiceNoteMissing =>
      'This voice reflection can\'t be opened on this phone.';

  @override
  String get notNow => 'Not now';

  @override
  String get saveYourJourney => 'Save your journey';

  @override
  String get saveJourneyBody =>
      'Sync your prayer settings and tasbih across your devices. Your journal always stays on this phone.';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithEmail => 'Continue with email';

  @override
  String get yourEmail => 'Your email';

  @override
  String get emailHint => 'you@email.com';

  @override
  String get next => 'Next';

  @override
  String get createPassword => 'Create a password';

  @override
  String get passwordRule => '8 or more characters';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get newHere => 'New here? Create an account';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get passwordHint => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get enterCode => 'Enter the code';

  @override
  String codeSentTo(String email) {
    return 'Sent to $email';
  }

  @override
  String resendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get codeResent => 'New code sent';

  @override
  String get newPassword => 'Choose a new password';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get journeySaved => 'Journey saved';

  @override
  String signedInWith(String email) {
    return 'Signed in with $email';
  }

  @override
  String get syncSettings => 'Sync your settings across devices';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'This removes your account and the settings and tasbih history synced with it. Your journal and everything else on this phone stay here.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get signedOut => 'Signed out';

  @override
  String get authWrongPassword => 'That email and password don\'t match.';

  @override
  String get authEmailTaken =>
      'There\'s already an account with this email. Sign in instead.';

  @override
  String get authWeakPassword => 'Choose a stronger password.';

  @override
  String get authWrongCode => 'That code isn\'t right, or it has expired.';

  @override
  String get authTooManyTries =>
      'Too many tries. Wait a minute, then try again.';

  @override
  String get authOffline =>
      'Couldn\'t connect. Check your connection and try again.';

  @override
  String get authNotAvailable => 'Accounts aren\'t available right now.';

  @override
  String get authUnknown => 'Something went wrong. Please try again.';

  @override
  String get deleteFailed =>
      'Couldn\'t delete the account. Check your connection and try again.';

  @override
  String get prayer => 'Prayer';

  @override
  String get alerts => 'Alerts';

  @override
  String get recitation => 'Recitation';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyIntro => 'Uns is built so what you share stays yours.';

  @override
  String get privacyPhone =>
      'On this phone only, encrypted: your journal, voice reflections, moods, sessions and location.';

  @override
  String get privacyClassify =>
      'When you type or say how you feel, only those words are sent to be understood — with no name or account — and they aren\'t kept.';

  @override
  String get privacyAccount =>
      'If you sign in: your prayer and alert settings, reciter and tasbih history sync to your account. Nothing else.';

  @override
  String get privacyNoAds => 'No ads, ever.';

  @override
  String get reciterTitle => 'Recitation';

  @override
  String get goDeeper => 'Go deeper';

  @override
  String get goDeeperBody =>
      'Unlimited Shama sessions, every reciter offline, custom dhikr and mood insights.';

  @override
  String get planYearly => 'Yearly';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planLifetime => 'Lifetime';

  @override
  String perYear(String price) {
    return '$price / yr';
  }

  @override
  String perMonth(String price) {
    return '$price / mo';
  }

  @override
  String once(String price) {
    return '$price once';
  }

  @override
  String savePercent(int percent) {
    return 'Save $percent%';
  }

  @override
  String get noAdsRestore => 'No ads, ever';

  @override
  String get restore => 'Restore';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get youHavePremium => 'You have Premium';

  @override
  String get premiumThanks => 'Thank you for supporting Uns.';

  @override
  String get premiumActive => 'Active';

  @override
  String get premiumWelcome => 'Welcome to Premium';

  @override
  String get restored => 'Purchases restored';

  @override
  String get nothingToRestore => 'No purchases to restore';

  @override
  String get buyFailed =>
      'The purchase didn\'t go through. You haven\'t been charged.';

  @override
  String get plansUnavailable =>
      'Plans aren\'t available right now. Check your connection and try again.';

  @override
  String freeLeft(int left, int total) {
    return '$left of $total free this week';
  }

  @override
  String get noFreeLeft => 'No free sessions left';

  @override
  String usedOf(int used, int total) {
    return '$used of $total used';
  }

  @override
  String get resetsMonday => 'Your free sessions reset on Monday';

  @override
  String get alwaysFree =>
      'Prayer times, tasbih and your journal are always free.';

  @override
  String get seePremium => 'See Premium';

  @override
  String get revisitPastSession => 'Revisit a past session';

  @override
  String get dhikrUnit => 'dhikr';

  @override
  String dhikrProgress(int done, int total) {
    return 'dhikr · $done of $total complete';
  }

  @override
  String get dhikrAllComplete => 'dhikr · all complete';

  @override
  String get goPremium => 'Go Premium';

  @override
  String duaLabel(String title) {
    return 'Dua · $title';
  }

  @override
  String duaSourceLabel(String source) {
    return '$source · via UmmahAPI';
  }

  @override
  String repeatTimes(int count) {
    return 'Said $count times';
  }

  @override
  String get readAlong => 'Read along';

  @override
  String get sourceDuas => 'Duas';

  @override
  String get sourceDuasValue => 'UmmahAPI · hadith cited';
}
