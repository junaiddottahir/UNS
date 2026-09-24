import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'prayer_schedule.dart';
import 'prayer_settings.dart';

/// Display names and formatting for prayer values.
extension PrayerLabels on AppLocalizations {
  String prayerName(Prayer p) => switch (p) {
    Prayer.fajr => prayerFajr,
    Prayer.dhuhr => prayerDhuhr,
    Prayer.asr => prayerAsr,
    Prayer.maghrib => prayerMaghrib,
    Prayer.isha => prayerIsha,
  };

  String methodName(PrayerMethod m) => switch (m) {
    PrayerMethod.muslimWorldLeague => methodMwl,
    PrayerMethod.ummAlQura => methodUmmAlQura,
    PrayerMethod.isna => methodIsna,
    PrayerMethod.egyptian => methodEgyptian,
    PrayerMethod.karachi => methodKarachi,
    PrayerMethod.dubai => methodDubai,
    PrayerMethod.qatar => methodQatar,
    PrayerMethod.kuwait => methodKuwait,
    PrayerMethod.moonsightingCommittee => methodMoonsighting,
    PrayerMethod.singapore => methodSingapore,
    PrayerMethod.turkey => methodTurkey,
    PrayerMethod.tehran => methodTehran,
  };

  String asrName(AsrMethod a) => switch (a) {
    AsrMethod.standard => asrStandard,
    AsrMethod.hanafi => asrHanafi,
  };

  String highLatitudeName(HighLatitudeMethod h) => switch (h) {
    HighLatitudeMethod.middleOfNight => highLatitudeMiddle,
    HighLatitudeMethod.seventhOfNight => highLatitudeSeventh,
    HighLatitudeMethod.twilightAngle => highLatitudeAngle,
  };

  /// "2h 14m" or "14m", rounded up so the last minute reads "1m", not "0m".
  String untilText(Duration d) {
    final minutes = (d.inSeconds / 60).ceil().clamp(0, 1 << 30);
    final hours = minutes ~/ 60;
    return hours > 0
        ? durationHoursMinutes(hours, minutes % 60)
        : durationMinutes(minutes);
  }
}

/// A prayer time as the prototype shows it ("3:38"), or 24-hour ("15:38")
/// when the phone is set to 24-hour time.
String formatPrayerTime(BuildContext context, DateTime time) {
  final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat(use24 ? 'H:mm' : 'h:mm', locale).format(time);
}

/// "Wed, 23 Sep".
String formatShortDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat('EEE, d MMM', locale).format(date);
}

/// "Wednesday, 23 September".
String formatLongDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat('EEEE, d MMMM', locale).format(date);
}
