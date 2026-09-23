import 'package:adhan/adhan.dart' as adhan;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_settings.dart';

var _zonesLoaded = false;

/// An IANA time zone from the bundled database, loaded on first use.
tz.Location timeZoneNamed(String name) {
  if (!_zonesLoaded) {
    tzdata.initializeTimeZones();
    _zonesLoaded = true;
  }
  return tz.getLocation(name);
}

/// The five daily prayers, in order.
enum Prayer { fajr, dhuhr, asr, maghrib, isha }

/// One prayer's start time, in the location's time zone.
class PrayerTime {
  const PrayerTime(this.prayer, this.time);

  final Prayer prayer;
  final tz.TZDateTime time;
}

/// Calculates prayer times on the phone with `adhan`.
///
/// Times are expressed in the location's own time zone, so a city chosen
/// abroad shows its local times, not the phone's.
class PrayerSchedule {
  PrayerSchedule({
    required double latitude,
    required double longitude,
    required this.zone,
    required PrayerMethod method,
    required AsrMethod asr,
    required HighLatitudeMethod highLatitude,
  }) : _coordinates = adhan.Coordinates(latitude, longitude),
       _params = _parameters(method, asr, highLatitude);

  final tz.Location zone;
  final adhan.Coordinates _coordinates;
  final adhan.CalculationParameters _params;

  /// The current moment as a wall-clock time at the location.
  tz.TZDateTime localNow(DateTime now) => tz.TZDateTime.from(now, zone);

  /// Prayer times for a calendar date at the location. Empty when they
  /// can't be calculated, e.g. near the poles when the sun doesn't rise or
  /// set.
  List<PrayerTime> timesOn(int year, int month, int day) {
    final adhan.PrayerTimes times;
    try {
      times = adhan.PrayerTimes.utc(
        _coordinates,
        adhan.DateComponents(year, month, day),
        _params,
      );
    } on Object {
      return const [];
    }
    PrayerTime at(Prayer p, DateTime t) => PrayerTime(
      p,
      tz.TZDateTime.fromMillisecondsSinceEpoch(zone, t.millisecondsSinceEpoch),
    );
    return [
      at(Prayer.fajr, times.fajr),
      at(Prayer.dhuhr, times.dhuhr),
      at(Prayer.asr, times.asr),
      at(Prayer.maghrib, times.maghrib),
      at(Prayer.isha, times.isha),
    ];
  }

  /// Today's times at the location.
  List<PrayerTime> today(DateTime now) {
    final local = localNow(now);
    return timesOn(local.year, local.month, local.day);
  }

  /// The next prayer after [now]: later today, else tomorrow's Fajr.
  PrayerTime? next(DateTime now) {
    for (final t in today(now)) {
      if (t.time.isAfter(now)) return t;
    }
    final local = localNow(now);
    // DateTime normalises day overflow, e.g. 31 Jan + 1 → 1 Feb.
    final tomorrow = DateTime(local.year, local.month, local.day + 1);
    final times = timesOn(tomorrow.year, tomorrow.month, tomorrow.day);
    return times.isEmpty ? null : times.first;
  }

  static adhan.CalculationParameters _parameters(
    PrayerMethod method,
    AsrMethod asr,
    HighLatitudeMethod highLatitude,
  ) {
    final params = switch (method) {
      PrayerMethod.muslimWorldLeague =>
        adhan.CalculationMethod.muslim_world_league,
      PrayerMethod.ummAlQura => adhan.CalculationMethod.umm_al_qura,
      PrayerMethod.isna => adhan.CalculationMethod.north_america,
      PrayerMethod.egyptian => adhan.CalculationMethod.egyptian,
      PrayerMethod.karachi => adhan.CalculationMethod.karachi,
      PrayerMethod.dubai => adhan.CalculationMethod.dubai,
      PrayerMethod.qatar => adhan.CalculationMethod.qatar,
      PrayerMethod.kuwait => adhan.CalculationMethod.kuwait,
      PrayerMethod.moonsightingCommittee =>
        adhan.CalculationMethod.moon_sighting_committee,
      PrayerMethod.singapore => adhan.CalculationMethod.singapore,
      PrayerMethod.turkey => adhan.CalculationMethod.turkey,
      PrayerMethod.tehran => adhan.CalculationMethod.tehran,
    }.getParameters();
    params.madhab = switch (asr) {
      AsrMethod.standard => adhan.Madhab.shafi,
      AsrMethod.hanafi => adhan.Madhab.hanafi,
    };
    params.highLatitudeRule = switch (highLatitude) {
      HighLatitudeMethod.middleOfNight =>
        adhan.HighLatitudeRule.middle_of_the_night,
      HighLatitudeMethod.seventhOfNight =>
        adhan.HighLatitudeRule.seventh_of_the_night,
      HighLatitudeMethod.twilightAngle => adhan.HighLatitudeRule.twilight_angle,
    };
    return params;
  }
}
