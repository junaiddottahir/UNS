import '../prayer/prayer_schedule.dart';

/// How a prayer announces itself at its start time.
enum AlertMode { off, silent, notification, adhan }

/// Minutes-before choices for the pre-prayer reminder (0 = none).
const reminderChoices = [0, 10, 15, 30];

/// One prayer's alert choices.
class PrayerAlert {
  const PrayerAlert({
    this.mode = AlertMode.off,
    this.remindBefore = 0,
    this.checkIn = false,
  });

  final AlertMode mode;

  /// Minutes before the prayer for a reminder; 0 for none.
  final int remindBefore;

  /// Whether to ask "did you pray?" after the prayer starts.
  final bool checkIn;

  PrayerAlert copyWith({AlertMode? mode, int? remindBefore, bool? checkIn}) =>
      PrayerAlert(
        mode: mode ?? this.mode,
        remindBefore: remindBefore ?? this.remindBefore,
        checkIn: checkIn ?? this.checkIn,
      );

  Map<String, Object?> toJson() => {
    'mode': mode.name,
    'before': remindBefore,
    'checkIn': checkIn,
  };

  static PrayerAlert fromJson(Object? json) {
    if (json is! Map<String, Object?>) return const PrayerAlert();
    final before = json['before'];
    return PrayerAlert(
      mode: AlertMode.values.asNameMap()[json['mode']] ?? AlertMode.off,
      remindBefore: before is int && reminderChoices.contains(before)
          ? before
          : 0,
      checkIn: json['checkIn'] == true,
    );
  }
}

/// Per-prayer alert choices. Nothing alerts until the user turns it on.
class AlertSettings {
  const AlertSettings({this.prayers = const {}, this.sound = AlertMode.adhan})
    : assert(sound != AlertMode.off);

  static const defaults = AlertSettings();

  final Map<Prayer, PrayerAlert> prayers;

  /// The onboarding "Sound" choice, given to prayers as they're turned on.
  final AlertMode sound;

  PrayerAlert of(Prayer p) => prayers[p] ?? const PrayerAlert();

  AlertMode modeOf(Prayer p) => of(p).mode;

  bool isOn(Prayer p) => modeOf(p) != AlertMode.off;

  int get onCount => Prayer.values.where(isOn).length;

  AlertSettings withPrayer(Prayer p, PrayerAlert alert) =>
      AlertSettings(prayers: {...prayers, p: alert}, sound: sound);

  /// Turns [p] on with [sound], or off.
  AlertSettings toggle(Prayer p) =>
      withPrayer(p, of(p).copyWith(mode: isOn(p) ? AlertMode.off : sound));

  /// Sets the sound and gives it to every prayer that is on.
  AlertSettings withSound(AlertMode mode) => AlertSettings(
    prayers: {
      for (final p in Prayer.values)
        p: of(p).copyWith(mode: isOn(p) ? mode : AlertMode.off),
    },
    sound: mode,
  );

  Map<String, Object?> toJson() => {
    'sound': sound.name,
    'prayers': {for (final p in Prayer.values) p.name: of(p).toJson()},
  };

  /// Unknown or missing values fall back to off / adhan.
  factory AlertSettings.fromJson(Map<String, Object?> json) {
    final prayers = json['prayers'];
    final sound = AlertMode.values.asNameMap()[json['sound']];
    return AlertSettings(
      prayers: {
        if (prayers is Map<String, Object?>)
          for (final p in Prayer.values)
            p: PrayerAlert.fromJson(prayers[p.name]),
      },
      sound: sound == null || sound == AlertMode.off ? AlertMode.adhan : sound,
    );
  }
}
