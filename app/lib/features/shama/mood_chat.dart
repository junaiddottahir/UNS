import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran/quran_providers.dart';
import '../../core/safety/safety_check.dart';
import '../library/verse_library.dart';
import 'classify_client.dart';

sealed class ChatMessage {
  const ChatMessage();
}

/// What the user wrote (shown as a bubble; never saved).
class UserMessage extends ChatMessage {
  const UserMessage(this.text);
  final String text;
}

/// The app's reply, localised when shown.
enum Reply { feeling, tellMore, unavailable }

class AppMessage extends ChatMessage {
  const AppMessage(this.reply, [this.emotion]);
  final Reply reply;
  final Emotion? emotion;
}

class MoodChat {
  const MoodChat({
    this.messages = const [],
    this.pending,
    this.thinking = false,
  });

  final List<ChatMessage> messages;

  /// A feeling awaiting "Yes" / "Something else".
  final Emotion? pending;

  /// Waiting for the classifier.
  final bool thinking;
}

/// What the screen should do after a message.
enum SendOutcome { replied, showSupport }

final classifyClientProvider = Provider<ClassifyClient>(
  (ref) => ClassifyClient(ref.watch(httpClientProvider)),
);

/// The Shama chat. Held in memory only: mood text is never stored, and the
/// chat clears once a session is saved.
final moodChatProvider = NotifierProvider<MoodChatNotifier, MoodChat>(
  MoodChatNotifier.new,
);

class MoodChatNotifier extends Notifier<MoodChat> {
  @override
  MoodChat build() => const MoodChat();

  /// Safety check on the phone first; any risk (here or from the backend)
  /// clears the chat and shows support instead of a session.
  Future<SendOutcome> send(String input) async {
    final text = input.trim();
    if (text.isEmpty || state.thinking) return SendOutcome.replied;

    final safety = await ref.read(safetyCheckProvider.future);
    if (safety.isRisky(text)) {
      state = const MoodChat();
      return SendOutcome.showSupport;
    }

    state = MoodChat(
      messages: [...state.messages, UserMessage(text)],
      thinking: true,
    );
    try {
      final reading = await ref.read(classifyClientProvider).classify(text);
      if (reading.risk) {
        state = const MoodChat();
        return SendOutcome.showSupport;
      }
      final emotion = reading.emotion;
      _reply(
        emotion == null
            ? const AppMessage(Reply.tellMore)
            : AppMessage(Reply.feeling, emotion),
        pending: emotion,
      );
    } on ClassifyUnavailable {
      _reply(const AppMessage(Reply.unavailable));
    }
    return SendOutcome.replied;
  }

  /// "Something else": ask for more, chips stay available.
  void notQuite() => _reply(const AppMessage(Reply.tellMore));

  /// Clears the chat (after a session is saved, or a chip is used).
  void reset() => state = const MoodChat();

  void _reply(AppMessage message, {Emotion? pending}) {
    state = MoodChat(messages: [...state.messages, message], pending: pending);
  }
}
