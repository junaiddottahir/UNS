import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the database encryption key. An interface so tests can fake it.
abstract interface class DatabaseKeyStore {
  /// The stored key as 64 hex characters, or null if none exists yet.
  Future<String?> read();
  Future<void> write(String hexKey);
}

/// Keeps the key in the iOS Keychain / Android Keystore-backed storage.
///
/// The key is tied to this device: it isn't included in backups, so a
/// database file restored elsewhere can't be opened.
class SecureDatabaseKeyStore implements DatabaseKeyStore {
  /// [name] picks the Keychain entry; each purpose has its own key.
  const SecureDatabaseKeyStore({this.name = 'uns.db.key'});

  /// The key for encrypted voice-note files.
  static const voiceNotes = SecureDatabaseKeyStore(name: 'uns.voice.key');

  final String name;
  static const _storage = FlutterSecureStorage(
    // Readable after first unlock, so later background work (scheduling
    // prayer notifications) can open the database.
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<String?> read() => _storage.read(key: name);

  @override
  Future<void> write(String hexKey) => _storage.write(key: name, value: hexKey);
}

/// A new random 256-bit key as hex.
String generateHexKey() {
  final random = Random.secure();
  return [
    for (var i = 0; i < 32; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}
