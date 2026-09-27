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

/// An answer the user tapped, shown as their bubble; localised when shown.
sealed class UserChoice extends ChatMessage {
  const UserChoice();
}

class FeelingChoice extends UserChoice {
  const FeelingChoice(this.emotion);
  final Emotion emotion;
}

/// "Yes" or "Something else" to "It sounds like you're feeling…".
class ConfirmChoice extends UserChoice {
  const ConfirmChoice({required this.yes});
  final bool yes;
}

/// "Comfort me" or "Remind me".
class HelpChoice extends UserChoice {
  const HelpChoice({required this.comfort});
  final bool comfort;
}

class LengthChoice extends UserChoice {
  const LengthChoice(this.minutes);
  final int minutes;
}

/// The app's reply, localised when shown. The wording is fixed; no AI
/// writes what the app says (architecture.md invariant 2).
enum Reply {
  /// "It sounds like you're feeling…"
  feeling,
  tellMore,
  unavailable,

  /// A short line for the feeling, e.g. "That sounds like a lot to hold."
  acknowledge,

  /// "What would help right now?"
  askHelp,

  /// "How much time do you have?"
  askLength,
}

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
    this.emotion,
    this.comfort,
  });

  final List<ChatMessage> messages;

  /// A feeling awaiting "Yes" / "Something else".
  final Emotion? pending;

  /// Waiting for the classifier.
  final bool thinking;

  /// The feeling agreed on; next "Comfort me" / "Remind me".
  final Emotion? emotion;

  /// Comfort (true) or a reminder (false); next the session length.
  final bool? comfort;

  /// What the conversation asks the user now.
  ChatStep get step => switch (this) {
    MoodChat(pending: _?) => ChatStep.confirm,
    MoodChat(emotion: _?, comfort: null) => ChatStep.help,
    MoodChat(emotion: _?, comfort: _?) => ChatStep.length,
    _ => ChatStep.feeling,
  };
}

enum ChatStep {
  /// Type, speak, or pick a feeling chip.
  feeling,

  /// "Yes" / "Something else".
  confirm,

  /// "Comfort me" / "Remind me".
  help,

  /// 5, 10, 15 or 30 minutes; picking one begins the session.
  length,
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

  /// "Yes": the feeling is agreed on.
  void confirm() {
    final emotion = state.pending;
    if (emotion == null) return;
    _agree(const ConfirmChoice(yes: true), emotion);
  }

  /// "Something else": ask for more, chips stay available.
  void notQuite() {
    state = MoodChat(
      messages: [
        ...state.messages,
        const ConfirmChoice(yes: false),
        const AppMessage(Reply.tellMore),
      ],
    );
  }

  /// A feeling chip: decided on the phone, nothing is sent.
  void chooseFeeling(Emotion emotion) =>
      _agree(FeelingChoice(emotion), emotion);

  void chooseHelp({required bool comfort}) {
    final emotion = state.emotion;
    if (emotion == null) return;
    state = MoodChat(
      messages: [
        ...state.messages,
        HelpChoice(comfort: comfort),
        const AppMessage(Reply.askLength),
      ],
      emotion: emotion,
      comfort: comfort,
    );
  }

  /// The length that begins the session, shown as the user's answer.
  void chooseLength(int minutes) {
    if (state.step != ChatStep.length) return;
    state = MoodChat(
      messages: [...state.messages, LengthChoice(minutes)],
      emotion: state.emotion,
      comfort: state.comfort,
    );
  }

  /// Clears the chat (after a session is saved).
  void reset() => state = const MoodChat();

  void _agree(UserChoice answer, Emotion emotion) {
    state = MoodChat(
      messages: [
        ...state.messages,
        answer,
        AppMessage(Reply.acknowledge, emotion),
        const AppMessage(Reply.askHelp),
      ],
      emotion: emotion,
    );
  }

  void _reply(AppMessage message, {Emotion? pending}) {
    state = MoodChat(messages: [...state.messages, message], pending: pending);
  }
}

/// Words from the voice screen waiting to fill the Shama text box, so the
/// user sees (and can edit) the transcript before sending it.
final moodDraftProvider = NotifierProvider<MoodDraft, String?>(MoodDraft.new);

class MoodDraft extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String words) => state = words.isEmpty ? null : words;

  /// Hands the words over once; the text box owns them from then on.
  String? take() {
    final words = state;
    state = null;
    return words;
  }
}
