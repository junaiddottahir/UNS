// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أُنس';

  @override
  String get welcomeGreeting => 'السلام عليكم';

  @override
  String get welcomeHeadline => 'هدّئ بالك، واذكر الله، وعِش بحضور.';

  @override
  String get welcomeBegin => 'ابدأ';

  @override
  String get introSkip => 'تخطٍّ';

  @override
  String get introNext => 'التالي';

  @override
  String get intro1Title => 'صلِّ في وقتها، أينما كنت';

  @override
  String get intro1Body => 'مواقيت دقيقة، وأذان، واتجاه القبلة.';

  @override
  String get intro2Title => 'آيات تناسب ما تشعر به';

  @override
  String get intro2Body => 'اختارها وراجعها عالِم شرعي.';

  @override
  String get intro3Title => 'خاص بك دائمًا';

  @override
  String get intro3Body => 'تبقى على هاتفك. بلا إعلانات، أبدًا.';

  @override
  String stepOf(int step, int total) {
    return '$step من $total';
  }

  @override
  String get back => 'رجوع';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get locationTitle => 'أين أنت؟';

  @override
  String get locationBody => 'لحساب مواقيت الصلاة واتجاه القبلة على هاتفك.';

  @override
  String get locationUseMine => 'استخدم موقعي';

  @override
  String get locationFinding => 'جارٍ تحديد موقعك…';

  @override
  String get locationChooseCity => 'اختر مدينة';

  @override
  String get locationDenied =>
      'الوصول إلى الموقع متوقف. يمكنك اختيار مدينتك بدلًا من ذلك.';

  @override
  String get locationDeniedForever =>
      'الوصول إلى الموقع متوقف لتطبيق أُنس. فعّله من الإعدادات، أو اختر مدينتك.';

  @override
  String get locationServiceOff =>
      'خدمات الموقع متوقفة على هذا الهاتف. فعّلها، أو اختر مدينتك.';

  @override
  String get locationFailed =>
      'تعذّر تحديد موقعك. حاول مرة أخرى، أو اختر مدينتك.';

  @override
  String get locationOpenSettings => 'فتح الإعدادات';

  @override
  String get citySearchTitle => 'اختر مدينة';

  @override
  String get citySearchHint => 'ابحث عن مدينتك';

  @override
  String citySearchEmpty(String query) {
    return 'لا توجد مدن تطابق \"$query\".';
  }

  @override
  String get prayerStepTitle => 'مواقيت صلاتك';

  @override
  String prayerStepBody(String place) {
    return '$place، اليوم. تتحدّث مع اختياراتك.';
  }

  @override
  String get notificationsStepTitle => 'لا تفوّت صلاة';

  @override
  String get notificationsStepBody => 'اختر الصلوات التي تنبّهك، وكيف.';

  @override
  String get reciterStepTitle => 'كيف تستمع إلى القرآن';

  @override
  String get reciterStepBody => 'اضغط على قارئ لتسمع مقطعًا.';

  @override
  String get finish => 'إنهاء';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get asrLabel => 'العصر';

  @override
  String get asrStandard => 'الجمهور';

  @override
  String get asrHanafi => 'الحنفي';

  @override
  String get highLatitudeLabel => 'خطوط العرض العليا';

  @override
  String get highLatitudeMiddle => 'منتصف الليل';

  @override
  String get highLatitudeSeventh => 'سُبع الليل';

  @override
  String get highLatitudeAngle => 'الزاوية';

  @override
  String get methodLabel => 'طريقة الحساب';

  @override
  String get methodTitle => 'طريقة الحساب';

  @override
  String get methodMwl => 'رابطة العالم الإسلامي';

  @override
  String get methodUmmAlQura => 'أم القرى، مكة المكرمة';

  @override
  String get methodIsna => 'الجمعية الإسلامية لأمريكا الشمالية';

  @override
  String get methodEgyptian => 'الهيئة المصرية العامة للمساحة';

  @override
  String get methodKarachi => 'جامعة العلوم الإسلامية، كراتشي';

  @override
  String get methodDubai => 'دبي';

  @override
  String get methodQatar => 'قطر';

  @override
  String get methodKuwait => 'الكويت';

  @override
  String get methodMoonsighting => 'لجنة رؤية الهلال';

  @override
  String get methodSingapore => 'سنغافورة';

  @override
  String get methodTurkey => 'رئاسة الشؤون الدينية، تركيا';

  @override
  String get methodTehran => 'جامعة طهران';

  @override
  String methodSuggested(String country) {
    return 'مقترحة لـ $country';
  }

  @override
  String methodSummary(String method, String asr) {
    return '$method · عصر $asr';
  }

  @override
  String get prayerSettingsTitle => 'إعدادات الصلاة';

  @override
  String get locationLabel => 'الموقع';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String nextPrayerAt(String time, String duration) {
    return '$time · بعد $duration';
  }

  @override
  String nextPrayerTag(String duration) {
    return 'القادمة · $duration';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String dateAndPlace(String date, String place) {
    return '$date · $place';
  }

  @override
  String prayerTimesUnavailable(String place) {
    return 'لا يمكن حساب مواقيت الصلاة في $place اليوم، لأن الشمس لا تشرق أو لا تغرب هناك. اختر مدينة أبعد عن القطب.';
  }

  @override
  String methodLine(String method) {
    return 'الطريقة · $method';
  }

  @override
  String get alertMeFor => 'نبّهني لـ';

  @override
  String get soundLabel => 'الصوت';

  @override
  String get soundAdhan => 'أذان';

  @override
  String get soundAlert => 'تنبيه';

  @override
  String get soundSilent => 'صامت';

  @override
  String get soundOff => 'متوقف';

  @override
  String get allowNotifications => 'السماح بالإشعارات';

  @override
  String get reciterLabel => 'القارئ';

  @override
  String get reciterAlafasy => 'مشاري العفاسي';

  @override
  String get reciterAbdulBasit => 'عبد الباسط عبد الصمد';

  @override
  String get reciterSudais => 'عبد الرحمن السديس';

  @override
  String get qibla => 'القبلة';

  @override
  String get tasbih => 'التسبيح';

  @override
  String get moodPrompt => 'كيف تشعر اليوم؟';

  @override
  String get moodVoice => 'أخبرنا بما تشعر';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabShama => 'شامة';

  @override
  String get tabTasbih => 'التسبيح';

  @override
  String get tabProfile => 'حسابي';

  @override
  String alertDetail(String time, String place) {
    return '$time · $place';
  }

  @override
  String alertReminderTitle(String prayer, int minutes) {
    return '$prayer بعد $minutes دقيقة';
  }

  @override
  String alertCheckInTitle(String prayer) {
    return 'هل صلّيت $prayer؟';
  }

  @override
  String get prayerAlertsTitle => 'تنبيهات الصلاة';

  @override
  String get alertsLabel => 'التنبيهات';

  @override
  String alertsCount(int count) {
    return '$count من 5';
  }

  @override
  String get atPrayerTime => 'عند وقت الصلاة';

  @override
  String get remindMeBefore => 'ذكّرني قبلها';

  @override
  String get askDidYouPray => 'اسألني \"هل صلّيت؟\"';

  @override
  String get reminderNone => 'بلا';

  @override
  String reminderMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String alertSummaryBefore(String mode, int minutes) {
    return '$mode · قبلها بـ $minutes د';
  }

  @override
  String get notificationsOff =>
      'الإشعارات متوقفة لتطبيق أُنس، لذلك لن تظهر التنبيهات.';

  @override
  String get turnOnNotifications => 'تفعيل الإشعارات';

  @override
  String get qiblaDirection => 'اتجاه القبلة';

  @override
  String get compassN => 'ش';

  @override
  String get compassNE => 'ش ق';

  @override
  String get compassE => 'ق';

  @override
  String get compassSE => 'ج ق';

  @override
  String get compassS => 'ج';

  @override
  String get compassSW => 'ج غ';

  @override
  String get compassW => 'غ';

  @override
  String get compassNW => 'ش غ';

  @override
  String degrees(int value) {
    return '$value°';
  }

  @override
  String get facingQibla => 'أنت تواجه القبلة';

  @override
  String get turnSlightlyLeft => 'استدر قليلًا إلى اليسار';

  @override
  String get turnSlightlyRight => 'استدر قليلًا إلى اليمين';

  @override
  String get turnLeft => 'استدر إلى اليسار';

  @override
  String get turnRight => 'استدر إلى اليمين';

  @override
  String get calibrate => 'معايرة';

  @override
  String get calibrateTitle => 'حرّك هاتفك على شكل الرقم 8';

  @override
  String get calibrateBody => 'بعيدًا عن المعادن والمغناطيس.';

  @override
  String accuracyLine(String level) {
    return 'الدقة · $level';
  }

  @override
  String get accuracyHigh => 'عالية';

  @override
  String get accuracyMedium => 'متوسطة';

  @override
  String get accuracyLow => 'منخفضة';

  @override
  String get accuracyUnknown => 'جارٍ الفحص';

  @override
  String get done => 'تم';

  @override
  String get close => 'إغلاق';

  @override
  String get compassLowAccuracy =>
      'دقة البوصلة منخفضة. قم بالمعايرة لقراءة أفضل.';

  @override
  String compassUnavailable(int degrees) {
    return 'البوصلة غير متاحة على هذا الهاتف. اتجه $degrees° من الشمال.';
  }

  @override
  String get compassNeedsLocation =>
      'اسمح بالوصول إلى الموقع لتتمكن البوصلة من تحديد الشمال الحقيقي.';

  @override
  String get allowLocation => 'السماح بالموقع';

  @override
  String get kaaba => 'الكعبة';

  @override
  String get history => 'السجل';

  @override
  String get today => 'اليوم';

  @override
  String get afterPrayer => 'بعد الصلاة';

  @override
  String get dhikrSubhanAllah => 'سبحان الله';

  @override
  String get dhikrAlhamdulillah => 'الحمد لله';

  @override
  String get dhikrAllahuAkbar => 'الله أكبر';

  @override
  String get customDhikr => 'ذكر مخصص';

  @override
  String get premium => 'المميز';

  @override
  String get streaksPremium => 'المواظبة · المميز';

  @override
  String get singleDhikr => 'ذكر واحد';

  @override
  String ofTarget(int target) {
    return 'من $target';
  }

  @override
  String get tapAnywhere => 'اضغط في أي مكان';

  @override
  String get complete => 'اكتمل';

  @override
  String get dhikrComplete => 'اكتمل الذكر';

  @override
  String get startOver => 'ابدأ من جديد';

  @override
  String get startAfterPrayer => 'ابدأ أذكار ما بعد الصلاة';

  @override
  String tasbihCount(int count, int target) {
    return '$count من $target، اضغط للعدّ';
  }

  @override
  String get sampleFailed =>
      'تعذّر تشغيل المقطع. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get ourSources => 'مصادرنا';

  @override
  String get sourcesIntro =>
      'كل آية تأتي من هذه المصادر دون أي تغيير. لا نولّد القرآن ولا نفسّره بالذكاء الاصطناعي أبدًا.';

  @override
  String get sourceArabic => 'العربية';

  @override
  String get sourceArabicValue => 'الرسم العثماني · حفص';

  @override
  String get sourceTranslation => 'الترجمة';

  @override
  String get sourceTranslationValue => 'Sahih International';

  @override
  String get sourceRecitation => 'التلاوة';

  @override
  String get sourceRecitationValue => 'UmmahAPI';

  @override
  String get sourceText => 'النص';

  @override
  String get sourceTextValue => 'fawazahmed0 Quran API';

  @override
  String get sourceReciter => 'القارئ';

  @override
  String get verseSelection => 'اختيار الآيات';

  @override
  String get verseSelectionBody => 'كل آية يراجعها ويعتمدها عالِم شرعي مؤهل.';

  @override
  String get otherData => 'بيانات أخرى';

  @override
  String get sourceCities => 'المدن';

  @override
  String get sourceCitiesValue => 'GeoNames · CC BY 4.0';

  @override
  String get sourceCompass => 'البوصلة';

  @override
  String get sourceCompassValue => 'NOAA · WMM-2025';

  @override
  String get howAreYouFeeling => 'كيف تشعر؟';

  @override
  String get moodAnxious => 'قلق';

  @override
  String get moodSad => 'حزين';

  @override
  String get moodLonely => 'وحيد';

  @override
  String get moodAngry => 'غاضب';

  @override
  String get moodGrateful => 'ممتن';

  @override
  String get moodHopeful => 'متفائل';

  @override
  String get moodHumble => 'متواضع';

  @override
  String get moodArrogant => 'متكبّر';

  @override
  String get moodGreedy => 'أريد المزيد';

  @override
  String get libraryNotReady => 'تُفتح الجلسات بعد أن يعتمد عالِمنا الآيات.';

  @override
  String get libraryOffline => 'اتصل بالإنترنت مرة واحدة لتنزيل الآيات.';

  @override
  String feelingMood(String mood) {
    return 'أشعر بـ$mood';
  }

  @override
  String get whatWouldHelp => 'ما الذي يساعدك الآن؟';

  @override
  String get comfortMe => 'واسِني';

  @override
  String get comfortMeBody => 'آيات رحمة وطمأنينة';

  @override
  String get remindMe => 'ذكّرني';

  @override
  String get remindMeBody => 'تذكير لطيف لتبدأ من جديد';

  @override
  String get helpComfort => 'مواساة';

  @override
  String get helpRemind => 'تذكير';

  @override
  String moodAndHelp(String mood, String help) {
    return '$mood · $help';
  }

  @override
  String get howMuchTime => 'كم لديك من الوقت؟';

  @override
  String timeRecommend(int minutes) {
    return 'ننصح بـ $minutes دقائق، ليكون هناك وقت للتمهّل.';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes د';
  }

  @override
  String verseLabel(String ref) {
    return 'سورة · $ref';
  }

  @override
  String get arabicSourceLabel => 'العربية · الرسم العثماني · من Quran API';

  @override
  String get translationSourceLabel => 'الترجمة · Sahih International';

  @override
  String get endSession => 'إنهاء الجلسة';

  @override
  String get previousVerse => 'الآية السابقة';

  @override
  String get nextVerse => 'الآية التالية';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get preparingVerses => 'جارٍ تجهيز الآيات…';

  @override
  String beforeMood(String mood) {
    return 'قبل · $mood';
  }

  @override
  String get howDoYouFeelNow => 'كيف تشعر الآن؟';

  @override
  String get afterCalmer => 'أهدأ';

  @override
  String get afterBetter => 'أفضل قليلًا';

  @override
  String get afterSame => 'كما أنا';

  @override
  String get afterHeavier => 'أثقل';

  @override
  String get sessionSaved => 'حُفظت الجلسة';

  @override
  String get supportTitle => 'لست مضطرًا لحمل هذا وحدك';

  @override
  String get supportBody => 'التحدث إلى أحد قد يساعد، الآن.';

  @override
  String emergencyCall(String number) {
    return 'الطوارئ · $number';
  }

  @override
  String get imSafe => 'أنا بأمان، عودة';

  @override
  String callFailed(String number) {
    return 'تعذّر بدء الاتصال هنا. يُرجى الاتصال بالرقم $number من هاتفك.';
  }

  @override
  String get tellMeInYourWords => 'أخبرني بكلماتك…';

  @override
  String get send => 'إرسال';

  @override
  String replyFeeling(String mood) {
    return 'يبدو أنك تشعر بـ$mood.';
  }

  @override
  String get replyTellMore => 'أخبرني أكثر قليلًا، أو اختر شعورًا من الأسفل.';

  @override
  String get replyUnavailable =>
      'لم أتمكن من فهم ذلك الآن. اختر شعورًا من الأسفل.';

  @override
  String get somethingElse => 'شيء آخر';

  @override
  String get listening => 'أستمع';

  @override
  String get tellMeHowYouFeel => 'أخبرني بما تشعر';

  @override
  String get speakNaturally => 'تحدّث بطبيعتك. أنا أستمع.';

  @override
  String get tapToFinish => 'اضغط للإنهاء';

  @override
  String get finishListening => 'إنهاء';

  @override
  String get talkInstead => 'تحدّث بدلًا من الكتابة';

  @override
  String get voiceNoPermission =>
      'اسمح لأُنس بالوصول إلى الميكروفون والتعرّف على الكلام من الإعدادات لتتحدث بدلًا من الكتابة.';

  @override
  String get voiceUnsupported =>
      'الصوت غير متاح على هذا الهاتف. يمكنك الكتابة بدلًا من ذلك.';

  @override
  String get captureReflection => 'هل تدوّن تأملًا؟ · اختياري';

  @override
  String get write => 'كتابة';

  @override
  String get record => 'تسجيل';

  @override
  String get todaysPrompt => 'سؤال اليوم';

  @override
  String get prompt1 => 'أي آية بقيت معك، ولماذا؟';

  @override
  String get prompt2 => 'ما الذي صار أخف بعد الاستماع؟';

  @override
  String get prompt3 => 'ما الذي تود أن تحمله معك لبقية اليوم؟';

  @override
  String get prompt4 => 'ما الذي في قلبك الآن؟';

  @override
  String get writeHint => 'اكتب بضعة أسطر…';

  @override
  String get onlyOnThisPhone => 'على هذا الهاتف فقط';

  @override
  String get reflectionSaved => 'حُفظ التأمل في يومياتك';

  @override
  String get journal => 'اليوميات';

  @override
  String get insights => 'رؤى';

  @override
  String get journalEmpty => 'تظهر هنا الجلسات التي تُنهيها، مع ما تكتبه.';

  @override
  String get sessionOnly => 'جلسة فقط';

  @override
  String moodsBeforeAfter(String before, String after) {
    return '$before ← $after';
  }

  @override
  String todayAt(String time) {
    return 'اليوم $time';
  }

  @override
  String entryMinutes(String date, int minutes) {
    return '$date · $minutes د';
  }

  @override
  String get noReflection => 'لم يُكتب تأمل لهذه الجلسة.';

  @override
  String get replaySession => 'إعادة الجلسة';

  @override
  String playVerse(String ref) {
    return 'تشغيل $ref';
  }

  @override
  String journalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مدخل',
      many: '$count مدخلًا',
      few: '$count مدخلات',
      two: 'مدخلان',
      one: 'مدخل واحد',
      zero: 'لا توجد مدخلات',
    );
    return '$_temp0';
  }

  @override
  String get startRecording => 'بدء التسجيل';

  @override
  String get pauseRecording => 'إيقاف مؤقت';

  @override
  String get resumeRecording => 'استئناف';

  @override
  String get discardRecording => 'تجاهل';

  @override
  String get saveRecording => 'حفظ';

  @override
  String get micNeeded =>
      'اسمح لأُنس بالوصول إلى الميكروفون من الإعدادات لتسجيل تأمل.';

  @override
  String voiceReflection(String length) {
    return 'تأمل صوتي · $length';
  }

  @override
  String get playVoiceNote => 'تشغيل التأمل الصوتي';

  @override
  String get stopVoiceNote => 'إيقاف';

  @override
  String get voiceNoteMissing =>
      'لا يمكن فتح هذا التأمل الصوتي على هذا الهاتف.';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get saveYourJourney => 'احفظ رحلتك';

  @override
  String get saveJourneyBody =>
      'زامن إعدادات صلاتك وتسبيحك بين أجهزتك. تبقى يومياتك دائمًا على هذا الهاتف.';

  @override
  String get continueWithApple => 'المتابعة باستخدام Apple';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get continueWithEmail => 'المتابعة بالبريد الإلكتروني';

  @override
  String get yourEmail => 'بريدك الإلكتروني';

  @override
  String get emailHint => 'you@email.com';

  @override
  String get next => 'التالي';

  @override
  String get createPassword => 'أنشئ كلمة مرور';

  @override
  String get passwordRule => '8 أحرف أو أكثر';

  @override
  String get haveAccount => 'لديك حساب؟ سجّل الدخول';

  @override
  String get newHere => 'جديد هنا؟ أنشئ حسابًا';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get enterCode => 'أدخل الرمز';

  @override
  String codeSentTo(String email) {
    return 'أُرسل إلى $email';
  }

  @override
  String resendIn(String time) {
    return 'إعادة الإرسال بعد $time';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get codeResent => 'أُرسل رمز جديد';

  @override
  String get newPassword => 'اختر كلمة مرور جديدة';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور';

  @override
  String get journeySaved => 'حُفظت رحلتك';

  @override
  String signedInWith(String email) {
    return 'مسجّل الدخول بـ $email';
  }

  @override
  String get syncSettings => 'زامن إعداداتك بين الأجهزة';

  @override
  String get account => 'الحساب';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountTitle => 'حذف حسابك؟';

  @override
  String get deleteAccountBody =>
      'سيؤدي هذا إلى حذف حسابك والإعدادات وسجل التسبيح المتزامن معه. تبقى يومياتك وكل شيء آخر على هذا الهاتف.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get accountDeleted => 'حُذف الحساب';

  @override
  String get signedOut => 'تم تسجيل الخروج';

  @override
  String get authWrongPassword =>
      'البريد الإلكتروني وكلمة المرور غير متطابقين.';

  @override
  String get authEmailTaken =>
      'يوجد حساب بهذا البريد الإلكتروني بالفعل. سجّل الدخول بدلًا من ذلك.';

  @override
  String get authWeakPassword => 'اختر كلمة مرور أقوى.';

  @override
  String get authWrongCode => 'الرمز غير صحيح، أو انتهت صلاحيته.';

  @override
  String get authTooManyTries => 'محاولات كثيرة. انتظر دقيقة ثم حاول مرة أخرى.';

  @override
  String get authOffline => 'تعذّر الاتصال. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get authNotAvailable => 'الحسابات غير متاحة الآن.';

  @override
  String get authUnknown => 'حدث خطأ ما. يُرجى المحاولة مرة أخرى.';

  @override
  String get deleteFailed => 'تعذّر حذف الحساب. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get prayer => 'الصلاة';

  @override
  String get alerts => 'التنبيهات';

  @override
  String get recitation => 'التلاوة';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get privacyIntro => 'صُمم أُنس لتبقى مشاركتك ملكًا لك.';

  @override
  String get privacyPhone =>
      'على هذا الهاتف فقط، مشفّرة: يومياتك، وتأملاتك الصوتية، ومشاعرك، وجلساتك، وموقعك.';

  @override
  String get privacyClassify =>
      'عندما تكتب أو تقول ما تشعر به، تُرسل تلك الكلمات فقط لفهمها — دون اسم أو حساب — ولا يُحتفظ بها.';

  @override
  String get privacyAccount =>
      'إذا سجّلت الدخول: تتزامن إعدادات الصلاة والتنبيهات والقارئ وسجل التسبيح مع حسابك. لا شيء غير ذلك.';

  @override
  String get privacyNoAds => 'بلا إعلانات، أبدًا.';

  @override
  String get reciterTitle => 'التلاوة';

  @override
  String get goDeeper => 'تعمّق أكثر';

  @override
  String get goDeeperBody =>
      'جلسات شامة غير محدودة، وكل القرّاء دون اتصال، وأذكار مخصصة، ورؤى عن مشاعرك.';

  @override
  String get planYearly => 'سنوي';

  @override
  String get planMonthly => 'شهري';

  @override
  String get planLifetime => 'مدى الحياة';

  @override
  String perYear(String price) {
    return '$price / سنة';
  }

  @override
  String perMonth(String price) {
    return '$price / شهر';
  }

  @override
  String once(String price) {
    return '$price مرة واحدة';
  }

  @override
  String savePercent(int percent) {
    return 'وفّر $percent%';
  }

  @override
  String get noAdsRestore => 'بلا إعلانات، أبدًا';

  @override
  String get restore => 'استعادة';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get youHavePremium => 'لديك الاشتراك المميز';

  @override
  String get premiumThanks => 'شكرًا لدعمك أُنس.';

  @override
  String get premiumActive => 'مفعّل';

  @override
  String get premiumWelcome => 'مرحبًا بك في المميز';

  @override
  String get restored => 'تمت استعادة المشتريات';

  @override
  String get nothingToRestore => 'لا توجد مشتريات لاستعادتها';

  @override
  String get buyFailed => 'لم تكتمل عملية الشراء. لم يُخصم منك أي مبلغ.';

  @override
  String get plansUnavailable =>
      'الخطط غير متاحة الآن. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String freeLeft(int left, int total) {
    return '$left من $total مجانية هذا الأسبوع';
  }

  @override
  String get noFreeLeft => 'لا توجد جلسات مجانية متبقية';

  @override
  String usedOf(int used, int total) {
    return 'استُخدم $used من $total';
  }

  @override
  String get resetsMonday => 'تتجدد جلساتك المجانية يوم الاثنين';

  @override
  String get alwaysFree => 'مواقيت الصلاة والتسبيح ويومياتك مجانية دائمًا.';

  @override
  String get seePremium => 'اطّلع على المميز';

  @override
  String get revisitPastSession => 'أعد زيارة جلسة سابقة';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'إعداد الهاتف';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageBody =>
      'تظهر الآيات دائمًا بالعربية، مع الترجمة الإنجليزية.';
}
