import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../alerts/alert_providers.dart';
import '../location/location_providers.dart';
import 'compass_source.dart';
import 'qibla.dart';

final compassSourceProvider = Provider<CompassSource>(
  (ref) => const DeviceCompassSource(),
);

/// Qibla bearing for the chosen location, or null before one is chosen.
final qiblaBearingProvider = Provider<double?>((ref) {
  final location = ref.watch(userLocationProvider);
  return location == null
      ? null
      : qiblaBearing(location.latitude, location.longitude);
});

/// Live compass while the qibla screen is open.
final compassProvider = StreamProvider.autoDispose<CompassState>((ref) {
  // Restart after returning from Settings, where location may be allowed.
  ref.watch(permissionCheckProvider);
  final location = ref.watch(userLocationProvider);
  if (location == null) return Stream.value(const CompassUnavailable());
  return ref
      .watch(compassSourceProvider)
      .watch(location.latitude, location.longitude);
});
