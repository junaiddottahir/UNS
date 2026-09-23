import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Shown when the sun doesn't rise or set at the location today, so the
/// times can't be calculated.
class PrayerTimesUnavailable extends StatelessWidget {
  const PrayerTimesUnavailable({super.key, required this.place});

  final String place;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).prayerTimesUnavailable(place),
      style: AppText.body,
    );
  }
}
