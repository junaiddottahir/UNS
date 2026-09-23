import '../../l10n/app_localizations.dart';
import 'reciter.dart';

extension ReciterLabels on AppLocalizations {
  String reciterName(Reciter r) => switch (r) {
    Reciter.alafasy => reciterAlafasy,
    Reciter.abdulBasit => reciterAbdulBasit,
    Reciter.sudais => reciterSudais,
  };
}
