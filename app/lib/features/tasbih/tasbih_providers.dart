import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_database.dart';
import '../prayer/prayer_providers.dart';
import 'dhikr.dart';
import 'tasbih_store.dart';

final tasbihStoreProvider = Provider<TasbihStore>(
  (ref) => TasbihStore(ref.watch(appDatabaseProvider)),
);

DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

/// Today's total, by the phone's calendar.
final todayTasbihProvider = StreamProvider<int>((ref) {
  final today = ref.watch(nowProvider.select(_dateOnly));
  return ref.watch(tasbihStoreProvider).watchDay(today);
});

final tasbihHistoryProvider = StreamProvider<List<DailyTotal>>(
  (ref) => ref.watch(tasbihStoreProvider).watchRecent(),
);

/// A counting session: one dhikr, or the after-prayer set in order.
class TasbihSession {
  const TasbihSession({required this.set, this.index = 0, this.count = 0});

  final List<Dhikr> set;
  final int index;
  final int count;

  Dhikr get dhikr => set[index];
  bool get isSet => set.length > 1;
  bool get atTarget => count >= dhikr.target;
  bool get isLast => index == set.length - 1;

  TasbihSession copyWith({int? index, int? count}) => TasbihSession(
    set: set,
    index: index ?? this.index,
    count: count ?? this.count,
  );
}

/// What a tap did, so the screen can react.
enum TapResult { counted, reachedTarget, ignored }

/// Pause at a target before moving on, so the user sees it complete.
const targetPause = Duration(milliseconds: 700);

final tasbihSessionProvider =
    NotifierProvider<TasbihSessionNotifier, TasbihSession?>(
      TasbihSessionNotifier.new,
    );

/// Kept for the app's lifetime, so leaving the counter doesn't lose the
/// count in progress.
class TasbihSessionNotifier extends Notifier<TasbihSession?> {
  @override
  TasbihSession? build() => null;

  void start(List<Dhikr> set) => state = TasbihSession(set: set);

  /// Counts one, with a light tap, or a vibration at the target. Taps past
  /// the target are ignored.
  TapResult tap() {
    final s = state;
    if (s == null || s.atTarget) return TapResult.ignored;
    state = s.copyWith(count: s.count + 1);
    unawaited(ref.read(tasbihStoreProvider).increment(ref.read(nowProvider)));
    if (state!.atTarget) {
      HapticFeedback.heavyImpact();
      HapticFeedback.vibrate();
      return TapResult.reachedTarget;
    }
    HapticFeedback.selectionClick();
    return TapResult.counted;
  }

  /// After a target: the next dhikr in the set. Returns false when the
  /// session is finished.
  bool advance() {
    final s = state;
    if (s == null || s.isLast) {
      state = null;
      return false;
    }
    state = s.copyWith(index: s.index + 1, count: 0);
    return true;
  }

  /// Starts the current dhikr over. Today's total keeps what was counted.
  void reset() => state = state?.copyWith(count: 0);
}
