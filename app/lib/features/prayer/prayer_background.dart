import 'prayer_schedule.dart';

/// The prototype's background photo for each prayer, shown while it is the
/// next one.
String prayerBackground(Prayer? p) => switch (p) {
  Prayer.fajr => 'assets/images/bg_fajr.jpg',
  Prayer.dhuhr => 'assets/images/bg_dhuhr.jpg',
  Prayer.asr => 'assets/images/bg_asr.jpg',
  Prayer.maghrib => 'assets/images/bg_maghrib.jpg',
  Prayer.isha => 'assets/images/bg_isha.jpg',
  null => 'assets/images/bg_default.jpg',
};
