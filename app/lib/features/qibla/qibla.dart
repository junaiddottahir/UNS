import 'package:adhan/adhan.dart' as adhan;

/// Great-circle bearing from the location to the Kaaba, in degrees
/// clockwise from true north. Computed on the phone.
double qiblaBearing(double latitude, double longitude) =>
    adhan.Qibla(adhan.Coordinates(latitude, longitude)).direction;

/// How far to turn from [heading] to face [bearing], in (-180, 180].
/// Positive means turn right (clockwise).
double turnBy(double bearing, double heading) {
  final d = (bearing - heading) % 360;
  return d > 180 ? d - 360 : d;
}

/// What the status line tells the user.
enum QiblaGuidance { facing, slightlyLeft, slightlyRight, left, right }

/// Within this many degrees counts as facing the qibla.
const facingToleranceDegrees = 5.0;

QiblaGuidance guidanceFor(double turn) {
  if (turn.abs() <= facingToleranceDegrees) return QiblaGuidance.facing;
  final slight = turn.abs() <= 30;
  if (turn > 0) {
    return slight ? QiblaGuidance.slightlyRight : QiblaGuidance.right;
  }
  return slight ? QiblaGuidance.slightlyLeft : QiblaGuidance.left;
}

/// Eight-point compass direction for a bearing.
enum CompassPoint { n, ne, e, se, s, sw, w, nw }

CompassPoint compassPointFor(double bearing) =>
    CompassPoint.values[((bearing % 360) / 45).round() % 8];

/// How much to trust the heading.
enum HeadingAccuracy { high, medium, low, unknown }

/// From the platform's ± degrees (Android reports 15 / 30 / 45).
HeadingAccuracy accuracyFor(double? degrees) {
  if (degrees == null || degrees < 0) return HeadingAccuracy.unknown;
  if (degrees <= 15) return HeadingAccuracy.high;
  if (degrees <= 30) return HeadingAccuracy.medium;
  return HeadingAccuracy.low;
}
