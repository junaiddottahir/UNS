import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/settings_store.dart';
import 'city.dart';
import 'city_repository.dart';
import 'device_locator.dart';

final cityRepositoryProvider = FutureProvider<CityRepository>(
  (ref) => CityRepository.load(rootBundle),
);

final deviceLocatorProvider = Provider<DeviceLocator>(
  (ref) => const GeolocatorDeviceLocator(),
);

/// The location prayer times and qibla use. Saved on the device only.
final userLocationProvider =
    NotifierProvider<UserLocationNotifier, UserLocation?>(
      UserLocationNotifier.new,
    );

class UserLocationNotifier extends Notifier<UserLocation?> {
  @override
  UserLocation? build() {
    final json = ref.read(settingsStoreProvider).readJson(SettingKeys.location);
    return json == null ? null : UserLocation.fromJson(json);
  }

  void set(UserLocation location) {
    state = location;
    ref
        .read(settingsStoreProvider)
        .writeJson(SettingKeys.location, location.toJson());
  }

  /// Asks the phone where it is and, if found, uses that position labelled
  /// with the nearest city.
  Future<DeviceLocationResult> useDevice() async {
    final result = await ref.read(deviceLocatorProvider).locate();
    if (result is DeviceLocationFound) {
      final cities = await ref.read(cityRepositoryProvider.future);
      set(
        UserLocation(
          city: cities.nearest(result.latitude, result.longitude),
          latitude: result.latitude,
          longitude: result.longitude,
          source: LocationSource.device,
        ),
      );
    }
    return result;
  }
}
