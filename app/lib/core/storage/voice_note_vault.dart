import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'database_key.dart';

/// Voice-note reflections, encrypted at rest with AES-256-GCM under a key
/// kept in the Keychain / Android secure storage. Notes are only ever
/// decrypted into memory for playback, never back to disk, and never leave
/// the phone.
class VoiceNoteVault {
  VoiceNoteVault(this._keys, this._directory);

  final DatabaseKeyStore _keys;
  final Future<Directory> Function() _directory;
  final _cipher = AesGcm.with256bits();

  static const folder = 'voice_notes';

  Future<SecretKey> _key() async {
    var hex = await _keys.read();
    if (hex == null) {
      hex = generateHexKey();
      await _keys.write(hex);
    }
    return SecretKey([
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ]);
  }

  Future<File> _file(String name) async {
    final dir = await _directory();
    return File('${dir.path}/$folder/$name');
  }

  /// Encrypts [recording] into the vault, deletes the plain file, and
  /// returns the note's name.
  Future<String> store(File recording, {required String name}) async {
    final plain = await recording.readAsBytes();
    final box = await _cipher.encrypt(plain, secretKey: await _key());
    final file = await _file(name);
    await file.parent.create(recursive: true);
    // Write then rename, so a partial file never counts as a note.
    final partial = File('${file.path}.part');
    await partial.writeAsBytes(box.concatenation(), flush: true);
    await partial.rename(file.path);
    await recording.delete();
    return name;
  }

  /// The note's audio, decrypted in memory. Throws if it's missing or
  /// can't be decrypted (e.g. the key was lost).
  Future<Uint8List> open(String name) async {
    final bytes = await (await _file(name)).readAsBytes();
    final box = SecretBox.fromConcatenation(
      bytes,
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );
    return Uint8List.fromList(
      await _cipher.decrypt(box, secretKey: await _key()),
    );
  }

  Future<void> delete(String name) async {
    final file = await _file(name);
    if (file.existsSync()) await file.delete();
  }
}

final voiceNoteVaultProvider = Provider<VoiceNoteVault>(
  (ref) => VoiceNoteVault(
    SecureDatabaseKeyStore.voiceNotes,
    getApplicationSupportDirectory,
  ),
);
