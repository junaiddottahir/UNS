import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/timezone.dart' as tz;

import 'alert_settings.dart';

/// Notification permission. An interface so tests can fake it.
abstract interface class NotificationPermission {
  /// Shows the OS prompt (if it still can); true if allowed.
  Future<bool> request();

  /// Whether notifications are currently allowed, without prompting.
  Future<bool> isGranted();

  /// Opens this app's page in the Settings app.
  Future<void> openSettings();
}

/// A notification ready to schedule, with its text already localised.
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.fireAt,
    required this.title,
    required this.body,
    required this.mode,
  });

  final int id;
  final tz.TZDateTime fireAt;
  final String title;
  final String body;
  final AlertMode mode;
}

/// Replaces every pending prayer notification. An interface so tests can
/// fake it.
abstract interface class AlertScheduler {
  Future<void> replaceAll(List<ScheduledNotification> notifications);
}

/// Both services on flutter_local_notifications.
class LocalNotifications implements NotificationPermission, AlertScheduler {
  LocalNotifications([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _ready;

  // Initialise without prompting; the prompt comes from a button tap.
  Future<void> _init() => _ready ??= _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      ),
    ),
  );

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> request() async {
    await _init();
    if (Platform.isIOS) {
      return await _ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    if (Platform.isAndroid) {
      final allowed = await _android?.requestNotificationsPermission() ?? false;
      // Exact timing needs a separate grant on Android 12+; without it
      // alerts still come, a few minutes late at worst.
      if (allowed &&
          !(await _android?.canScheduleExactNotifications() ?? true)) {
        await _android?.requestExactAlarmsPermission();
      }
      return allowed;
    }
    return false;
  }

  @override
  Future<bool> isGranted() async {
    await _init();
    if (Platform.isIOS) {
      final options = await _ios?.checkPermissions();
      // Provisional (quiet) permission still delivers notifications.
      return options != null &&
          (options.isEnabled || options.isProvisionalEnabled);
    }
    if (Platform.isAndroid) {
      return await _android?.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  @override
  Future<void> openSettings() => Geolocator.openAppSettings();

  Future<void> _queue = Future.value();

  /// Runs one replacement at a time, so quick changes can't interleave;
  /// the last one called wins.
  @override
  Future<void> replaceAll(List<ScheduledNotification> notifications) =>
      _queue = _queue.then(
        (_) => _replace(notifications),
        onError: (_) {
          return _replace(notifications);
        },
      );

  Future<void> _replace(List<ScheduledNotification> notifications) async {
    await _init();
    await _plugin.cancelAllPendingNotifications();
    // iOS refuses to schedule until notifications are allowed; the sync
    // runs again once they are.
    if (notifications.isEmpty || !await isGranted()) return;
    final exact =
        !Platform.isAndroid ||
        (await _android?.canScheduleExactNotifications() ?? false);
    for (final n in notifications) {
      await _plugin.zonedSchedule(
        id: n.id,
        scheduledDate: n.fireAt,
        title: n.title,
        body: n.body,
        notificationDetails: _details(n.mode),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Android channels per sound; the user can tune each in Settings.
  /// Adhan uses the default sound until a recording is bundled (see
  /// progress-tracker.md).
  static NotificationDetails _details(AlertMode mode) {
    final silent = mode == AlertMode.silent;
    final (id, name) = switch (mode) {
      AlertMode.adhan => ('prayer_adhan', 'Adhan'),
      AlertMode.silent || AlertMode.off => ('prayer_silent', 'Silent alerts'),
      AlertMode.notification => ('prayer_alert', 'Prayer alerts'),
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        id,
        name,
        importance: silent ? Importance.low : Importance.high,
        priority: silent ? Priority.low : Priority.high,
        playSound: !silent,
        enableVibration: !silent,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: !silent,
        presentAlert: true,
        presentBanner: true,
        presentList: true,
      ),
    );
  }
}
