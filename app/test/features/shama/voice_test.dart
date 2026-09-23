import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/router/app_router.dart';
import 'package:uns/core/router/routes.dart';
import 'package:uns/features/library/verse_library.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/shama/classify_client.dart';
import 'package:uns/features/shama/voice_input.dart';

import '../../support/test_app.dart';

Future<ProviderContainer> _open(
  WidgetTester tester, {
  required FakeVoiceInput voice,
  FakeClassify? classify,
  String route = Routes.shama,
}) async {
  final container = await pumpApp(tester, voice: voice, classify: classify);
  container
      .read(userLocationProvider.notifier)
      .set(UserLocation.fromCity(sydney));
  container.read(appRouterProvider).go(route);
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('speak → words shown → finish → in the box, not yet sent', (
    tester,
  ) async {
    final voice = FakeVoiceInput(supported: true);
    final classify = FakeClassify({
      'I feel lonely today': const MoodReading(
        emotion: Emotion.loneliness,
        risk: false,
      ),
    });
    await _open(tester, voice: voice, classify: classify);

    await tester.tap(find.bySemanticsLabel('Speak instead of typing'));
    await tester.pumpAndSettle();
    expect(find.text('LISTENING'), findsOneWidget);
    expect(find.text("Speak naturally. I'll listen."), findsOneWidget);
    expect(voice.starts, 1);

    voice.say('I feel lonely today');
    await tester.pump();
    expect(find.text('I feel lonely today'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Finish'));
    await tester.pumpAndSettle();
    expect(voice.stops, 1);
    // Back on Shama with the transcript to check; nothing sent yet.
    expect(find.widgetWithText(TextField, 'I feel lonely today'), findsOne);
    expect(classify.sent, isEmpty);

    await tester.tap(find.bySemanticsLabel('Send'));
    await tester.pumpAndSettle();
    expect(classify.sent, ['I feel lonely today']);
    expect(find.text("It sounds like you're feeling lonely."), findsOneWidget);
  });

  testWidgets('closing discards what was heard', (tester) async {
    final voice = FakeVoiceInput(supported: true);
    await _open(tester, voice: voice);
    await tester.tap(find.bySemanticsLabel('Speak instead of typing'));
    await tester.pumpAndSettle();
    voice.say('never mind');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(voice.cancels, 1);
    expect(find.widgetWithText(TextField, 'never mind'), findsNothing);
  });

  testWidgets('no permission: explains and links to Settings', (tester) async {
    final voice = FakeVoiceInput(
      supported: true,
      problem: VoiceProblem.noPermission,
    );
    await _open(tester, voice: voice);
    await tester.tap(find.bySemanticsLabel('Speak instead of typing'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Allow the microphone'), findsOneWidget);
    expect(find.text('Open Settings'), findsOneWidget);
  });

  testWidgets('unsupported: explains, and the mic is gone after', (
    tester,
  ) async {
    final voice = FakeVoiceInput(
      supported: true,
      problem: VoiceProblem.unsupported,
    );
    await _open(tester, voice: voice);
    await tester.tap(find.bySemanticsLabel('Speak instead of typing'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Voice isn't available"), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Speak instead of typing'), findsNothing);
  });

  testWidgets('no voice on this platform: no mic anywhere', (tester) async {
    await _open(tester, voice: FakeVoiceInput(supported: false));
    expect(find.bySemanticsLabel('Speak instead of typing'), findsNothing);
  });

  testWidgets('home voice button opens Shama listening', (tester) async {
    final voice = FakeVoiceInput(supported: true);
    await _open(tester, voice: voice, route: Routes.home);
    await tester.tap(find.bySemanticsLabel('Tell us how you feel'));
    await tester.pumpAndSettle();
    expect(find.text('LISTENING'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('How are you feeling?'), findsOneWidget);
  });
}
