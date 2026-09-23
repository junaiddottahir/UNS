import 'prayer_settings.dart';

/// Countries whose local authority or common practice uses a method other
/// than Muslim World League. Based on the `adhan` library's regional
/// guidance; pending scholar review (see progress-tracker.md).
const _methodByCountry = <String, PrayerMethod>{
  // Arabian Peninsula
  'SA': PrayerMethod.ummAlQura,
  'YE': PrayerMethod.ummAlQura,
  'OM': PrayerMethod.ummAlQura,
  'BH': PrayerMethod.ummAlQura,
  'AE': PrayerMethod.dubai,
  'QA': PrayerMethod.qatar,
  'KW': PrayerMethod.kuwait,
  // Egyptian General Authority: Egypt, much of Africa, the Levant, Iraq
  'EG': PrayerMethod.egyptian,
  'SD': PrayerMethod.egyptian,
  'LY': PrayerMethod.egyptian,
  'DZ': PrayerMethod.egyptian,
  'MA': PrayerMethod.egyptian,
  'TN': PrayerMethod.egyptian,
  'SY': PrayerMethod.egyptian,
  'LB': PrayerMethod.egyptian,
  'JO': PrayerMethod.egyptian,
  'PS': PrayerMethod.egyptian,
  'IQ': PrayerMethod.egyptian,
  // Karachi: South Asia
  'PK': PrayerMethod.karachi,
  'IN': PrayerMethod.karachi,
  'BD': PrayerMethod.karachi,
  'AF': PrayerMethod.karachi,
  // North America
  'US': PrayerMethod.isna,
  'CA': PrayerMethod.isna,
  // Southeast Asia
  'SG': PrayerMethod.singapore,
  'MY': PrayerMethod.singapore,
  'ID': PrayerMethod.singapore,
  'BN': PrayerMethod.singapore,
  'TR': PrayerMethod.turkey,
  'IR': PrayerMethod.tehran,
  'GB': PrayerMethod.moonsightingCommittee,
};

/// The method suggested for an ISO 3166-1 alpha-2 country code.
PrayerMethod suggestedMethodFor(String countryCode) =>
    _methodByCountry[countryCode.toUpperCase()] ??
    PrayerMethod.muslimWorldLeague;
