import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:http/http.dart' show BaseClient, BaseRequest, StreamedResponse;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uns/core/duas/dua.dart';
import 'package:uns/core/duas/dua_repository.dart';
import 'package:uns/core/api/api_client.dart';
import 'package:uns/core/auth/auth_service.dart';
import 'package:uns/core/purchases/premium_store.dart';
import 'package:uns/core/quran/quran_providers.dart';
import 'package:uns/core/quran/quran_repository.dart';
import 'package:uns/core/quran/quran_text_client.dart';
import 'package:uns/core/quran/recitation_client.dart';
import 'package:uns/core/quran/verse_ref.dart';
import 'package:uns/core/safety/safety_check.dart';
import 'package:uns/core/storage/app_database.dart';
import 'package:uns/core/storage/database_key.dart';
import 'package:uns/core/storage/voice_note_vault.dart';
import 'package:uns/features/journal/voice_note.dart';
import 'package:uns/core/storage/settings_store.dart';
import 'package:uns/features/account/account_sync.dart';
import 'package:uns/features/alerts/alert_providers.dart';
import 'package:uns/features/alerts/notification_permission.dart';
import 'package:uns/features/location/city.dart';
import 'package:uns/features/location/city_repository.dart';
import 'package:uns/features/location/device_locator.dart';
import 'package:uns/features/location/location_providers.dart';
import 'package:uns/features/prayer/prayer_providers.dart';
import 'package:uns/features/qibla/compass_source.dart';
import 'package:uns/features/qibla/qibla_providers.dart';
import 'package:uns/features/library/verse_library.dart';
import 'package:uns/features/reciter/reciter_sample.dart';
import 'package:uns/features/shama/classify_client.dart';
import 'package:uns/features/shama/mood_chat.dart';
import 'package:uns/features/shama/shama_session.dart';
import 'package:uns/features/shama/voice_input.dart';
import 'package:uns/features/shama/verse_player.dart';
import 'package:uns/features/support/support_screen.dart';
import 'package:uns/main.dart';

const sydney = City(
  name: 'Sydney',
  region: 'New South Wales',
  countryCode: 'AU',
  countryName: 'Australia',
  latitude: -33.8678,
  longitude: 151.2073,
  timeZone: 'Australia/Sydney',
  population: 5638830,
  searchKeys: ['sydney'],
);

const makkah = City(
  name: 'Makkah',
  region: 'Mecca Region',
  countryCode: 'SA',
  countryName: 'Saudi Arabia',
  latitude: 21.4266,
  longitude: 39.8256,
  timeZone: 'Asia/Riyadh',
  population: 1578722,
  searchKeys: ['makkah', 'la mecca', 'مكه'],
);

/// 03:00 UTC on 23 Sep 2026: 13:00 in Sydney, 06:00 in Makkah.
final testNow = DateTime.utc(2026, 9, 23, 3);

class FakeLocator implements DeviceLocator {
  FakeLocator(this.result);
  final DeviceLocationResult result;
  bool openedSettings = false;

  @override
  Future<DeviceLocationResult> locate() async => result;

  @override
  Future<void> openSettings() async => openedSettings = true;
}

/// A clock that never ticks, so tests can settle.
class FixedClock extends MinuteClock {
  FixedClock(this.now);
  final DateTime now;

  @override
  DateTime build() => now;
}

class FakeNotificationPermission implements NotificationPermission {
  FakeNotificationPermission({this.allow = true, this.granted = true});
  final bool allow;
  bool granted;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<bool> request() async {
    requests++;
    granted = allow;
    return allow;
  }

  @override
  Future<bool> isGranted() async => granted;

  @override
  Future<void> openSettings() async => settingsOpened++;
}

/// Records what would be scheduled with the OS.
class FakeAlertScheduler implements AlertScheduler {
  List<ScheduledNotification> pending = const [];

  @override
  Future<void> replaceAll(List<ScheduledNotification> notifications) async =>
      pending = notifications;
}

/// A compass the test drives by adding states.
class FakeCompass implements CompassSource {
  final states = StreamController<CompassState>.broadcast();
  int locationRequests = 0;

