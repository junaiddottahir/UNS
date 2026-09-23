/// Calculation methods offered to the user. Each maps to an `adhan` method.
enum PrayerMethod {
  muslimWorldLeague,
  ummAlQura,
  isna,
  egyptian,
  karachi,
  dubai,
  qatar,
  kuwait,
  moonsightingCommittee,
  singapore,
  turkey,
  tehran,
}

/// How Asr is calculated: standard (Shafi, Maliki, Hanbali) or Hanafi.
enum AsrMethod { standard, hanafi }

/// How Fajr and Isha are bounded where twilight lasts all night.
enum HighLatitudeMethod { middleOfNight, seventhOfNight, twilightAngle }

/// The user's prayer calculation choices.
class PrayerSettings {
  const PrayerSettings({
    this.method,
    this.asr = AsrMethod.standard,
    this.highLatitude = HighLatitudeMethod.middleOfNight,
  });

  /// Chosen method, or null to use the one suggested for the location's
  /// country.
  final PrayerMethod? method;
  final AsrMethod asr;
  final HighLatitudeMethod highLatitude;

  Map<String, Object?> toJson() => {
    'method': method?.name,
    'asr': asr.name,
    'highLatitude': highLatitude.name,
  };

  /// Unknown or missing values fall back to the defaults.
  factory PrayerSettings.fromJson(Map<String, Object?> json) {
    const defaults = PrayerSettings();
    return PrayerSettings(
      method: PrayerMethod.values.asNameMap()[json['method']],
      asr: AsrMethod.values.asNameMap()[json['asr']] ?? defaults.asr,
      highLatitude:
          HighLatitudeMethod.values.asNameMap()[json['highLatitude']] ??
          defaults.highLatitude,
    );
  }

  PrayerSettings copyWith({
    PrayerMethod? method,
    AsrMethod? asr,
    HighLatitudeMethod? highLatitude,
  }) => PrayerSettings(
    method: method ?? this.method,
    asr: asr ?? this.asr,
    highLatitude: highLatitude ?? this.highLatitude,
  );
}
