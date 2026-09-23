import 'package:geolocator/geolocator.dart';

/// Result of asking the phone where it is.
sealed class DeviceLocationResult {
  const DeviceLocationResult();
}

class DeviceLocationFound extends DeviceLocationResult {
  const DeviceLocationFound(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class DeviceLocationDenied extends DeviceLocationResult {
  const DeviceLocationDenied({required this.permanently});

  /// True when the OS won't show the prompt again; only Settings can fix it.
  final bool permanently;
}

class DeviceLocationServiceOff extends DeviceLocationResult {
  const DeviceLocationServiceOff();
}

class DeviceLocationFailed extends DeviceLocationResult {
  const DeviceLocationFailed();
}

/// Reads the device position. An interface so tests can fake it.
abstract interface class DeviceLocator {
  Future<DeviceLocationResult> locate();
  Future<void> openSettings();
}

class GeolocatorDeviceLocator implements DeviceLocator {
  const GeolocatorDeviceLocator();

  @override
  Future<DeviceLocationResult> locate() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const DeviceLocationServiceOff();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        return const DeviceLocationDenied(permanently: false);
      case LocationPermission.deniedForever:
        return const DeviceLocationDenied(permanently: true);
      case LocationPermission.whileInUse:
      case LocationPermission.always:
      case LocationPermission.unableToDetermine:
        break;
    }

    try {
      // City-level accuracy is enough for prayer times and qibla.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return DeviceLocationFound(position.latitude, position.longitude);
    } on Exception {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return DeviceLocationFound(last.latitude, last.longitude);
      }
      return const DeviceLocationFailed();
    }
  }

  @override
  Future<void> openSettings() => Geolocator.openAppSettings();
}
