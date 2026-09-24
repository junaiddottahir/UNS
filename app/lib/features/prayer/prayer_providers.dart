import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/settings_store.dart';
import '../location/location_providers.dart';
import 'method_suggestion.dart';
import 'prayer_schedule.dart';
import 'prayer_settings.dart';

/// Prayer calculation choices, saved on the device.
final prayerSettingsProvider =
    NotifierProvider<PrayerSettingsNotifier, PrayerSettings>(
      PrayerSettingsNotifier.new,
    );

class PrayerSettingsNotifier extends Notifier<PrayerSettings> {
  @override
  PrayerSettings build() {
    final json = ref.read(settingsStoreProvider).readJson(SettingKeys.prayer);
    return json == null
        ? const PrayerSettings()
        : PrayerSettings.fromJson(json);
  }

  void setMethod(PrayerMethod method) => _save(state.copyWith(method: method));

  void setAsr(AsrMethod asr) => _save(state.copyWith(asr: asr));

  void _save(PrayerSettings settings) {
    state = settings;
    ref
        .read(settingsStoreProvider)
        .writeJson(SettingKeys.prayer, settings.toJson());
  }
}

/// The method suggested for the chosen location's country.
final suggestedMethodProvider = Provider<PrayerMethod?>((ref) {
  final location = ref.watch(userLocationProvider);
  return location == null
      ? null
      : suggestedMethodFor(location.city.countryCode);
});

/// The method in use: the user's choice, else the suggestion.
final prayerMethodProvider = Provider<PrayerMethod>((ref) {
  return ref.watch(prayerSettingsProvider).method ??
      ref.watch(suggestedMethodProvider) ??
      PrayerMethod.muslimWorldLeague;
});

/// Prayer times for the chosen location, or null before one is chosen.
final prayerScheduleProvider = Provider<PrayerSchedule?>((ref) {
  final location = ref.watch(userLocationProvider);
  if (location == null) return null;
  final settings = ref.watch(prayerSettingsProvider);
  return PrayerSchedule(
    latitude: location.latitude,
    longitude: location.longitude,
    zone: timeZoneNamed(location.city.timeZone),
    method: ref.watch(prayerMethodProvider),
    asr: settings.asr,
  );
});

/// The current time, updated at the start of every minute. Prayer times are
/// whole minutes, so the next prayer and countdown only change then.
final nowProvider = NotifierProvider<MinuteClock, DateTime>(MinuteClock.new);

class MinuteClock extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    _scheduleTick();
    return DateTime.now();
  }

  void _scheduleTick() {
    final now = DateTime.now();
    final untilNextMinute = Duration(
      seconds: 60 - now.second,
      milliseconds: -now.millisecond,
    );
    _timer = Timer(untilNextMinute, () {
      state = DateTime.now();
      _scheduleTick();
    });
  }
}