  @override
  Stream<CompassState> watch(double latitude, double longitude) =>
      states.stream;

  @override
  Future<void> allowLocation({required bool openSettings}) async =>
      locationRequests++;
}

/// Records what it was asked to play; playback "ends" when [finish] runs.
class FakeSamplePlayer implements SamplePlayer {
  final played = <String>[];
  int stops = 0;
  Completer<void>? _playing;

  @override
  Future<void> play(File file) {
    played.add(file.path);
    return (_playing = Completer<void>()).future;
  }

  void finish() => _playing?.complete();

  @override
  Future<void> stop() async {
    stops++;
    if (!(_playing?.isCompleted ?? true)) _playing!.complete();
  }

  @override
  Future<void> dispose() async {}
}

/// Hands back a fake file per reciter, or fails when [offline].
/// A dua made up for tests (not real text).
Dua testDua(int id, {String category = 'distress', int repeat = 1}) => Dua(
  id: id,
  category: category,
  title: 'Dua $id',
  arabic: 'arabic dua $id',
  transliteration: 'transliteration $id',
  translation: 'translation of dua $id',
  source: 'Source $id',
  repeat: repeat,
);

/// The dua collection, in memory; [offline] throws as with no copy.
class FakeDuas implements DuaRepository {
  FakeDuas([this.duas = const [], this.offline = false]);

  final List<Dua> duas;
  final bool offline;

  @override
  Future<List<Dua>> all() async {
    if (offline) throw const SocketException('offline');
    return duas;
  }
}

class FakeRecitations extends RecitationRepository {
  FakeRecitations({this.offline = false})
    : super(RecitationClient(_NoHttp()), _NoHttp(), () async => Directory(''));
  final bool offline;

  @override
  Future<File> audio(ReciterSource reciter, VerseRef ref) async {
    if (offline) throw Exception('offline');
    return File('/audio/${reciter.id}/${ref.paddedKey}.mp3');
  }
}

class _NoHttp extends BaseClient {
  @override
  Future<StreamedResponse> send(BaseRequest request) =>
      throw UnsupportedError('no network in tests');
}

/// A verse player the test steps through: [finishVerse] plays the loaded
/// verse to its end; [advance] moves the position.
class FakeVersePlayer implements VersePlayer {
  final _positions = StreamController<Duration>.broadcast();
  final _completions = StreamController<void>.broadcast();
  final opened = <String>[];
  bool playing = false;
  Duration verseLength = const Duration(seconds: 90);

  @override
  Future<Duration?> open(File file) async {
    opened.add(file.path);
    return verseLength;
  }

  @override
  void play() => playing = true;

  @override
  Future<void> pause() async => playing = false;

  @override
  Future<void> stop() async => playing = false;

  void advance(Duration to) => _positions.add(to);

  void finishVerse() {
    _positions.add(verseLength);
    _completions.add(null);
  }

  @override
  Stream<Duration> get positions => _positions.stream;

  @override
  Stream<void> get completions => _completions.stream;

  @override
  Future<void> dispose() async {}
}

/// Verse "text" for tests: labelled stand-ins, never real verse text.
class FakeQuran extends QuranRepository {
  FakeQuran({this.offlineRefs = const {}})
    : super(AppDatabase(NativeDatabase.memory()), QuranTextClient(_NoHttp()));

  /// Verses that fail as if offline and not cached.
  final Set<VerseRef> offlineRefs;

  @override
  Future<VerseText> verse(VerseRef ref) async {
    if (offlineRefs.contains(ref)) throw Exception('offline');
    return VerseText(
      ref: ref,
      arabic: 'arabic $ref',
      translation: 'translation $ref',
    );
  }
}

/// Classifier answers keyed by text; records what was sent.
class FakeClassify implements ClassifyClient {
  FakeClassify([this.answers = const {}]);
  final Map<String, MoodReading> answers;
  final sent = <String>[];

  @override
  String get baseUrl => 'http://fake';

