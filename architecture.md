# Architecture Context

## Stack

| Layer            | Technology                                  | Role                                                        |
| ---------------- | ------------------------------------------- | ----------------------------------------------------------- |
| Mobile app       | Flutter (Dart), iOS + Android               | All UI, all wellness data, prayer/qibla math, playback      |
| State / routing  | Riverpod, go_router                         | App state and navigation                                    |
| Prayer math      | `adhan` Dart package                        | On-device prayer times and qibla bearing                    |
| Compass          | `flutter_compass` + `geomag` (WMM-2025)     | Heading for the qibla dial; magnetic → true north on Android |
| Time zones       | `timezone` package (bundled IANA database)  | Show prayer times in the chosen city's local time           |
| Local storage    | Drift (SQLite) + SQLite3MultipleCiphers, secure storage | Encrypted journal, tasbih history, settings, verse cache    |
| Notifications    | flutter_local_notifications                 | Scheduled prayer alerts and adhan                           |
| Audio playback   | just_audio                                  | Recitation playback from cached per-ayah MP3s               |
| Speech to text   | `speech_to_text`, on-device mode            | Voice mood input → text, on the phone                       |
| Audio recording  | `record`                                    | Voice-note reflections, saved encrypted on device           |
| Auth             | Supabase Auth (`supabase_flutter`)          | Optional sign in: Apple, Google, email + password           |
| Backend          | FastAPI (Python 3.12), Pydantic v2          | Verse library, mood classification, settings sync, account  |
| Backend database | Supabase Postgres                           | Synced settings and tasbih history for signed-in users      |
| Mood classifier  | Anthropic Claude API (called from backend)  | Free text → one fixed emotion label + risk flag             |
| Purchases        | App Store / Google Play IAP via RevenueCat  | Monthly, yearly and lifetime premium; restore               |
| Quran text       | fawazahmed0 Quran API                       | Arabic and translation text, fetched by the app             |
| Recitation audio | UmmahAPI                                    | Per-ayah MP3, fetched by the app                            |

## Repository Layout / System Boundaries

- `app/` — Flutter app. Owns every screen, all wellness data, prayer and
  qibla calculation, notifications, speech-to-text, voice notes, verse
  text/audio caching and playback, session quota, purchases, and the
  on-device safety checks.
- `app/lib/features/<feature>/` — one folder per feature (onboarding, auth,
  home, prayer, qibla, shama, tasbih, journal, sources, paywall, profile).
- `app/lib/core/` — shared services: storage, API client, auth, Quran/audio
  clients, safety check, theme, routing, localisation, app config.
- `app/lib/core/config/` — values that will change later, such as the
  helpline number. Never hardcode these in widgets.
- `backend/` — FastAPI service. Serves the approved verse library,
  classifies free-text mood, syncs settings for signed-in users and deletes
  accounts. Verifies Supabase JWTs; never issues its own credentials.
- `backend/app/data/` — the approved verse library as versioned data
  (verse references + category + tag only, never verse text). Served by
  `GET /v1/library` with an ETag; validated at startup. Until the scholar
  delivers, a placeholder on the non-existent surah 0 with
  `"placeholder": true` stands in.
- `backend/migrations/` — SQL migrations for the Supabase Postgres schema.
- `app/lib/features/prayer/` — prayer calculation (`PrayerSchedule` wraps
  `adhan`), settings, country → method suggestion, and the times/settings
  screens. Times are computed in the city's IANA zone (from
  `cities.json`), never the phone's zone.
- `app/assets/data/cities.json` — bundled GeoNames city list for manual
  city search and labelling a device position with a city name, offline.
  Built by `tools/cities/build_cities.py`; never edit by hand.
- `tools/curation/` — (later) offline AI-assisted candidate search for the
  scholar to review. Runs once before launch; never part of the runtime.

## Storage Model

