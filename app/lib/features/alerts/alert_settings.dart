import '../prayer/prayer_schedule.dart';

/// How a prayer announces itself. Scheduling arrives with unit 4.
enum AlertMode { off, silent, notification, adhan }

/// Per-prayer alert choices.
class AlertSettings {
  const AlertSettings(this.modes);

  /// Prototype defaults: adhan for all but Isha.
  static const defaults = AlertSettings({
    Prayer.fajr: AlertMode.adhan,
    Prayer.dhuhr: AlertMode.adhan,
    Prayer.asr: AlertMode.adhan,
    Prayer.maghrib: AlertMode.adhan,
    Prayer.isha: AlertMode.off,
  });

  final Map<Prayer, AlertMode> modes;

  AlertMode modeOf(Prayer p) => modes[p] ?? AlertMode.off;

  bool isOn(Prayer p) => modeOf(p) != AlertMode.off;

  /// The sound shared by the prayers that are on (the onboarding "Sound"
  /// choice); adhan when none are on.
  AlertMode get sound => Prayer.values
      .map(modeOf)
      .firstWhere((m) => m != AlertMode.off, orElse: () => AlertMode.adhan);

  /// Turns [p] on with the current sound, or off.
  AlertSettings toggle(Prayer p) {
    final current = sound;
    return AlertSettings({...modes, p: isOn(p) ? AlertMode.off : current});
  }

  /// Gives every prayer that is on the same [mode].
  AlertSettings withSound(AlertMode mode) => AlertSettings({
    for (final p in Prayer.values) p: isOn(p) ? mode : AlertMode.off,
  });

  Map<String, Object?> toJson() => {
    for (final p in Prayer.values) p.name: modeOf(p).name,
  };

  /// Unknown or missing prayers fall back to the defaults.
  factory AlertSettings.fromJson(Map<String, Object?> json) => AlertSettings({
    for (final p in Prayer.values)
      p: AlertMode.values.asNameMap()[json[p.name]] ?? defaults.modeOf(p),
  });
}
