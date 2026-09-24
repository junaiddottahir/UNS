import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/features/library/verse_library.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/shama/classify_client.dart';
import 'package:uns/features/shama/mood_chat.dart';

import '../../support/test_app.dart';

const _worried = "I can't stop worrying about exams";

Future<ProviderContainer> _openShama(
  WidgetTester tester,
  FakeClassify classify,
) async {
  final container = await pumpApp(tester, classify: classify);
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  container.read(appRouterProvider).go(Routes.shama);
  await tester.pumpAndSettle();
  return container;
}

Future<void> _say(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.bySemanticsLabel('Send'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('typed feeling → "It sounds like…" → Yes → session steps', (
    tester,
  ) async {
    final classify = FakeClassify({
      _worried: const MoodReading(emotion: Emotion.anxiety, risk: false),
    });
    await _openShama(tester, classify);
    expect(find.text('Tell me in your words…'), findsOneWidget);

    await _say(tester, _worried);
    expect(classify.sent, [_worried]);
    expect(find.text(_worried), findsOneWidget);
    expect(find.text("It sounds like you're feeling anxious."), findsOneWidget);
    // The greeting gives way to the conversation.
    expect(find.text('How are you feeling?'), findsNothing);
    // The reply sits below the user's words.
    expect(
      tester.getTopLeft(find.textContaining('It sounds like')).dy,
      greaterThan(tester.getTopLeft(find.text(_worried)).dy),
    );

    await tester.tap(find.text('YES'));
    await tester.pumpAndSettle();
    expect(find.text('FEELING ANXIOUS'), findsOneWidget);
  });

  testWidgets('"Something else" and unknown ask for more; chips remain', (
    tester,
  ) async {
    final classify = FakeClassify({
      _worried: const MoodReading(emotion: Emotion.anxiety, risk: false),
      'hmm': const MoodReading(emotion: null, risk: false),
    });
    await _openShama(tester, classify);
    await _say(tester, _worried);
    await tester.tap(find.text('SOMETHING ELSE'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tell me a little more, or pick a feeling below.'),
      findsOneWidget,
    );
    expect(find.text('ANXIOUS'), findsOneWidget);

    await _say(tester, 'hmm');
    expect(
      find.text('Tell me a little more, or pick a feeling below.'),
      findsNWidgets(2),
    );
  });

  testWidgets('risky words go to support without leaving the phone', (
    tester,
  ) async {
    final classify = FakeClassify();
    final container = await _openShama(tester, classify);
    await _say(tester, "I just don't want to live anymore");
    expect(find.text("You don't have to carry this alone"), findsOneWidget);
    expect(classify.sent, isEmpty);
    expect(container.read(moodChatProvider).messages, isEmpty);
  });

  testWidgets('risk flagged by the backend also shows support', (tester) async {
    final classify = FakeClassify({
      'everything is too much': const MoodReading(
        emotion: Emotion.sadness,
        risk: true,
      ),
    });
    await _openShama(tester, classify);
    await _say(tester, 'everything is too much');
    expect(find.text("You don't have to carry this alone"), findsOneWidget);
  });

  testWidgets('classifier unavailable: says so, chips still work', (
    tester,
  ) async {
    await _openShama(tester, FakeClassify());
    await _say(tester, 'tired');
    expect(find.textContaining("couldn't read that"), findsOneWidget);
    await tester.tap(find.text('SAD'));
    await tester.pumpAndSettle();
    expect(find.text('FEELING SAD'), findsOneWidget);
  });

  testWidgets('a second message right after a reply still works', (
    tester,
  ) async {
    final classify = FakeClassify();
    await _openShama(tester, classify);
    await _say(tester, 'Work has been a lot lately');
    expect(find.textContaining("couldn't read that"), findsOneWidget);
    // Focus is kept, so the next words go straight in.
    expect(
      tester.widget<TextField>(find.byType(TextField)).enabled,
      isNot(false),
    );
    await _say(tester, 'I want to end it all');
    expect(find.text("You don't have to carry this alone"), findsOneWidget);
  });
}