- **Device (encrypted SQLite)** — `uns.db`; key in Keychain / Android
  secure storage, not backed up (a missing or wrong key means a fresh
  database); settings in a key → JSON `settings` table. Holds: journal
  entries, mood before/after, session
  history and weekly quota, tasbih counts and custom dhikr, settings,
  location. Journal and mood are never uploaded.
- **Device (encrypted files)**: voice-note reflections.
- **Device cache**: approved verse library, verse text and per-ayah audio,
  fetched once from the upstream APIs.
- **Backend data file**: approved verse library — `{surah, ayah, category,
  tag}` records plus a library version. Reviewed changes only.
- **Supabase Auth**: account identity (email, Apple/Google link).
- **Supabase Postgres** (signed-in users only): prayer settings (method,
  Asr, high-latitude rule, alert choices), app language, reciter, tasbih
  daily history and custom dhikr. Rows keyed by user ID with row-level
  security. No location coordinates, mood, journal or voice data.
- **RevenueCat**: purchase receipts and entitlements. RevenueCat app user
  ID = Supabase user ID when signed in, anonymous ID otherwise.
- **Backend runtime**: classification requests are not persisted or logged
  with their text.

## Auth and Access Model

- Sign in is optional. Every feature works signed out; data stays on the
  phone.
- Methods: Sign in with Apple, Sign in with Google, email + password (with
  email verification and password reset).
- Signing in adds: settings and tasbih sync across devices, and premium
  linked to the account.
- The app sends the Supabase access token to FastAPI; FastAPI verifies it
  and only reads or writes that user's rows.
- Account deletion is available in Profile and removes the Supabase user,
  their synced rows and the RevenueCat link (App Store requirement).
- Premium: checked on device through the RevenueCat SDK. Restore works
  through the store account ("Restore purchases") and through sign in.
- Library and classify endpoints are public, carry no identifiers and are
  rate limited. Classify never receives the access token.

## Runtime Flows

- Chips → category decided on device → pick verses from cached library by
  category + tag (comfort = `comfort`; reminder = `gentle_reminder` +
  `warning`) → load text/audio from cache (fetch once if online) → play
  until the chosen length. A placeholder library never plays.
- Voice → on-device speech-to-text → handled as free text.
- Free text → on-device safety check → `POST /v1/classify` → `{category,
  risk}` → risk shows support resources; otherwise same as chips.
- Written journal entry → on-device safety check on save → match shows a
  caring message with the helpline; the entry still saves.
- Sign in → Supabase session → `GET /v1/me/settings` → merge with local
  (see open questions) → local changes pushed with `PUT /v1/me/settings`.
- Upgrade → RevenueCat paywall offering → store purchase sheet →
  entitlement active on device.

## Safety Check (on device)

- A bundled list of self-harm phrases in English and Arabic, matched after
  normalising the text (case, diacritics, Arabic letter variants).
- A plain phrase match, not AI, so it respects the no-AI-on-journal rule.
- Used on typed mood text, voice transcripts and written journal entries.
- On a mood check-in, the backend classifier's risk flag is a second check.
- Voice-note reflections are not transcribed, so they are not checked.
- The helpline shown is read from app config (currently `000`).

## Invariants

1. Religious text and audio are only ever the unmodified output of the Quran
   APIs. No AI output is ever displayed as religious content.
2. AI's only runtime job is mapping user text to one fixed emotion category
   (and a risk flag). It never writes, paraphrases or explains verses.
3. Sessions only serve verses present in the scholar-approved library.
4. Journal content (text and audio) and mood history never leave the device
   and are never processed by AI.
5. The server stores only account identity, synced settings and tasbih
   history. It never receives mood history, journal, location coordinates
   or voice data, and classification requests carry no identifiers.
6. Risk detected at any check shows support resources instead of a session.
7. Prayer times and qibla are computed on device and work fully offline.
   Device coordinates are never sent to a geocoding service; city names
   come from the bundled list.
8. Voice audio never leaves the device; only the transcript of a mood
   check-in is sent, on the same path as typed text.
9. Every feature works signed out.
