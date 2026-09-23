import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/settings_store.dart';

/// Reciters offered in the prototype. Audio comes from UmmahAPI (unit 8).
enum Reciter { alafasy, abdulBasit, sudais }

/// The chosen reciter, saved on the device. Default: Mishary Alafasy.
final reciterProvider = NotifierProvider<ReciterNotifier, Reciter>(
  ReciterNotifier.new,
);

class ReciterNotifier extends Notifier<Reciter> {
  @override
  Reciter build() {
    final json = ref.read(settingsStoreProvider).readJson(SettingKeys.reciter);
    return Reciter.values.asNameMap()[json?['id']] ?? Reciter.alafasy;
  }

  void set(Reciter reciter) {
    state = reciter;
    ref.read(settingsStoreProvider).writeJson(SettingKeys.reciter, {
      'id': reciter.name,
    });
  }
}
