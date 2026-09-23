import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran/recitation_client.dart';
import '../../core/storage/settings_store.dart';

/// Reciters offered in the prototype, with their UmmahAPI entries.
enum Reciter {
  alafasy(ReciterSource(id: 1, nameContains: 'Alafasy')),
  abdulBasit(ReciterSource(id: 3, nameContains: 'Abdul Basit')),
  sudais(ReciterSource(id: 2, nameContains: 'Sudais'));

  const Reciter(this.source);

  final ReciterSource source;
}

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
