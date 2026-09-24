import 'package:flutter_test/flutter_test.dart';
import 'package:uns/features/prayer/method_suggestion.dart';
import 'package:uns/features/prayer/prayer_schedule.dart';
import 'package:uns/features/prayer/prayer_settings.dart';

PrayerSchedule _schedule(
  double lat,
  double lng,
  String zone,
  PrayerMethod method, {
  AsrMethod asr = AsrMethod.standard,
}) => PrayerSchedule(
  latitude: lat,
  longitude: lng,
  zone: timeZoneNamed(zone),
  method: method,
  asr: asr,
);

int _minutes(DateTime t) => t.hour * 60 + t.minute;

/// Checks each prayer's local wall-clock time is within 2 minutes of the
/// reference, the usual spread between published sources.
void _expectClose(List<PrayerTime> times, List<String> reference) {
  expect(times.map((t) => t.prayer), Prayer.values);
  for (var i = 0; i < 5; i++) {
    final [h, m] = reference[i].split(':').map(int.parse).toList();
    final diff = (_minutes(times[i].time) - (h * 60 + m)).abs();
    expect(
      diff,
      lessThanOrEqualTo(2),
      reason: '${times[i].prayer.name}: ${times[i].time} vs ${reference[i]}',
    );
  }
}

void main() {
  // Reference: api.aladhan.com timings for 23 Sep 2026.
  test('Sydney, Muslim World League', () {
    final s = _schedule(
      -33.8678,
      151.2073,
      'Australia/Sydney',
      PrayerMethod.muslimWorldLeague,
    );
    _expectClose(s.timesOn(2026, 9, 23), [
      '04:21',
      '11:48',
      '15:13',
      '17:52',
      '19:10',
    ]);
  });

  test('Makkah, Umm al-Qura', () {
    final s = _schedule(
      21.4266,
      39.8256,
      'Asia/Riyadh',
      PrayerMethod.ummAlQura,
    );
    _expectClose(s.timesOn(2026, 9, 23), [
      '04:54',
      '12:13',
      '15:39',
      '18:16',
      '19:46',
    ]);
  });

  test('New York, ISNA', () {
    final s = _schedule(
      40.7128,
      -74.006,
      'America/New_York',
      PrayerMethod.isna,
    );
    _expectClose(s.timesOn(2026, 9, 23), [
      '05:29',
      '12:48',
      '16:14',
      '18:51',
      '20:07',
    ]);
  });

  test('Karachi, Karachi method with Hanafi Asr', () {
    final s = _schedule(
      24.8607,
      67.0011,
      'Asia/Karachi',
      PrayerMethod.karachi,
      asr: AsrMethod.hanafi,
    );
    _expectClose(s.timesOn(2026, 9, 23), [
      '05:05',
      '12:24',
      '16:47',
      '18:28',
      '19:44',
    ]);
  });

  test('Hanafi Asr is later than standard; other prayers unchanged', () {
    List<PrayerTime> times(AsrMethod asr) => _schedule(
      -33.8678,
      151.2073,
      'Australia/Sydney',
      PrayerMethod.muslimWorldLeague,
      asr: asr,
    ).timesOn(2026, 9, 23);
    final standard = times(AsrMethod.standard);
    final hanafi = times(AsrMethod.hanafi);
    expect(hanafi[2].time.isAfter(standard[2].time), isTrue);
    expect(hanafi[0].time, standard[0].time);
    expect(hanafi[3].time, standard[3].time);
  });

  test('times are in the city zone, whatever the phone zone', () {
    final s = _schedule(
      21.4266,
      39.8256,
      'Asia/Riyadh',
      PrayerMethod.ummAlQura,
    );
    final maghrib = s.timesOn(2026, 9, 23)[3].time;
    expect(maghrib.location.name, 'Asia/Riyadh');
    expect(maghrib.timeZoneOffset, const Duration(hours: 3));
    expect(maghrib.hour, 18);
  });

  test('"today" follows the city date, not the phone date', () {
    final s = _schedule(
      21.4266,
      39.8256,
      'Asia/Riyadh',
      PrayerMethod.ummAlQura,
    );
    // 22:30 UTC on 23 Sep is 01:30 on 24 Sep in Makkah.
    final now = DateTime.utc(2026, 9, 23, 22, 30);
    expect(s.today(now).first.time.day, 24);
  });

  group('next', () {
    final s = _schedule(
      -33.8678,
      151.2073,
      'Australia/Sydney',
      PrayerMethod.muslimWorldLeague,
    );
    final today = s.timesOn(2026, 9, 23);

    test('is the first prayer after now', () {
      final justAfterDhuhr = today[1].time.add(const Duration(minutes: 1));
      expect(s.next(justAfterDhuhr)!.prayer, Prayer.asr);
    });

    test('at the exact start time moves on to the following prayer', () {
      expect(s.next(today[2].time)!.prayer, Prayer.maghrib);
    });

    test("after Isha is tomorrow's Fajr", () {
      final lateNight = today[4].time.add(const Duration(hours: 1));
      final next = s.next(lateNight)!;
      expect(next.prayer, Prayer.fajr);
      expect(next.time.day, 24);
    });

    test('rolls over month end', () {
      final lastDay = s.timesOn(2026, 9, 30);
      final next = s.next(lastDay[4].time.add(const Duration(minutes: 5)))!;
      expect((next.time.month, next.time.day), (10, 1));
    });
  });

  test('polar day has no times and no next prayer', () {
    final s = _schedule(
      78.2232,
      15.6267,
      'Arctic/Longyearbyen',
      PrayerMethod.muslimWorldLeague,
    );
    expect(s.timesOn(2026, 6, 21), isEmpty);
    expect(s.next(DateTime.utc(2026, 6, 21, 12)), isNull);
  });

  group('suggestedMethodFor', () {
    test('uses the regional method where one applies', () {
      expect(suggestedMethodFor('SA'), PrayerMethod.ummAlQura);
      expect(suggestedMethodFor('us'), PrayerMethod.isna);
      expect(suggestedMethodFor('EG'), PrayerMethod.egyptian);
      expect(suggestedMethodFor('PK'), PrayerMethod.karachi);
    });

    test('falls back to Muslim World League', () {
      expect(suggestedMethodFor('AU'), PrayerMethod.muslimWorldLeague);
      expect(suggestedMethodFor('ZZ'), PrayerMethod.muslimWorldLeague);
    });
  });
}
