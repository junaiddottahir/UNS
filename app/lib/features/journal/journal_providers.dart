import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran/verse_ref.dart';
import '../../core/storage/app_database.dart';
import '../shama/shama_session.dart';

/// Finished sessions, newest first.
final journalProvider = StreamProvider<List<Session>>(
  (ref) => ref.watch(sessionStoreProvider).watchJournal(),
);

/// The verses a session played, parsed from `2:286,94:5`.
List<VerseRef> versesOf(Session s) => [
  for (final part in s.verses.split(',')) ?_parse(part),
];

VerseRef? _parse(String part) {
  final [surah, ayah] = [...part.split(':'), '', ''].take(2).toList();
  final (sn, an) = (int.tryParse(surah), int.tryParse(ayah));
  if (sn == null || an == null || !VerseRef.isValid(sn, an)) return null;
  return VerseRef(sn, an);
}
