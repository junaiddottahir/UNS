import 'dart:async';
import 'dart:io';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geomag/geomag.dart';

import 'qibla.dart';

/// What the compass can tell us right now.
sealed class CompassState {
  const CompassState();
}

/// Heading in degrees from true north.
class CompassReading extends CompassState {
  const CompassReading(this.heading, this.accuracy);
  final double heading;
  final HeadingAccuracy accuracy;
}

/// This phone has no compass (or it isn't responding).
class CompassUnavailable extends CompassState {
  const CompassUnavailable();
}

/// iOS gives true north only with location access.
class CompassNeedsLocation extends CompassState {
  const CompassNeedsLocation({required this.permanently});
  final bool permanently;
}

/// The phone's compass. An interface so tests can fake it.
abstract interface class CompassSource {
  /// Headings for a phone at [latitude], [longitude] (used to correct
  /// magnetic north to true north).
  Stream<CompassState> watch(double latitude, double longitude);

  /// Asks for location access (iOS true north), or opens Settings.
  Future<void> allowLocation({required bool openSettings});
}

class DeviceCompassSource implements CompassSource {
  const DeviceCompassSource();

  /// No reading this long after starting means no usable compass (e.g.
  /// the iOS simulator).
  static const _noSensorAfter = Duration(seconds: 3);

  @override
  Stream<CompassState> watch(double latitude, double longitude) async* {
    if (Platform.isIOS) {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        yield CompassNeedsLocation(
          permanently: permission == LocationPermission.deniedForever,
        );
        return;
      }
    }
    final events = FlutterCompass.events;
    if (events == null) {
      yield const CompassUnavailable();
      return;
    }
    // Android reports magnetic north; correct it with the World Magnetic
    // Model at the user's position. iOS already reports true north.
    final declination = Platform.isAndroid
        ? GeoMag().calculate(latitude, longitude).dec
        : 0.0;

    yield* untilFirst(
      events.map<CompassState>((e) {
        final heading = e.heading;
        if (heading == null || heading < 0) return const CompassUnavailable();
        return CompassReading(
          (heading + declination) % 360,
          accuracyFor(e.accuracy),
        );
      }),
      _noSensorAfter,
    );
  }

  @override
  Future<void> allowLocation({required bool openSettings}) async {
    if (openSettings) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.requestPermission();
    }
  }
}

/// Passes [readings] through, adding [CompassUnavailable] if the first
/// one takes longer than [wait]. Later gaps are normal: headings only
/// arrive when the phone turns.
Stream<CompassState> untilFirst(Stream<CompassState> readings, Duration wait) {
  late final StreamController<CompassState> out;
  StreamSubscription<CompassState>? sub;
  Timer? timer;
  out = StreamController<CompassState>(
    onListen: () {
      timer = Timer(wait, () => out.add(const CompassUnavailable()));
      sub = readings.listen(
        (r) {
          timer?.cancel();
          out.add(r);
        },
        onError: out.addError,
        onDone: out.close,
      );
    },
    onCancel: () {
      timer?.cancel();
      return sub?.cancel();
    },
  );
  return out.stream;
}
