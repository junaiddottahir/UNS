import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'city.dart';
import 'city_repository.dart';
import 'device_locator.dart';

final cityRepositoryProvider = FutureProvider<CityRepository>(
  (ref) => CityRepository.load(rootBundle),
);

final deviceLocatorProvider = Provider<DeviceLocator>(
  (ref) => const GeolocatorDeviceLocator(),
);

/// The location chosen in onboarding. Held in memory until the local
/// database lands (unit 3).
final userLocationProvider =
    NotifierProvider<UserLocationNotifier, UserLocation?>(
      UserLocationNotifier.new,
    );

class UserLocationNotifier extends Notifier<UserLocation?> {
  @override
  UserLocation? build() => null;

  void set(UserLocation location) => state = location;
}
