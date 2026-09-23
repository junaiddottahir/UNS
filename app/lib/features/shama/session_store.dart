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

  Future<void> finish(
    int id, {
    required DateTime at,
    String? moodAfter,
    String? reflection,
    String? voiceNote,
    int? voiceSeconds,
  }) => (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
    SessionsCompanion(
      endedAt: Value(at),
      moodAfter: Value(moodAfter),
      reflection: Value(reflection),
      voiceNote: Value(voiceNote),
      voiceSeconds: Value(voiceSeconds),
    ),
  );

  /// Finished sessions, newest first: the journal.
  Stream<List<Session>> watchJournal() =>
      (_db.select(_db.sessions)
            ..where((s) => s.endedAt.isNotNull())
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
          .watch();

  Future<Session?> byId(int id) => (_db.select(
    _db.sessions,
  )..where((s) => s.id.equals(id))).getSingleOrNull();
}
