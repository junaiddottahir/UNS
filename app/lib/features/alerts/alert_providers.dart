import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/language.dart';
import '../../core/storage/settings_store.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_providers.dart';
import '../prayer/prayer_labels.dart';
import '../prayer/prayer_providers.dart';
import '../prayer/prayer_schedule.dart';
import 'alert_planner.dart';
import 'alert_settings.dart';
import 'notification_permission.dart';

final _localNotificationsProvider = Provider<LocalNotifications>(
  (ref) => LocalNotifications(),
);

final notificationPermissionProvider = Provider<NotificationPermission>(
  (ref) => ref.watch(_localNotificationsProvider),
);

final alertSchedulerProvider = Provider<AlertScheduler>(
  (ref) => ref.watch(_localNotificationsProvider),
);

/// Which prayers alert and how, saved on the device.
final alertSettingsProvider =
    NotifierProvider<AlertSettingsNotifier, AlertSettings>(
      AlertSettingsNotifier.new,
    );

class AlertSettingsNotifier extends Notifier<AlertSettings> {
  @override
  AlertSettings build() {
    final json = ref.read(settingsStoreProvider).readJson(SettingKeys.alerts);
    return json == null ? AlertSettings.defaults : AlertSettings.fromJson(json);
  }

  void toggle(Prayer p) => _save(state.toggle(p));

  void setSound(AlertMode mode) => _save(state.withSound(mode));

  /// Applies [change] to [p]'s current choices.
  void updatePrayer(Prayer p, PrayerAlert Function(PrayerAlert) change) =>
      _save(state.withPrayer(p, change(state.of(p))));

  void _save(AlertSettings settings) {
    state = settings;
    ref
        .read(settingsStoreProvider)
        .writeJson(SettingKeys.alerts, settings.toJson());
  }
}

/// The notifications that should be pending right now. Recomputed when
/// the location, prayer settings or alert choices change, and every six
/// hours so the window keeps moving forward while the app is open.
final plannedAlertsProvider = Provider<List<PlannedAlert>>((ref) {
  final schedule = ref.watch(prayerScheduleProvider);
  if (schedule == null) return const [];
  final settings = ref.watch(alertSettingsProvider);
  // Six-hour buckets, so minute ticks don't reschedule.
  ref.watch(
    nowProvider.select((n) => DateTime(n.year, n.month, n.day, n.hour ~/ 6)),
  );
  return planAlerts(
    schedule: schedule,
    settings: settings,
    now: ref.read(nowProvider),
  );
});

/// Bumped when notification permission may have changed (after asking,
/// or when the app returns from the background), so alerts resync.
final permissionCheckProvider = NotifierProvider<PermissionCheck, int>(
  PermissionCheck.new,
);

class PermissionCheck extends Notifier<int> {
  @override
  int build() => 0;

  void recheck() => state++;
}

/// Keeps the OS's pending notifications in step with [plannedAlertsProvider].
/// Watched by the app root so it runs from launch. Written in the app's
/// language, so changing it rewrites the pending alerts.
final alertSyncProvider = Provider<void>((ref) {
  final planned = ref.watch(plannedAlertsProvider);
  ref.watch(permissionCheckProvider);
  final place = ref.watch(userLocationProvider)?.city.name ?? '';
  final scheduler = ref.read(alertSchedulerProvider);
  final l10n = lookupAppLocalizations(
    ref.watch(languageProvider).locale ?? _deviceLocale(),
  );
  unawaited(() async {
    // This can run before the app's localisations load at launch.
    await initializeDateFormatting(l10n.localeName);
    try {
      await scheduler.replaceAll([
        for (final a in planned) _describe(a, l10n, place),
      ]);
    } on Exception catch (e) {
      // Alerts are best effort; the next change or launch tries again.
      debugPrint('Scheduling prayer alerts failed: $e');
    }
  }());
});

Locale _deviceLocale() {
  final device = PlatformDispatcher.instance.locale;
  final supported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == device.languageCode,
  );
  return supported ? Locale(device.languageCode) : const Locale('en');
}

ScheduledNotification _describe(
  PlannedAlert a,
  AppLocalizations l10n,
  String place,
) {
  final prayer = l10n.prayerName(a.prayer);
  final time = DateFormat.jm(l10n.localeName).format(a.prayerTime);
  final detail = l10n.alertDetail(time, place);
  final (title, body) = switch (a.kind) {
    AlertKind.atTime => (prayer, detail),
    AlertKind.reminder => (
      l10n.alertReminderTitle(prayer, a.remindBefore),
      detail,
    ),
    AlertKind.checkIn => (l10n.alertCheckInTitle(prayer), ''),
  };
  return ScheduledNotification(
    id: a.id,
    fireAt: a.fireAt,
    title: title,
    body: body,
    mode: a.mode,
  );
}
