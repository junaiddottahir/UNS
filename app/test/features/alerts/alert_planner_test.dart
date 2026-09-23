import 'package:flutter_test/flutter_test.dart';
import 'package:uns/features/alerts/alert_planner.dart';
import 'package:uns/features/alerts/alert_settings.dart';
import 'package:uns/features/prayer/prayer_schedule.dart';
import 'package:uns/features/prayer/prayer_settings.dart';

import '../../support/test_app.dart';

void main() {
  final schedule = PrayerSchedule(
    latitude: sydney.latitude,
    longitude: sydney.longitude,
    zone: timeZoneNamed(sydney.timeZone),
    method: PrayerMethod.muslimWorldLeague,
    asr: AsrMethod.standard,
    highLatitude: HighLatitudeMethod.middleOfNight,
  );
  // testNow is 13:00 in Sydney: Fajr and Dhuhr have passed today.
  List<PlannedAlert> plan(AlertSettings s, {int days = 7}) =>
      planAlerts(schedule: schedule, settings: s, now: testNow, days: days);

  test('nothing is scheduled by default', () {
    expect(plan(AlertSettings.defaults), isEmpty);
  });

  test('only future alerts, earliest first', () {
    final s = AlertSettings.defaults.toggle(Prayer.fajr).toggle(Prayer.asr);
    final alerts = plan(s, days: 2);
    // Today: Asr only (Fajr passed). Tomorrow: Fajr and Asr.
    expect(alerts.map((a) => a.prayer), [Prayer.asr, Prayer.fajr, Prayer.asr]);
    expect(alerts.every((a) => a.fireAt.isAfter(testNow)), isTrue);
    expect(alerts.first.mode, AlertMode.adhan);
    expect(alerts.first.fireAt, alerts.first.prayerTime);
  });

  test('reminder before and check-in after, even with the alert off', () {
    final s = AlertSettings.defaults.withPrayer(
      Prayer.maghrib,
      const PrayerAlert(remindBefore: 15, checkIn: true),
    );
    final today = plan(s, days: 1);
    expect(today.map((a) => a.kind), [AlertKind.reminder, AlertKind.checkIn]);
    final [reminder, checkIn] = today;
    expect(
      reminder.prayerTime.difference(reminder.fireAt),
      const Duration(minutes: 15),
    );
    expect(checkIn.fireAt.difference(checkIn.prayerTime), checkInDelay);
    expect(reminder.mode, AlertMode.notification);
  });

  test('follow-ups stay silent when the prayer alert is silent', () {
    final s = AlertSettings.defaults.withPrayer(
      Prayer.isha,
      const PrayerAlert(mode: AlertMode.silent, remindBefore: 10),
    );
    expect(plan(s, days: 1).map((a) => a.mode).toSet(), {AlertMode.silent});
  });

  test('stays under the iOS pending limit with unique ids', () {
    var s = AlertSettings.defaults;
    for (final p in Prayer.values) {
      s = s.withPrayer(
        p,
        const PrayerAlert(
          mode: AlertMode.adhan,
          remindBefore: 10,
          checkIn: true,
        ),
      );
    }
    final alerts = plan(s);
    expect(alerts.length, maxPendingAlerts);
    expect(alerts.map((a) => a.id).toSet().length, alerts.length);
    for (var i = 1; i < alerts.length; i++) {
      expect(alerts[i].fireAt.isBefore(alerts[i - 1].fireAt), isFalse);
    }
  });
}
