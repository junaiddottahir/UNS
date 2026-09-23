import '../../l10n/app_localizations.dart';
import 'device_locator.dart';

/// What to tell the user when the device location couldn't be used.
String? locationProblemText(AppLocalizations l10n, DeviceLocationResult? r) =>
    switch (r) {
      DeviceLocationDenied(permanently: true) => l10n.locationDeniedForever,
      DeviceLocationDenied() => l10n.locationDenied,
      DeviceLocationServiceOff() => l10n.locationServiceOff,
      DeviceLocationFailed() => l10n.locationFailed,
      DeviceLocationFound() || null => null,
    };

/// Whether only the Settings app can fix the problem.
bool needsSettings(DeviceLocationResult? r) =>
    r is DeviceLocationDenied && r.permanently;
