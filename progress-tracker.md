# Progress Tracker

Update this file after every meaningful implementation
change.

## Current Phase

- In progress — foundations

## Current Goal

- Unit 4: prayer notifications (per-prayer mode, pre-reminder, check-in),
  onboarding step 3.

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
- Recent locations in the location picker (prototype): storage exists now;
  add when polishing Profile/settings, or as a small follow-up.
- Self-harm phrase list: who writes and reviews the English and Arabic
  phrases.
- Scholar still to confirm the Arabic and English editions (from scope).

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
- 2026-09-23 — Encryption uses SQLite3MultipleCiphers (via `sqlite3`
  3.x build hooks) instead of SQLCipher: `sqlcipher_flutter_libs` is
  end-of-life, and sqlite3mc needs no OpenSSL on Android.

## Session Notes

- Run backend: `cd backend && .venv/bin/uvicorn app.main:app --reload`
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
