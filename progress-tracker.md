# Progress Tracker

Update this file after every meaningful implementation
change.

## Current Phase

- In progress — foundations

## Current Goal

- Unit 12: app — free-text chat input wired to classify + safety flow.

## Completed

- Unit 0 (2026-09-23): context files filled from the MVP 1 Scope PDF and
  prototype. Flutter app scaffolded in `app/` (iOS + Android, Riverpod,
  go_router, theme tokens). FastAPI backend scaffolded in `backend/` with
  `GET /v1/health`. `flutter analyze`, `flutter test`, `ruff`, `pytest` pass.

- RevenueCat SDK wired (2026-09-23, early part of unit 19 at the user's
  request): `purchases_flutter` added, configured at startup from
  `AppConfig.revenueCatApiKey`. Test Store key verified against the
  RevenueCat API (no offerings yet). iOS simulator build passes.

- Unit 1 (2026-09-23): onboarding shell + location step.
  - Welcome, 3 intro slides (swipe, arrow, Skip), step 1 location, city
    search, placeholders for steps 2–4, placeholder home.
  - "Use my location" via geolocator (city-level accuracy; coarse only on
    Android), handles denied / denied forever (Open Settings) / service
    off / failure, always with the city fallback.
  - Bundled GeoNames city list (31.7k cities, 2.6 MB, English + Arabic
    alternate names); search and nearest-city labelling run on the phone.
    Rebuilt by `tools/cities/build_cities.py`.
  - go_router routes, gen-l10n (English ARB), prototype backgrounds + logo.
  - 16 unit/widget tests; iOS integration test passed on the simulator with
    real location (Sydney).
  - (Location is saved since unit 3.)

- Unit 2 (2026-09-23): prayer times on device.
  - `adhan` computes the five prayers on the phone. Times are shown in the
    chosen city's own time zone (`timezone` package, full IANA database,
    loaded on first use), so a city abroad shows its local times.
  - Method is suggested from the city's country (`method_suggestion.dart`)
    until the user picks one; Asr (standard / Hanafi) and high-latitude
    rule (middle of night / 1/7th / angle) settings.
  - Onboarding step 2 (Asr pills, today's times, method link), home (date ·
    city header, next-prayer hero with countdown on that prayer's
    background), today's times list, prayer settings, method picker,
    location picker (search + current location).
  - Countdown updates on each minute boundary; after Isha it counts to
    tomorrow's Fajr. Where the sun doesn't rise or set (polar day/night)
    the screens say times can't be calculated instead of crashing.
  - Verified against api.aladhan.com for Sydney (MWL), Makkah (Umm
    al-Qura), New York (ISNA), Karachi (Karachi, Hanafi): every prayer
    within 2 minutes (the adhan library adds a +1 min Dhuhr margin).
  - 36 unit/widget tests; iOS integration test (real location → Sydney →
    home) and a screenshot walkthrough on the simulator.
  - Not in this unit: qibla/tasbih shortcuts and mood card on home (units 5,
    6, 9), alert icons and the Alerts row (unit 4), recent locations
    (needs storage, unit 3).

