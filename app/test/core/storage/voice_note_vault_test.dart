import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/storage/database_key.dart';
import 'package:uns/core/storage/voice_note_vault.dart';
import 'package:uns/features/journal/voice_note.dart';

class _Keys implements DatabaseKeyStore {
  String? key;
  @override
  Future<String?> read() async => key;
  @override
  Future<void> write(String hexKey) async => key = hexKey;
}

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('uns_vault'));
  tearDown(() => dir.deleteSync(recursive: true));

  File recording(List<int> bytes) =>
      File('${dir.path}/rec.m4a')..writeAsBytesSync(bytes);

  test('encrypts at rest, removes the plain file, decrypts exactly', () async {
    final audio = Uint8List.fromList(List.generate(5000, (i) => i % 251));
    final keys = _Keys();
    final vault = VoiceNoteVault(keys, () async => dir);
    final plain = recording(audio);

    await vault.store(plain, name: 'n1.enc');
    expect(plain.existsSync(), isFalse);
    final stored = File('${dir.path}/voice_notes/n1.enc').readAsBytesSync();
    expect(stored, isNot(audio));
    // No long run of the original bytes survives in the file.
    expect(
      String.fromCharCodes(stored)
          .contains(String.fromCharCodes(audio.sublist(100, 140))),
      isFalse,
    );
    expect(keys.key, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(await vault.open('n1.enc'), audio);
  });

  test('another key cannot open it', () async {
    final vault = VoiceNoteVault(_Keys(), () async => dir);
    await vault.store(recording([1, 2, 3, 4]), name: 'n2.enc');
    final stranger = VoiceNoteVault(_Keys(), () async => dir);
    await expectLater(stranger.open('n2.enc'), throwsA(anything));
  });

  test('delete removes the note', () async {
    final vault = VoiceNoteVault(_Keys(), () async => dir);
    await vault.store(recording([9]), name: 'n3.enc');
    await vault.delete('n3.enc');
    expect(File('${dir.path}/voice_notes/n3.enc').existsSync(), isFalse);
  });

  test('audio type sniffing', () {
    Uint8List b(List<int> x) =>
        Uint8List.fromList([...x, ...List.filled(20, 0)]);
    expect(audioTypeOf(b([0, 0, 0, 32, ...'ftyp'.codeUnits])), 'audio/mp4');
    expect(audioTypeOf(b('ID3'.codeUnits)), 'audio/mpeg');
    expect(audioTypeOf(b([0xFF, 0xFB])), 'audio/mpeg');
  });
}
