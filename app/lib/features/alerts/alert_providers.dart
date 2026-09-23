import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/settings_store.dart';
import '../prayer/prayer_schedule.dart';
import 'alert_settings.dart';
import 'notification_permission.dart';

final notificationPermissionProvider = Provider<NotificationPermission>(
  (ref) => LocalNotificationPermission(),
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

  void _save(AlertSettings settings) {
    state = settings;
    ref
        .read(settingsStoreProvider)
        .writeJson(SettingKeys.alerts, settings.toJson());
  }
}