  @override
  Future<MoodReading> classify(String text) async {
    sent.add(text);
    final answer = answers[text];
    if (answer == null) throw const ClassifyUnavailable();
    return answer;
  }
}

/// Voice input the test drives: [say] delivers words, [problem] makes
/// starting fail.
class FakeVoiceInput implements VoiceInput {
  FakeVoiceInput({this.supported = false, this.problem});

  @override
  final bool supported;
  final VoiceProblem? problem;
  VoiceListener? _listener;
  int starts = 0;
  int stops = 0;
  int cancels = 0;

  @override
  Future<VoiceProblem?> start(VoiceListener listener) async {
    starts++;
    _listener = listener;
    return problem;
  }

  void say(String words) {
    _listener?.onLevel(0.8);
    _listener?.onWords(words);
  }

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> cancel() async => cancels++;
}

/// A recorder that "records" fixed bytes; [allowed] is the mic permission.
class FakeVoiceRecorder implements VoiceRecorder {
  FakeVoiceRecorder({this.allowed = true});
  final bool allowed;
  final _levels = StreamController<double>.broadcast();
  int discards = 0;

  @override
  Future<bool> ensurePermission() async => allowed;

  @override
  Future<void> start() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<File?> stop() async => File('/tmp/fake-note.m4a');

  @override
  Future<void> discard() async => discards++;

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<void> dispose() async {}
}

/// Keeps "encrypted" notes in memory, keyed by name.
class FakeVault extends VoiceNoteVault {
  FakeVault() : super(_NoKeys(), () async => Directory(''));
  final notes = <String, Uint8List>{};

  @override
  Future<String> store(File recording, {required String name}) async {
    notes[name] = Uint8List.fromList([1, 2, 3]);
    return name;
  }

  @override
  Future<Uint8List> open(String name) async =>
      notes[name] ?? (throw Exception('missing'));
}

class _NoKeys implements DatabaseKeyStore {
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String hexKey) async {}
}

class FakeNotePlayer implements NotePlayer {
  final played = <Uint8List>[];

  @override
  Future<void> play(Uint8List audio) async => played.add(audio);

  @override
  Future<void> stop() async {}
}

/// Accounts in memory. [codes] is the 6-digit code "emailed" per address.
class FakeAuth implements AuthService {
  final _changes = StreamController<Account?>.broadcast();
  final users = <String, String>{}; // email → password
  final confirmed = <String>{};
  final resets = <String>[];
  Account? _current;
  String code = '123456';

  @override
  bool get available => true;
  @override
  Account? get current => _current;
  @override
  Stream<Account?> get changes => _changes.stream;
  @override
  Future<String?> accessToken() async => _current == null ? null : 'token';

  void _signInAs(String email) {
    _current = Account(id: 'id-$email', email: email, provider: 'email');
    _changes.add(_current);
  }

  @override
  Future<void> signUp(String email, String password) async {
    if (users.containsKey(email)) {
      throw const AuthFailure(AuthProblem.emailTaken);
    }
    users[email] = password;
  }

  @override
  Future<void> confirmSignUp(String email, String code) async {
    if (code != this.code) throw const AuthFailure(AuthProblem.wrongCode);
    confirmed.add(email);
    _signInAs(email);
  }

  @override
  Future<void> resendSignUpCode(String email) async {}

  @override
  Future<void> signIn(String email, String password) async {
    if (users[email] != password) {
      throw const AuthFailure(AuthProblem.wrongPassword);
    }
    _signInAs(email);
  }

  @override
  Future<void> sendPasswordReset(String email) async => resets.add(email);

  @override
  Future<void> confirmPasswordReset(String email, String code) async {
    if (code != this.code) throw const AuthFailure(AuthProblem.wrongCode);
    _signInAs(email);
  }

  @override
  Future<void> setNewPassword(String password) async =>
      users[_current!.email!] = password;

  @override
  Future<void> signOut() async {
    _current = null;
    _changes.add(null);
  }
}

/// The backend for one account, in memory: newest settings win, higher
/// tasbih count per day wins (same rules as the server).
class FakeAccountApi implements AccountApi {
  FakeAccountApi({this.fails = false});
  bool fails;
  final calls = <String>[];
  Map<String, Object?>? settings;
  DateTime? settingsAt;
  final tasbih = <String, int>{};

