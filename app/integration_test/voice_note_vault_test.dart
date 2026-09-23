import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uns/core/storage/database_key.dart';
import 'package:uns/core/storage/voice_note_vault.dart';
import 'package:uns/features/journal/voice_note.dart';

/// Real Keychain key, real AES-GCM file, real playback from memory. A
/// short recitation stands in for a recording (needs a network):
///   flutter test integration_test/voice_note_vault_test.dart -d SIMULATOR_ID
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a note is encrypted on disk and plays from memory', (
    tester,
  ) async {
    final audio = (await http.get(
      Uri.parse('https://everyayah.com/data/Alafasy_128kbps/001001.mp3'),
    )).bodyBytes;
    expect(audio.length, greaterThan(10000));
    final tmp = await getTemporaryDirectory();
    final recording = File('${tmp.path}/rec.mp3')..writeAsBytesSync(audio);

    final vault = VoiceNoteVault(
      SecureDatabaseKeyStore.voiceNotes,
      getApplicationSupportDirectory,
    );
    await vault.store(recording, name: 'device_check.enc');
    expect(recording.existsSync(), isFalse);

    final support = await getApplicationSupportDirectory();
    final stored = File('${support.path}/voice_notes/device_check.enc');
    expect(stored.existsSync(), isTrue);
    expect(
      stored.readAsBytesSync().sublist(0, 64),
      isNot(audio.sublist(0, 64)),
    );

    final back = await vault.open('device_check.enc');
    expect(back, audio);

    final player = JustAudioNotePlayer();
    final playing = player.play(back);
    await Future<void>.delayed(const Duration(seconds: 2));
    await player.stop();
    await playing;
    await player.dispose();
    await vault.delete('device_check.enc');
  });
}
