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
    bool replay = false,
  }) => _db
      .into(_db.sessions)
      .insert(
        SessionsCompanion.insert(
          startedAt: at,
          emotion: emotion.name,
          help: comfort ? 'comfort' : 'remind',
          minutes: minutes,
          isReplay: Value(replay),
        ),
      );

  /// New (not replayed) sessions started since [since], live.
  Stream<int> watchStartedSince(DateTime since) {
    final count = _db.sessions.id.count();
    return (_db.selectOnly(_db.sessions)
          ..addColumns([count])
          ..where(
            _db.sessions.startedAt.isBiggerOrEqualValue(since) &
                _db.sessions.isReplay.equals(false),
          ))
        .map((r) => r.read(count) ?? 0)
        .watchSingle();
  }

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

  /// Replaces an entry's written reflection; null removes it.
  Future<void> updateReflection(int id, String? reflection) =>
      (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
        SessionsCompanion(reflection: Value(reflection)),
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
