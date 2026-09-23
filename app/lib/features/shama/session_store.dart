import 'package:drift/drift.dart';

import '../../core/quran/verse_ref.dart';
import '../../core/storage/app_database.dart';
import '../library/verse_library.dart';

/// Saves Shama sessions in the encrypted database.
class SessionStore {
  SessionStore(this._db);

  final AppDatabase _db;

  Future<int> start({
    required DateTime at,
    required Emotion emotion,
    required bool comfort,
    required int minutes,
  }) => _db
      .into(_db.sessions)
      .insert(
        SessionsCompanion.insert(
          startedAt: at,
          emotion: emotion.name,
          help: comfort ? 'comfort' : 'remind',
          minutes: minutes,
        ),
      );

  Future<void> recordVerses(int id, List<VerseRef> played) =>
      (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
        SessionsCompanion(verses: Value(played.join(','))),
      );

  Future<void> finish(int id, {required DateTime at, String? moodAfter}) =>
      (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
        SessionsCompanion(endedAt: Value(at), moodAfter: Value(moodAfter)),
      );

  Future<Session?> byId(int id) => (_db.select(
    _db.sessions,
  )..where((s) => s.id.equals(id))).getSingleOrNull();
}
