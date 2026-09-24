import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/database_key.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/prayer/prayer_settings.dart';

import '../../support/test_app.dart';

class _MemoryKeyStore implements DatabaseKeyStore {
  String? key;

  @override
  Future<String?> read() async => key;

  @override
  Future<void> write(String hexKey) async => key = hexKey;
}

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('uns_db_test');
    file = File('${dir.path}/${AppDatabase.fileName}');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<SettingsStore> openStore(DatabaseKeyStore keys) async =>
      SettingsStore.load(await AppDatabase.open(keys: keys, directory: dir));

  Future<void> writeSydney(DatabaseKeyStore keys) async {
    final db = await AppDatabase.open(keys: keys, directory: dir);
    final store = await SettingsStore.load(db);
    store.writeJson(
      SettingKeys.location,
      UserLocation.fromCity(sydney).toJson(),
    );
    await store.flush();
    await db.close();
  }

  test('creates a key and keeps settings across restarts', () async {
    final keys = _MemoryKeyStore();
    await writeSydney(keys);
    expect(keys.key, matches(RegExp(r'^[0-9a-f]{64}$')));

    final reopened = await openStore(keys);
    final json = reopened.readJson(SettingKeys.location)!;
    expect(UserLocation.fromJson(json)!.city.name, 'Sydney');
  });

  test('the file on disk is encrypted', () async {
    await writeSydney(_MemoryKeyStore());
    final bytes = file.readAsBytesSync();
    expect(latin1.decode(bytes.sublist(0, 15)), isNot('SQLite format 3'));
    expect(latin1.decode(bytes).contains('Sydney'), isFalse);
  });

  test('the wrong key cannot open it', () async {
    final keys = _MemoryKeyStore();
    await writeSydney(keys);
    expect(AppDatabase.canOpen(file, keys.key!), isTrue);
    expect(AppDatabase.canOpen(file, generateHexKey()), isFalse);
  });

  test('a lost key starts a fresh database instead of failing', () async {
    await writeSydney(_MemoryKeyStore());
    final store = await openStore(_MemoryKeyStore());
    expect(store.readJson(SettingKeys.location), isNull);
  });

  test('a replaced key starts a fresh database', () async {
    final keys = _MemoryKeyStore();
    await writeSydney(keys);
    keys.key = generateHexKey();
    final store = await openStore(keys);
    expect(store.readJson(SettingKeys.location), isNull);
  });

  group('stored values', () {
    test('location round-trips', () {
      const location = UserLocation(
        city: makkah,
        latitude: 21.42,
        longitude: 39.82,
        source: LocationSource.device,
      );
      final back = UserLocation.fromJson(
        jsonDecode(jsonEncode(location.toJson())) as Map<String, Object?>,
      )!;
      expect(back.city.name, 'Makkah');
      expect(back.city.timeZone, 'Asia/Riyadh');
      expect((back.latitude, back.longitude), (21.42, 39.82));
      expect(back.source, LocationSource.device);
    });

    test('a malformed location is ignored', () {
      expect(UserLocation.fromJson({'city': 'Sydney'}), isNull);
    });

    test('prayer settings round-trip; unknown values use defaults', () {
      const settings = PrayerSettings(
        method: PrayerMethod.karachi,
        asr: AsrMethod.hanafi,
      );
      final back = PrayerSettings.fromJson(settings.toJson());
      expect(back.method, PrayerMethod.karachi);
      expect(back.asr, AsrMethod.hanafi);

      final odd = PrayerSettings.fromJson({'method': 'nope', 'asr': 3});
      expect(odd.method, isNull);
      expect(odd.asr, AsrMethod.standard);
    });
  });
}
