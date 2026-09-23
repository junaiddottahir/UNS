import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/safety/safety_check.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SafetyCheck check;
  setUpAll(() async => check = await SafetyCheck.load(rootBundle));

  group('flags the prototype phrases, however they are written', () {
    for (final text in [
      'I want to kill myself',
      "I'm having suicidal thoughts",
      'thinking about SUICIDE',
      'I just want to end my life.',
      'sometimes I want to end it all',
      'I hurt myself again',
      'self-harm',
      'Self harm',
      'selfharm',
      'I want to die',
      "I don't want to live anymore",
      'I don’t want to live', // curly apostrophe
      'i dont want to live',
    ]) {
      test(text, () => expect(check.isRisky(text), isTrue));
    }
  });

  group('does not flag everyday language', () {
    for (final text in [
      'I want to diet this month',
      'I killed it at work today',
      'this deadline is killing me',
      "I'm tired and anxious",
      'Work has been overwhelming lately and I can\'t switch off at night',
      'I hurt my knee',
      '',
    ]) {
      test(text.isEmpty ? '(empty)' : text, () {
        expect(check.isRisky(text), isFalse);
      });
    }
  });

  group('Arabic (draft list): with or without diacritics', () {
    for (final text in [
      'أريد أن أموت',
      'أُرِيدُ أَنْ أَمُوتَ',
      'أفكر في الانتحار',
      'بدي انتحر',
      'لا أريد أن أعيش',
    ]) {
      test(text, () => expect(check.isRisky(text), isTrue));
    }
    test('ordinary Arabic is not flagged', () {
      expect(check.isRisky('أنا متعب قليلاً اليوم'), isFalse);
    });
  });

  test('normalising', () {
    expect(normalizeForSafety("  Don't   STOP—now! "), 'dont stop now');
    expect(normalizeForSafety('أَمُوتَ'), 'اموت');
    expect(normalizeForSafety('مدرسة'), 'مدرسه');
  });
}
