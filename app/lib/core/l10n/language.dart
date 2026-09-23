import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../storage/settings_store.dart';

/// The app's language. [system] follows the phone.
enum AppLanguage {
  system(null),
  en(Locale('en')),
  ar(Locale('ar'));

  const AppLanguage(this.locale);

  /// Null means use the phone's language.
  final Locale? locale;
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(
  LanguageNotifier.new,
);

/// Stored as {"id": "system" | "en" | "ar"}; missing means follow the
/// phone. Only en and ar sync to an account.
class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    final json = ref.read(settingsStoreProvider).readJson(SettingKeys.language);
    return AppLanguage.values.asNameMap()[json?['id']] ?? AppLanguage.system;
  }

  void set(AppLanguage language) {
    state = language;
    ref.read(settingsStoreProvider).writeJson(SettingKeys.language, {
      'id': language.name,
    });
  }
}

/// Arabic shows Western digits (0-9) everywhere, as intl's default of
/// Arabic-Indic digits for dates would mix with counts and durations.
/// Call once at startup.
void useWesternDigits() => DateFormat.useNativeDigitsByDefaultFor('ar', false);

/// The list comma for [locale]: Arabic uses "،".
String listComma(String locale) => locale.startsWith('ar') ? '،' : ',';
