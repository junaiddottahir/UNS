# Uns

## Overview

Uns is an iOS and Android wellness app for practising Muslims. It combines
daily worship tools (prayer times, prayer notifications, qibla, tasbih) with
mood-based Quran listening ("Shama" sessions) and a private reflection
journal. A user shares how they feel and the app plays authentic,
scholar-approved Quranic verses matched to that emotion. Every religious word
shown or played comes from the Quran API unchanged — the app never generates,
paraphrases or explains verses with AI.

Source of truth for scope: `Muslim Wellness App — MVP 1 Scope.pdf`.
Visual reference: `Uns Prototype.html`.

## Goals

1. A new user finishes onboarding and sees correct prayer times for their
   location on the home screen, with no account.
2. A user can go from "How are you feeling?" to hearing matched, approved
   verses (Arabic, translation, recitation) in under a minute.
3. Location, mood and journal data never leave the device, except free-text
   mood input sent for classification with no identifiers and no retention.
   Signed-in users sync settings and tasbih history only.
4. Sessions work offline once the approved verse library has been cached.

## Core User Flow

1. Onboarding (matches the prototype): skippable welcome intro slides, then
   four numbered steps — (1) location (auto or manual city), (2) prayer
   times preview with method auto-suggested by country and Asr setting,
   (3) notifications (which prayers, sound), (4) reciter with a sample.
   App language follows the device (English or Arabic) and can be changed in
   Profile. Sign in is optional and offered after onboarding and in
   Profile, never as a gate.
2. Home: next prayer countdown, today's times, mood check-in card, tasbih and
   qibla shortcuts. Every MVP feature is one tap away.
3. Shama session: chat or emotion chips → safety check (risk → support
   resources and helplines) → "comfort me" or "remind me" → session length
   (5, 10, 15, 30 min, one recommended) → playback → optional reflection →
   saved to journal.
4. Tasbih: pick a dhikr → tap to count with haptics → vibration at target →
   next dhikr or finish → saved to daily history.
5. Journal: chronological list (date, mood before → after, first line) → open
   entry → replay its verses.

## Features

### Worship tools (free)

- Prayer times: auto location with manual city override; calculation methods
  (MWL, Umm al-Qura, ISNA, Egyptian, etc.); Asr (Hanafi or standard);
  high-latitude rules.
- Prayer notifications: per prayer silent / notification / full adhan;
  optional pre-prayer reminder; optional "did you pray?" check-in.
- Qibla: compass from device sensors with a calibration prompt.
- Tasbih counter: defaults SubhanAllah 33, Alhamdulillah 33, Allahu Akbar 34;
  haptics; daily history. Custom dhikr lists and streaks are premium.

### Shama sessions (6 per week free, unlimited premium)

- Input by free-text chat, voice or emotion chips. Voice is transcribed on
  the device, then treated exactly like typed text.
- Emotion categories: sadness, anxiety, anger, loneliness, gratitude, hope,
  humility, arrogance, greed.
- Each category maps to scholar-approved verses tagged comfort, gentle
  reminder or warning, which powers "comfort me" / "remind me".
- Arabic (Uthmani, Hafs), translation (Sahih International) and recitation
  (default Mishary Alafasy; others selectable).
- "Our sources" screen credits translator, reciter and review process.

### Reflection journal (free, mood insights premium)

- Optional post-session prompt, mood after, rotating prompt, auto-linked
  verses, chronological list.
- Reflections can be written or recorded as voice notes.
- Stored locally and encrypted (text and audio). Never read or answered by
  AI, never transcribed.
- Written entries are checked on the device for self-harm language; a match
  shows a caring message with the helpline.

### Monetization

- Plans: monthly, yearly (discounted), lifetime. Regional pricing.
- Payments through Apple App Store and Google Play in-app purchase
  (managed with RevenueCat). "Restore purchases" in Profile and paywall.
- Premium: unlimited sessions, multiple reciters and offline audio, custom
  tasbih lists and streaks, mood insights, curated multi-day programs.
- No ads, ever.

### Accounts (optional)

- Register and sign in with Apple, Google, or email + password (email
  verification, password reset).
- Signed in: prayer settings, language, reciter and tasbih history sync
  across devices; premium follows the account.
- Journal and moods stay on the phone even when signed in.
- Sign out and delete account in Profile.

## Scope

### In Scope

- The six MVP 1 features above, onboarding, home, Profile (settings),
  "Our sources" and paywall.
- Voice input for mood check-ins and voice-note reflections.
- English and Arabic app languages.
- Optional accounts (register, sign in, sign out, delete account) with
  settings and tasbih sync.
- A small backend for mood classification, the approved verse library,
  settings sync and account deletion.

### Out of Scope

- Ramadan mode, prayer tracker / qada, Hijri calendar and event reminders.
- Duas from hadith.
- Journal search and filters; journal and mood sync or cloud backup.
- Family plan.
- Languages beyond English and Arabic.

## Success Criteria

1. Fresh install → onboarding → home shows correct times for the chosen city
   and method, verified against a reference source.
2. Notifications fire at each enabled prayer time with the chosen sound mode.
3. Qibla bearing matches the great-circle bearing to the Kaaba for the
   user's coordinates.
4. Choosing an emotion chip with the network off plays cached approved verses.
5. Free text or voice suggesting self-harm shows support resources
   instead of a session; a written journal entry with self-harm language
   shows the helpline.
6. The 4th free session in a week shows the paywall.
7. Journal entries persist across app restarts and are encrypted at rest.
8. A user can use every feature signed out; after signing in on a second
   phone their prayer settings and tasbih history appear.
9. Premium bought on one phone is active on another after sign in or
   "Restore purchases".
