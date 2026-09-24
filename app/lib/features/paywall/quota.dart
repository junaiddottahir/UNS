import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../prayer/prayer_providers.dart';
import '../shama/shama_session.dart';

/// Free Shama sessions per week (scope); Premium is unlimited.
const freeSessionsPerWeek = 6;

/// The week starts Monday 00:00 on the phone's clock.
DateTime weekStart(DateTime now) {
  final local = now.toLocal();
  final monday = DateTime(
    local.year,
    local.month,
    local.day - (local.weekday - 1),
  );
  return monday;
}

/// New sessions started this week (replays are free and not counted).
/// Kept on the phone, so reinstalling resets it (see progress-tracker.md).
final sessionsThisWeekProvider = StreamProvider<int>((ref) {
  final start = ref.watch(nowProvider.select(weekStart));
  return ref.watch(sessionStoreProvider).watchStartedSince(start);
});