  Map<String, Object?> _settingsOut() => {
    'settings': settings,
    'updated_at': settingsAt?.toIso8601String(),
  };

  @override
  Future<Map<String, Object?>> getSettings() async {
    await send('GET', '/v1/me/settings');
    return _settingsOut();
  }

  @override
  Future<Map<String, Object?>> putSettings(
    Map<String, Object?> incoming,
    DateTime changedAt,
  ) async {
    await send('PUT', '/v1/me/settings');
    if (settingsAt == null || changedAt.isAfter(settingsAt!)) {
      settings = incoming;
      settingsAt = changedAt;
    }
    return _settingsOut();
  }

  @override
  Future<List<Object?>> putTasbih(List<Map<String, Object?>> days) async {
    await send('PUT', '/v1/me/tasbih');
    for (final d in days) {
      final day = d['day']! as String;
      final count = d['count']! as int;
      if (count > (tasbih[day] ?? 0)) tasbih[day] = count;
    }
    return [
      for (final e in tasbih.entries) {'day': e.key, 'count': e.value},
    ];
  }

  @override
  String get baseUrl => 'http://fake';

  @override
  Future<Object?> send(String method, String path, {Object? body}) async {
    calls.add('$method $path');
    if (fails) throw const ApiException(503);
    return null;
  }

  @override
  Future<void> deleteAccount() => send('DELETE', '/v1/me');
}

/// The store in memory: [outcome] decides what a purchase does.
class FakePremiumStore implements PremiumStore {
  FakePremiumStore({
    this.premium = false,
    this.canRestore = false,
    this.outcome = BuyOutcome.bought,
    List<Plan>? plans,
  }) : _plans = plans ?? defaultPlans;

  static const defaultPlans = [
    Plan(kind: PlanKind.annual, price: 35.99, priceText: r'$35.99'),
    Plan(kind: PlanKind.monthly, price: 4.99, priceText: r'$4.99'),
    Plan(kind: PlanKind.lifetime, price: 89.99, priceText: r'$89.99'),
  ];

  bool premium;
  final bool canRestore;
  BuyOutcome outcome;
  final List<Plan> _plans;
  final bought = <PlanKind>[];
  final _changes = StreamController<bool>.broadcast();

  @override
  bool get available => true;
  @override
  Future<bool> isPremium() async => premium;
  @override
  Stream<bool> get changes => _changes.stream;
  @override
  Future<List<Plan>> plans() async => _plans;

  @override
  Future<BuyOutcome> buy(Plan plan) async {
    bought.add(plan.kind);
    if (outcome == BuyOutcome.bought) {
      premium = true;
      _changes.add(true);
    }
    return outcome;
  }

  @override
  Future<bool> restore() async {
    if (canRestore) premium = true;
    return premium;
  }
}

/// A library of real references, for tests only (not a verse selection).
VerseLibrary testLibrary({bool placeholder = false}) => VerseLibrary(
  version: 't',
  placeholder: placeholder,
  entries: placeholder
      ? const []
      : [
          LibraryEntry(VerseRef(1, 1), Emotion.anxiety, VerseTag.comfort),
          LibraryEntry(VerseRef(1, 2), Emotion.anxiety, VerseTag.comfort),
          LibraryEntry(VerseRef(1, 3), Emotion.anxiety, VerseTag.comfort),
          LibraryEntry(
            VerseRef(1, 4),
            Emotion.anxiety,
            VerseTag.gentleReminder,
          ),
        ],
);

/// A settings store on an in-memory database.
Future<SettingsStore> memoryStore() async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return SettingsStore.load(db);
}