- Unit 3 (2026-09-23): encrypted local database + settings persistence.
  - Drift database `uns.db` in the app support folder, encrypted with
    SQLite3MultipleCiphers (`sqlite3` package build hook, `source:
    sqlite3mc` in pubspec). Opening refuses to run on a SQLite build
    without encryption.
  - 256-bit random key in the Keychain / Android secure storage
    (`first_unlock_this_device`: not in backups, readable after first
    unlock for background notification work). If the key is missing or
    wrong (e.g. files restored to a new phone), the database is recreated
    empty instead of crashing.
  - `settings` table (key → JSON). `SettingsStore` loads it at startup
    and writes changes through. Saved: location, prayer settings,
    onboarding complete.
  - Returning users open straight to home; unfinished onboarding restarts
    at welcome.
  - 46 unit/widget tests (incl. raw file bytes have no SQLite header and
    no readable city name, wrong key can't open, lost key → fresh DB);
    iOS integration test: onboard → close → reopen → home with saved
    choices, file encrypted on the simulator.
  - Drift code is generated: `dart run build_runner build` after changing
    tables (`app_database.g.dart` is committed).

- Prototype fidelity pass (2026-09-23, at the user's request): screens
  that were placeholders now match the prototype.
  - Step 3: "Alert me for" prayer pills and Sound (Adhan / Alert /
    Silent), saved as per-prayer alert modes, none on by default; "Allow notifications" asks
    for permission (flutter_local_notifications) and continues either way.
    Scheduling is still unit 4.
  - Step 4: reciter pills (Mishary Alafasy, Abdul Basit, Al-Sudais), saved.
    Sample playback waits for Quran audio (unit 8).
  - Home: Qibla and Tasbih shortcuts, greeting + "How are you feeling
    today?" with the pulsing voice button (pulse stops with Reduce
    Motion), and the floating tab bar (Home, Shama, Tasbih, Profile).
    Shama, Tasbih, Profile and Qibla show a "Coming in a later update"
    placeholder until their units.
  - 48 unit/widget tests; iOS persistence integration test passes;
    screenshots checked against the prototype.

- Unit 4 (2026-09-23): prayer notifications.
  - Per prayer: at prayer time Adhan / Alert / Silent / Off (Silent added
    to the prototype's three, per scope), remind before None / 10 / 15 /
    30 min, "did you pray?" check-in Yes / No. Prayer settings → Alerts
    ("n of 5") → list → per-prayer screen; today's times rows show the
    mode icon and open that prayer's alert.
  - Planned on the device from prayer times (`alert_planner.dart`):
    up to 7 days ahead, capped at 60 pending (iOS allows 64). Rescheduled
    on launch, on location / prayer / alert changes, every 6 hours while
    open, and on return to the app (permission may have changed).
  - Scheduling only runs when notifications are allowed (iOS refuses
    otherwise). Alert screens show "Notifications are off…" with a
    button that asks again or opens Settings.
  - Android: exact alarms when granted (asked after notification
    permission), inexact otherwise; boot receiver reschedules; channels
    per sound. Not verified on a device yet (no Android SDK here).
  - Fixed on the way: alert times formatted before date data loaded
    would have crashed launch; quick taps could undo each other's alert
    changes.
  - 60 unit/widget tests; iOS integration tests: saved alerts are
    registered with iOS on launch (24–28 for Fajr+reminder and
    Maghrib+check-in over 7 days), and a scheduled alert fires on time.

- Unit 5 (2026-09-23): qibla compass.
  - Bearing from `adhan` (great circle to the Kaaba), on the phone from
    the saved location; matches an independent great-circle formula to
    0.01° for six cities (Sydney 277.5°, London 119°).
  - Live dial (prototype): turns with the world, Kaaba at the qibla
    bearing, N at north; status "You're facing the qibla" (±5°), "Turn
    slightly left/right" (≤30°), "Turn left/right".
  - Heading via `flutter_compass`. iOS reports true north (needs
    location access; the screen asks, or links to Settings). Android
    reports magnetic north, corrected with the World Magnetic Model
    (`geomag`, WMM-2025, offline) at the user's position.
  - Calibration: Calibrate pill → "Move your phone in a figure-8" with
    live accuracy; low accuracy also shows a hint on the qibla screen.
  - No compass (e.g. simulator, or no reading within 3 s): shows "Face
    278° from north" with the dial as a still map.
  - 76 unit/widget tests; simulator screenshots checked (real device
    compass untested: the simulator has none).

- Unit 6 (2026-09-23): tasbih counter + daily history.
  - Tasbih tab (prototype): today's total, "After prayer" set
    (SubhanAllah 33 → Alhamdulillah 33 → Allahu Akbar 34, from the
    scope), single dhikr rows, "Custom dhikr · Premium" (placeholder
    Premium screen until unit 19).
  - Counter: tap anywhere, progress ring, light haptic per tap and a
    vibration at the target; pauses 0.7 s then moves to the next dhikr,
    or to History with "Dhikr complete". Start over resets the current
    count (today's total keeps it). The session survives leaving the
    screen while the app runs.
  - History: today plus earlier days (weekday within a week, then date);
    "Streaks · Premium".
  - Storage: `tasbih_days` table (day → total) in the encrypted database;
    schema v2 with a migration from v1 (tested on a v1 file).
  - Fixed on the way: totals written with a raw SQL statement didn't
    refresh live screens; now a typed upsert.
  - 87 unit/widget tests; simulator screenshots checked; persistence
    integration test still passes.

- Unit 7 (2026-09-23): backend `GET /v1/library`.
  - `backend/app/data/library.json`: `{version, placeholder, entries:
    [{surah, ayah, category, tag}]}`, references and tags only (a `text`
    field is rejected). Categories: the scope's nine emotions; tags:
    comfort / gentle_reminder / warning.
  - Placeholder until the scholar delivers (user's choice, 2026-09-23):
    27 entries (one per category × tag), all on surah 0, which doesn't
    exist, and `"placeholder": true`, so it can't pass as approved
    content. A real library must use real references (surah 1–114, ayah
    within the surah; Hafs counts, 6,236 total).
  - Loaded and validated at startup; an invalid file stops the server.
  - ETag from the content + `Cache-Control: public, max-age=3600`;
    `If-None-Match` → 304. Errors use `{"error": {"code", "message"}}`.
  - 14 pytest tests; ruff clean; checked against a running server.

- Unit 8 (2026-09-23): Quran text + audio clients, cache, Our sources.
  - Text: fawazahmed0 Quran API, editions `ara-quranuthmanihaf`
    (Uthmani Hafs, King Fahd Complex v13) and `eng-ummmuhammad`
    (Saheeh International, via Tanzil). Responses are checked (right
    verse, non-empty) and stored byte-for-byte in the encrypted database
    (`verse_texts`, schema v3); later reads work offline.
  - Audio: UmmahAPI `/api/quran/audio/{s}/{a}` → EveryAyah per-ayah
    MP3s. Reciters: Alafasy = 1, Al-Sudais = 2, Abdul Basit (Murattal) =
    3, each checked by name in case UmmahAPI renumbers; https only;
    written to `<app support>/recitations/<id>/<sssaaa>.mp3` via a temp
    file so partial downloads never count.
  - Step 4 now plays a sample (just_audio) on tap; tap again stops;
    offline shows a message and still selects.
  - "Our sources" (prototype) + reciter, GeoNames and WMM credits;
    reached from a minimal Profile tab (Prayer settings, Our sources).
  - Fixed on the way: leaving step 4 read a provider during disposal
    (throws in debug).
  - 100 unit/widget tests; iOS integration test against the real APIs:
    text fetched and served offline from the encrypted cache; all three
    reciters' samples download and load.

- Unit 9 (2026-09-23): Shama session via emotion chips + playback.
  - Flow (prototype): Shama tab "How are you feeling?" with 6 chips →
    "What would help right now?" (Comfort me / Remind me) → "How much
    time do you have?" (5/10/15/30, 10 recommended) → player → "How do
    you feel now?" (Calmer / A little better / The same / Heavier) →
    Done → home with "Session saved". Home's voice button opens Shama.
  - Library: `GET /v1/library` from the backend (`API_BASE_URL`,
    dart-define; `http://localhost:8000` in dev), validated, cached on
    the device with its ETag; offline uses the cache.
  - Only approved verses play: a placeholder library disables the chips
    with "Sessions open once our scholar has approved the verses." (what
    the app shows today). No library and offline → "Connect to the
    internet once…".
  - Comfort = `comfort` tag; Remind = `gentle_reminder` + `warning`.
    Random order; plays until the chosen time, finishing the verse then
    playing (or until verses run out). Previous restarts the verse (or
    goes back if < 3 s in); next; pause; X ends.
  - Text and audio come from the unit 8 caches; offline, verses not yet
    cached are skipped. Background audio enabled (iOS
    `UIBackgroundModes: audio`, speech audio session).
  - Player shows Arabic above the translation with the prototype's
    source tags, progress, reciter and time left.
  - Sessions saved in the encrypted database (`sessions`, schema v4):
    emotion, help, minutes, verses played, mood after, times.
  - iOS dev: `NSAllowsLocalNetworking` so the app can reach the local
    backend over http.
  - 118 unit/widget tests; iOS integration test plays real recitation
    with real text (test-only library of real references); simulator
    screenshots checked (fixed full-width chips).

- Unit 10 (2026-09-23): on-device safety check + support resources.
  - `assets/data/safety_phrases.json`: English = the prototype's phrases
    plus spelling variants of the same phrases; Arabic = a DRAFT list
    (marked in the file) pending review. Whole-word match after
    normalising (case, apostrophes, punctuation, Arabic diacritics and
    letter variants, Arabic attached prefixes like ال/و/ب); `*` marks a
    stem (`suicid*`). Plain matching, no AI (journal-safe).
  - `SafetyCheck.isRisky(text)` via `safetyCheckProvider`; used by
    typed/voice mood input (units 12–13) and journal (unit 14).
  - Support screen (prototype): "You don't have to carry this alone",
    Emergency · {helpline from AppConfig} dials (url_launcher `tel:`);
    if a call can't start (e.g. simulator) it says to dial; "I'm safe,
    go back".
  - "Heavier" after a session opens support; going back returns to the
    mood screen.
  - 146 unit/widget tests (incl. near-misses like "want to diet" and
    "killing me" not flagged); phrase list verified on the simulator;
    screenshots checked.

- Unit 11 (2026-09-23): backend `POST /v1/classify`.
  - `{"text"}` (1–1000 chars, trimmed; other fields ignored) →
    `{"category": <one of the 9> | "unknown", "risk": bool}`.
  - Claude via the Anthropic Python SDK (`anthropic` 1.8, async):
    `claude-sonnet-5` (user's choice, 2026-09-23), effort `low`,
    JSON-schema structured output restricted to the 9 categories +
    unknown. A refusal → unknown (app falls back to chips). No
    server-side fallbacks on Sonnet (that option targets Opus 5/Fable).
    Output re-validated; anything unexpected → unknown, keeping a clear
    risk flag. System prompt: classify only, never reply; risk = any
    sign of self-harm or danger, erring towards true.
  - Privacy: only the text is sent (no user ID, token or metadata); never
    logged or stored; errors never echo it (tested with caplog).
  - Rate limit: 20 requests/minute per client address, in memory only.
  - Needs `ANTHROPIC_API_KEY` in `backend/.env` (git-ignored; template
    `.env.example`); without it the endpoint answers 503 (not 500) and
    the app keeps the chips.
  - 34 pytest tests (fake Claude client: request shape, schema, refusal,
    failures; route: validation, rate limit, 503, no logging). Not yet
    run against the live API (no key on this Mac).

## In Progress

- None yet.

## Next Up

Each line is one unit; app and backend units are kept separate.

1. App: onboarding shell (welcome slides + 4 steps) + location step
   (permission, manual city fallback).
2. App: prayer times on device (`adhan`), method auto-suggest, Asr,
   high-latitude; home screen with next-prayer countdown.
3. App: encrypted local database + settings persistence.
4. App: prayer notifications (per-prayer mode, pre-reminder, check-in).
5. App: qibla compass + calibration prompt.
6. App: tasbih counter + daily history.
7. Backend: `GET /v1/library` serving the approved verse library (needs a
   placeholder library until the scholar delivers).
8. App: Quran text + audio clients with on-device cache; "Our sources".
9. App: Shama session via emotion chips (on-device) + playback.
10. App: on-device safety check (phrase list, helpline from config) +
    support resources screen.
11. Backend: `POST /v1/classify` (free text → category + risk).
12. App: free-text chat input wired to classify + safety flow.
13. App: voice mood input (on-device speech-to-text → chat path).
14. App: reflection journal — written entries, list, replay, safety check.
15. App: voice-note reflections (record, encrypted storage, playback).
16. Backend: Supabase project + schema, JWT verification, settings/tasbih
    sync endpoints, account deletion endpoint.
17. App: auth — sign in / register / forgot password (Apple, Google,
    email), account card in Profile, sign out, delete account.
18. App: settings and tasbih sync for signed-in users.
19. App: session quota (3/week) + paywall + RevenueCat store purchases +
    restore.
20. App: Athletics font, English/Arabic localisation and RTL pass.

## Open Questions

- Settings merge on first sign in: when the phone and the account both have
  settings, which wins? Proposal: the account's, after asking the user once.
- Developer accounts needed before units 17–19: Apple Developer (Sign in
  with Apple, IAP), Google Play Console. (RevenueCat account exists.)
- Final app ID (bundle ID / package name). Currently the placeholder
  `com.uns.uns`; must be set before registering with Apple, Google and
  RevenueCat.
- Android SDK is not installed on this Mac, so Android builds can't be
  verified yet.
- Voice transcription for Arabic: on-device recognition support differs by
  phone and OS version. If on-device isn't available, hide the mic or allow
  the platform's cloud recognizer? (Default until decided: hide the mic.)
- Weekly quota is on device, so reinstalling resets it. Acceptable for
  MVP 1, or track it on the server for signed-in users?
- Arabic Quran font choice.
- Athletics font files: the prototype's copies are marked "wf-rip" (taken
  from a website), so they are not bundled. Need the OTF files from the
  licence purchase for unit 20.
- Sign in link on the welcome screen (prototype has one): add with the auth
  unit (17) for returning users?
- Location error messages (denied, services off, failed) are new copy not in
  the prototype — review wording.
- GeoNames (CC BY 4.0) needs attribution — add to "Our sources" or an
  About/licences screen.
- Error/success colors are not defined in the prototype.
- Rate limiting: `/classify` has an in-memory 20/min per-client limit
  (single instance only; behind a proxy it needs the real client
  address). Revisit with the hosting choice; the library relies on
  caching.
- DEFERRED TO THE END (user, 2026-09-23): Anthropic API key in
  `backend/.env` and a live test of `/v1/classify`; confirm the org's
  data-retention setting. Anthropic data retention settings for mood text
  (scope says "no retention") — confirm the org's zero-data-retention
  status.
- The app must not run real sessions from a placeholder library (unit 9
  checks `placeholder`).
- Backend hosting target (e.g. Fly.io, Railway, Cloud Run).
- Pricing: $4.99 / $35.99 / $89.99 (USD base) is a suggestion adopted for
  the Test Store; confirm before creating real store products. Regional
  prices for Pakistan, Indonesia, Egypt (~30–40% of US) still to set.
- Replace the default `000` helpline with per-country numbers later.
- Country → method suggestions (`app/lib/features/prayer/method_suggestion.dart`)
  follow the adhan library's regional guidance (e.g. UK → Moonsighting
  Committee, US/CA → ISNA, Malaysia/Indonesia → Singapore). Scholar to
  confirm.
- Default high-latitude rule is "middle of night" (from the prototype);
  adhan recommends 1/7th above 48°. Keep, or switch automatically by
  latitude?
- Prayer times use 12-hour time without AM/PM, as in the prototype (24-hour
  if the phone is set to it). Confirm.
- New copy to review: "Prayer times can't be calculated for {place}
  today…" (polar day/night) and the method names in the method picker.
- Placeholder copy "Coming in a later update." on unbuilt tabs.
- Adhan sound: no recording is bundled, so Adhan alerts use the default
  sound. Need an approved adhan recording (iOS plays at most 30 s of a
  notification sound; longer needs a shortened cut). Who chooses it?
- "Did you pray?" check-in fires 30 min after the prayer starts (not in
  the prototype). Confirm the timing. It's a nudge only; answers aren't
  tracked (prayer tracker is out of scope).
- If the app isn't opened for about 4+ days (all alerts on), scheduled
  alerts run out. Add background refresh (iOS BGTaskScheduler / Android
  WorkManager) later?
- New notification copy to review: "Fajr in 15 min", "Did you pray
  Asr?", body "4:21 AM · Sydney", "Notifications are off for Uns…".
- Recent locations in the location picker (prototype): storage exists now;
  add when polishing Profile/settings, or as a small follow-up.
- Qibla copy to review: "Turn slightly left/right", "Compass accuracy is
  low…", "The compass isn't available on this phone. Face {n}° from
  north.", "Allow location access so the compass can find true north."
- Qibla should be tried on a real iPhone and Android phone (heading,
  calibration, true-north correction) before release.
- Dhikr names are English transliterations from the scope. Arabic-script
  forms (for the Arabic app language) need the scholar.
- Shama chips: the prototype has 6 (Anxious, Sad, Lonely, Angry,
  Grateful, Hopeful); the scope has 9 categories. Humility, arrogance
  and greed are reachable only through free text (unit 12) for now.
  Their labels ("Humble", "Proud", "Wanting more") are my wording.
- "Heavier" after a session should lead to support (unit 10); for now it
  just saves.
- The player shows the verse reference ("Surah · 2:255"), not the surah
  name (names aren't sourced yet).
- Session length: the session ends after the verse playing when time
  runs out, so it can run over by up to one verse. OK?
- Self-harm phrase list: who writes and reviews the English and Arabic
  phrases. English is the prototype's list (+ variants); Arabic is my
  unreviewed DRAFT — must be reviewed by a native speaker and clinician
  before release.
- Support screen shows only the emergency number (prototype). Add a
  crisis line (e.g. Lifeline 13 11 14 in Australia) alongside 000?
- Scholar still to confirm the Arabic and English editions (from scope).
  In use: `ara-quranuthmanihaf` and `eng-ummmuhammad` (AppConfig).
- Reciter sample verse is 1:1 (AppConfig), my placeholder choice; the
  scholar should confirm or pick another.
- The Uthmani text needs a font that renders it properly (the API notes
  the Quran Complex Uthmanic Hafs font); see "Arabic Quran font choice".
- "Our sources" says every verse is scholar-approved; true once the real
  library replaces the placeholder (sessions can't run before then).

## Architecture Decisions

- Monorepo: `app/` (Flutter) and `backend/` (FastAPI). Kept separate so
  each can be verified on its own.
- Server holds no wellness data — required by the scope's privacy model
  (location, mood, journal stay on device). It stores only account
  identity, synced settings and tasbih history.
- App fetches verse text and audio directly from the Quran APIs and caches
  it; the backend serves only verse references + tags. This keeps the
  "unchanged from the Quran API" invariant easy to verify.
- Prayer times and qibla are computed on device with the `adhan` package so
  they work offline and location never leaves the phone.
- Backend uses Python 3.12 from Homebrew (system Python is 3.9).
- 2026-09-23 — Optional accounts (replaces the earlier "no sign in"
  decision). Apple, Google, email + password via Supabase Auth; FastAPI
  verifies Supabase JWTs. Sync covers settings and tasbih only; journal
  and mood stay on the phone. Every feature works signed out. In-app
  account deletion included (App Store requirement).
- 2026-09-23 — Onboarding follows the prototype: welcome slides + 4 steps.
  App language follows the device and is changeable in Profile.
- 2026-09-23 — Voice input is in scope: voice mood check-ins (transcribed on
  device) and voice-note reflections (stored encrypted, never transcribed).
- 2026-09-23 — Journal crisis detection is an on-device phrase match, not
  AI, to keep the no-AI-on-journal rule. Written entries are checked; voice
  notes are not. A match shows the helpline but still saves the entry.
- 2026-09-23 — Helpline defaults to `000`, held in app config so it can be
  swapped per country later.
- 2026-09-23 — Payments via Apple/Google in-app purchase through RevenueCat
  (replaces Stripe, to follow store rules). RevenueCat handles receipts,
  renewals and restore; its user ID is the Supabase user ID when signed in.
  No purchase data in our backend.
- 2026-09-23 — Athletics is licensed for app use.
- 2026-09-23 — No prayer alerts are on by default; the user turns on the
  ones they want (sound preselected as Adhan, stored separately).
- 2026-09-23 — Encryption uses SQLite3MultipleCiphers (via `sqlite3`
  3.x build hooks) instead of SQLCipher: `sqlcipher_flutter_libs` is
  end-of-life, and sqlite3mc needs no OpenSSL on Android.

## Session Notes

- Run backend: `cd backend && .venv/bin/uvicorn app.main:app --reload --env-file .env`
  (`.env` holds `ANTHROPIC_API_KEY`; copy `.env.example`).
- Test backend: `cd backend && .venv/bin/pytest`
- Run app: `cd app && flutter run --dart-define-from-file=config/dev.json`
- `app/config/dev.json` holds keys and is gitignored; copy
  `config/dev.example.json` to create it. Without it, purchases are disabled.
- RevenueCat currently uses the Test Store key (`test_…`). Before release,
  swap in the `appl_` and `goog_` keys (per-platform) — the app throws
  if a `test_` key reaches a release build.
- RevenueCat project ID: `proj94cbdc06`.
- RevenueCat Test Store configured (2026-09-23) via API v2:
  products `uns_premium_monthly` ($4.99, P1M), `uns_premium_yearly`
  ($35.99, P1Y), `uns_premium_lifetime` ($89.99, non-consumable); all
  attached to entitlement `premium`; current offering `default` with
  packages `$rc_monthly`, `$rc_annual`, `$rc_lifetime`. Verified with the
  app's test key. Real App Store / Play products (same identifiers,
  regional prices) still to be created when those accounts exist.
- Git: pushed to https://github.com/junaiddottahir/UNS (branch `main`).
  Not committed on purpose: `Uns Prototype.html` and all font files
  (licensed; see .gitignore), `app/config/*.json` keys, backend `.venv`.
- Supabase project "Uns": ref `yjyegwckgrxwtoqygsrm`, URL
  `https://yjyegwckgrxwtoqygsrm.supabase.co`, region ap-northeast-1
  (Tokyo), Postgres 17. Created 2026-09-23; `public` schema empty. Schema
  goes in with unit 16 via migrations in `backend/migrations/`.
