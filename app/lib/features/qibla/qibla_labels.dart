import '../../l10n/app_localizations.dart';
import 'qibla.dart';

extension QiblaLabels on AppLocalizations {
  String compassPointName(CompassPoint p) => switch (p) {
    CompassPoint.n => compassN,
    CompassPoint.ne => compassNE,
    CompassPoint.e => compassE,
    CompassPoint.se => compassSE,
    CompassPoint.s => compassS,
    CompassPoint.sw => compassSW,
    CompassPoint.w => compassW,
    CompassPoint.nw => compassNW,
  };

  String guidanceText(QiblaGuidance g) => switch (g) {
    QiblaGuidance.facing => facingQibla,
    QiblaGuidance.slightlyLeft => turnSlightlyLeft,
    QiblaGuidance.slightlyRight => turnSlightlyRight,
    QiblaGuidance.left => turnLeft,
    QiblaGuidance.right => turnRight,
  };

  String accuracyName(HeadingAccuracy a) => switch (a) {
    HeadingAccuracy.high => accuracyHigh,
    HeadingAccuracy.medium => accuracyMedium,
    HeadingAccuracy.low => accuracyLow,
    HeadingAccuracy.unknown => accuracyUnknown,
  };
}
