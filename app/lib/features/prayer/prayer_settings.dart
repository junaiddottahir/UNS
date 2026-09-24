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

/// The user's prayer calculation choices.
class PrayerSettings {
  const PrayerSettings({this.method, this.asr = AsrMethod.standard});

  /// Chosen method, or null to use the one suggested for the location's
  /// country.
  final PrayerMethod? method;
  final AsrMethod asr;

  Map<String, Object?> toJson() => {'method': method?.name, 'asr': asr.name};

  /// Unknown or missing values fall back to the defaults.
  factory PrayerSettings.fromJson(Map<String, Object?> json) {
    const defaults = PrayerSettings();
    return PrayerSettings(
      method: PrayerMethod.values.asNameMap()[json['method']],
      asr: AsrMethod.values.asNameMap()[json['asr']] ?? defaults.asr,
    );
  }

  PrayerSettings copyWith({PrayerMethod? method, AsrMethod? asr}) =>
      PrayerSettings(method: method ?? this.method, asr: asr ?? this.asr);
}
