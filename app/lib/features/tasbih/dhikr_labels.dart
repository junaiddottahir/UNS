import '../../l10n/app_localizations.dart';
import 'dhikr.dart';

extension DhikrLabels on AppLocalizations {
  String dhikrName(Dhikr d) => switch (d) {
    Dhikr.subhanAllah => dhikrSubhanAllah,
    Dhikr.alhamdulillah => dhikrAlhamdulillah,
    Dhikr.allahuAkbar => dhikrAllahuAkbar,
  };
}