/// Pumps the app on a phone-sized screen with fake location and time.
/// Pass [settings] to start with saved settings, as after a restart.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  DeviceLocator? locator,
  DateTime? now,
  SettingsStore? settings,
  NotificationPermission? notifications,
  AlertScheduler? scheduler,
  CompassSource? compass,
  AppDatabase? database,
  SamplePlayer? player,
  RecitationRepository? recitations,
  VersePlayer? versePlayer,
  VerseLibrary? library,
  bool noLibrary = false,
  QuranRepository? quran,
  Dialer? dialer,
  ClassifyClient? classify,
  VoiceInput? voice,
  VoiceRecorder? recorder,
  VoiceNoteVault? vault,
  NotePlayer? notePlayer,
  AuthService? auth,
  AccountApi? accountApi,
  PremiumStore? premium,
  DuaRepository? duas,
}) async {
  // Assets load inside each test's fake clock; a load cached by an earlier
  // test would never complete in this one.
  rootBundle.evict(SafetyCheck.assetPath);

  // Reduced motion, so the pulsing mood button lets frames settle.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final store = settings ?? await tester.runAsync(memoryStore);
  final db = database ?? AppDatabase(NativeDatabase.memory());
  if (database == null) addTearDown(db.close);
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      settingsStoreProvider.overrideWithValue(store!),
      deviceLocatorProvider.overrideWithValue(
        locator ?? FakeLocator(const DeviceLocationFailed()),
      ),
      cityRepositoryProvider.overrideWith(
        (ref) async => CityRepository([sydney, makkah]),
      ),
      nowProvider.overrideWith(() => FixedClock(now ?? testNow)),
      notificationPermissionProvider.overrideWithValue(
        notifications ?? FakeNotificationPermission(),
      ),
      alertSchedulerProvider.overrideWithValue(
        scheduler ?? FakeAlertScheduler(),
      ),
      compassSourceProvider.overrideWithValue(compass ?? FakeCompass()),
      samplePlayerProvider.overrideWithValue(player ?? FakeSamplePlayer()),
      recitationRepositoryProvider.overrideWithValue(
        recitations ?? FakeRecitations(),
      ),
      versePlayerProvider.overrideWithValue(versePlayer ?? FakeVersePlayer()),
      verseLibraryProvider.overrideWith(
        (ref) async => noLibrary ? null : (library ?? testLibrary()),
      ),
      sessionRandomProvider.overrideWithValue(Random(1)),
      quranRepositoryProvider.overrideWithValue(quran ?? FakeQuran()),
      if (dialer != null) dialerProvider.overrideWithValue(dialer),
      classifyClientProvider.overrideWithValue(classify ?? FakeClassify()),
      voiceInputProvider.overrideWithValue(voice ?? FakeVoiceInput()),
      voiceRecorderProvider.overrideWithValue(recorder ?? FakeVoiceRecorder()),
      voiceNoteVaultProvider.overrideWithValue(vault ?? FakeVault()),
      notePlayerProvider.overrideWithValue(notePlayer ?? FakeNotePlayer()),
      authServiceProvider.overrideWithValue(auth ?? const NoAuthService()),
      accountApiProvider.overrideWithValue(accountApi ?? FakeAccountApi()),
      syncDelayProvider.overrideWithValue(Duration.zero),
      premiumStoreProvider.overrideWithValue(premium ?? FakePremiumStore()),
      duaRepositoryProvider.overrideWithValue(duas ?? FakeDuas()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const UnsApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

/// A provider container with the same fakes as [pumpApp], for tests that
/// don't need widgets.
Future<ProviderContainer> containerFor(
  AppDatabase db, {
  FakeVersePlayer? player,
}) async => ProviderContainer(
  overrides: [
    appDatabaseProvider.overrideWithValue(db),
    settingsStoreProvider.overrideWithValue(await SettingsStore.load(db)),
    nowProvider.overrideWith(() => FixedClock(testNow)),
    versePlayerProvider.overrideWithValue(player ?? FakeVersePlayer()),
    verseLibraryProvider.overrideWith((ref) async => testLibrary()),
    sessionRandomProvider.overrideWithValue(Random(1)),
    quranRepositoryProvider.overrideWithValue(FakeQuran()),
    recitationRepositoryProvider.overrideWithValue(FakeRecitations()),
    duaRepositoryProvider.overrideWithValue(FakeDuas()),
  ],
);
