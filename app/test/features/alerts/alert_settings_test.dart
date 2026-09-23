import 'package:flutter_test/flutter_test.dart';
import 'package:uns/features/alerts/alert_settings.dart';
import 'package:uns/features/prayer/prayer_schedule.dart';

void main() {
  test('nothing is on by default', () {
    expect(Prayer.values.where(AlertSettings.defaults.isOn), isEmpty);
    expect(AlertSettings.defaults.sound, AlertMode.adhan);
  });

  test('the sound choice holds while every prayer is off', () {
    final s = AlertSettings.defaults
        .withSound(AlertMode.notification)
        .toggle(Prayer.asr);
    expect(s.modeOf(Prayer.asr), AlertMode.notification);
    expect(s.toggle(Prayer.asr).isOn(Prayer.asr), isFalse);
  });

  test('changing the sound updates only prayers that are on', () {
    final s = AlertSettings.defaults
        .toggle(Prayer.fajr)
        .withSound(AlertMode.silent);
    expect(s.modeOf(Prayer.fajr), AlertMode.silent);
    expect(s.modeOf(Prayer.dhuhr), AlertMode.off);
  });

  test('round-trips through JSON; bad data falls back safely', () {
    final s = AlertSettings.defaults
        .withSound(AlertMode.silent)
        .toggle(Prayer.maghrib);
    final back = AlertSettings.fromJson(s.toJson());
    expect(back.sound, AlertMode.silent);
    expect(back.modeOf(Prayer.maghrib), AlertMode.silent);
    expect(back.isOn(Prayer.fajr), isFalse);

    final odd = AlertSettings.fromJson({'sound': 'off', 'modes': 'x'});
    expect(odd.sound, AlertMode.adhan);
    expect(Prayer.values.where(odd.isOn), isEmpty);
  });
}
