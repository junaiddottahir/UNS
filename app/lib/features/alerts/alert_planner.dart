import 'package:timezone/timezone.dart' as tz;

import '../prayer/prayer_schedule.dart';
import 'alert_settings.dart';

enum AlertKind { atTime, reminder, checkIn }

/// One notification to schedule.
class PlannedAlert {
  const PlannedAlert({
    required this.id,
    required this.kind,
    required this.prayer,
    required this.prayerTime,
    required this.fireAt,
    required this.mode,
    this.remindBefore = 0,
  });

  final int id;
  final AlertKind kind;
  final Prayer prayer;
  final tz.TZDateTime prayerTime;
  final tz.TZDateTime fireAt;

  /// Sound for this notification. Reminders and check-ins use the
  /// standard alert, or stay silent when the prayer's alert is silent.
  final AlertMode mode;
  final int remindBefore;
}

/// How long after a prayer starts the "did you pray?" check-in comes.
const checkInDelay = Duration(minutes: 30);

/// iOS keeps at most 64 pending notifications per app; stay under it.
const maxPendingAlerts = 60;

/// Plans every notification from [now] for up to [days] days, earliest
/// first, capped at [limit]. Days are counted at the prayer location.
List<PlannedAlert> planAlerts({
  required PrayerSchedule schedule,
  required AlertSettings settings,
  required DateTime now,
  int days = 7,
  int limit = maxPendingAlerts,
}) {
  final today = schedule.localNow(now);
  final planned = <PlannedAlert>[];

  for (var d = 0; d < days; d++) {
    final date = DateTime(today.year, today.month, today.day + d);
    for (final t in schedule.timesOn(date.year, date.month, date.day)) {
      final alert = settings.of(t.prayer);
      final followUp = alert.mode == AlertMode.silent
          ? AlertMode.silent
          : AlertMode.notification;
      // Stable ids: day, prayer, kind.
      int id(AlertKind k) => d * 100 + t.prayer.index * 10 + k.index;

      if (alert.mode != AlertMode.off) {
        planned.add(
          PlannedAlert(
            id: id(AlertKind.atTime),
            kind: AlertKind.atTime,
            prayer: t.prayer,
            prayerTime: t.time,
            fireAt: t.time,
            mode: alert.mode,
          ),
        );
      }
      if (alert.remindBefore > 0) {
        planned.add(
          PlannedAlert(
            id: id(AlertKind.reminder),
            kind: AlertKind.reminder,
            prayer: t.prayer,
            prayerTime: t.time,
            fireAt: t.time.subtract(Duration(minutes: alert.remindBefore)),
            mode: followUp,
            remindBefore: alert.remindBefore,
          ),
        );
      }
      if (alert.checkIn) {
        planned.add(
          PlannedAlert(
            id: id(AlertKind.checkIn),
            kind: AlertKind.checkIn,
            prayer: t.prayer,
            prayerTime: t.time,
            fireAt: t.time.add(checkInDelay),
            mode: followUp,
          ),
        );
      }
    }
  }

  final upcoming = planned.where((a) => a.fireAt.isAfter(now)).toList()
    ..sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return upcoming.take(limit).toList();
}
