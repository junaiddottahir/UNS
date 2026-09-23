import 'package:drift/drift.dart';

import '../../core/storage/app_database.dart';

/// One day's total.
class DailyTotal {
  const DailyTotal(this.date, this.count);

  /// Local calendar date (time is midnight).
  final DateTime date;
  final int count;
}

/// Daily dhikr totals in the encrypted database.
class TasbihStore {
  TasbihStore(this._db);

  final AppDatabase _db;

  static String keyFor(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static DateTime dateOf(String key) => DateTime.parse(key);

  /// Adds one to [date]'s total. A typed upsert, so live queries (today's
  /// total, history) hear about it.
  Future<void> increment(DateTime date) => _db
      .into(_db.tasbihDays)
      .insert(
        TasbihDaysCompanion.insert(day: keyFor(date), count: 1),
        onConflict: DoUpdate(
          (old) =>
              TasbihDaysCompanion.custom(count: old.count + const Constant(1)),
        ),
      );

  Stream<int> watchDay(DateTime date) =>
      (_db.select(_db.tasbihDays)..where((t) => t.day.equals(keyFor(date))))
          .watchSingleOrNull()
          .map((row) => row?.count ?? 0);

  /// The most recent days with any count, newest first.
  Stream<List<DailyTotal>> watchRecent({int limit = 30}) =>
      (_db.select(_db.tasbihDays)
            ..where((t) => t.count.isBiggerThanValue(0))
            ..orderBy([(t) => OrderingTerm.desc(t.day)])
            ..limit(limit))
          .watch()
          .map(
            (rows) => [
              for (final r in rows) DailyTotal(dateOf(r.day), r.count),
            ],
          );
}
