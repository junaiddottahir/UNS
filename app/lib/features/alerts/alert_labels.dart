import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'alert_settings.dart';

extension AlertLabels on AppLocalizations {
  String alertModeName(AlertMode m) => switch (m) {
    AlertMode.adhan => soundAdhan,
    AlertMode.notification => soundAlert,
    AlertMode.silent => soundSilent,
    AlertMode.off => soundOff,
  };
}

/// The prototype's icons: volume for adhan, bell for alert, bell-off.
IconData alertModeIcon(AlertMode m) => switch (m) {
  AlertMode.adhan => Icons.volume_up_outlined,
  AlertMode.notification => Icons.notifications_none,
  AlertMode.silent || AlertMode.off => Icons.notifications_off_outlined,
};
