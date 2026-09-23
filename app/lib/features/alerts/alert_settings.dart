import '../prayer/prayer_schedule.dart';

/// How a prayer announces itself. Scheduling arrives with unit 4.
enum AlertMode { off, silent, notification, adhan }

/// Per-prayer alert choices. Nothing alerts until the user turns it on.
class AlertSettings {
  const AlertSettings({this.modes = const {}, this.sound = AlertMode.adhan})
    : assert(sound != AlertMode.off);

  static const defaults = AlertSettings();

  final Map<Prayer, AlertMode> modes;

  /// The onboarding "Sound" choice, given to prayers as they're turned on.
  final AlertMode sound;

  AlertMode modeOf(Prayer p) => modes[p] ?? AlertMode.off;

  bool isOn(Prayer p) => modeOf(p) != AlertMode.off;

  /// Turns [p] on with [sound], or off.
  AlertSettings toggle(Prayer p) => AlertSettings(
    modes: {...modes, p: isOn(p) ? AlertMode.off : sound},
    sound: sound,
  );

  /// Sets the sound and gives it to every prayer that is on.
  AlertSettings withSound(AlertMode mode) => AlertSettings(
    modes: {for (final p in Prayer.values) p: isOn(p) ? mode : AlertMode.off},
    sound: mode,
  );

  Map<String, Object?> toJson() => {
    'sound': sound.name,
    'modes': {for (final p in Prayer.values) p.name: modeOf(p).name},
  };

  /// Unknown or missing values fall back to off / adhan.
  factory AlertSettings.fromJson(Map<String, Object?> json) {
    final modes = json['modes'];
    final sound = AlertMode.values.asNameMap()[json['sound']];
    return AlertSettings(
      modes: {
        if (modes is Map<String, Object?>)
          for (final p in Prayer.values)
            p: AlertMode.values.asNameMap()[modes[p.name]] ?? AlertMode.off,
      },
      sound: sound == null || sound == AlertMode.off ? AlertMode.adhan : sound,
    );
  }
}
