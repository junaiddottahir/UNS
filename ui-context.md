# UI Context

Derived from `Uns Prototype.html`. When in doubt, match the prototype.

## Theme

Dark only. A warm, quiet, night-time feel — deep brown-black backgrounds,
cream text and soft copper accents. Calm, spacious, few elements per screen.

## Colors

All widgets use these tokens (defined in `app/lib/core/theme/`), never raw hex.

| Role             | Token           | Value     |
| ---------------- | --------------- | --------- |
| Page background  | `bgBase`        | `#140B08` |
| Deep background  | `bgDeep`        | `#0F0A08` |
| Surface          | `bgSurface`     | `#1C0F0A` |
| Primary text     | `textPrimary`   | `#F3EDE8` |
| Muted text       | `textMuted`     | `#F3EDE8` at ~60% opacity |
| Primary button   | `ctaBackground` / `ctaForeground` | `#F3EDE8` / `#1C0F0A` (cream pill, dark text) |
| Primary accent   | `accentPrimary` | `#E9A37C` |
| Strong accent    | `accentStrong`  | `#C0603A` |
| Deep accent      | `accentDeep`    | `#B8472A` |
| Accent shadow    | `accentShadow`  | `#5A2412` |
| Border           | `borderDefault` | `#F3EDE8` at ~10% opacity |

Error and success colors are not defined in the prototype — open question.

## Typography

| Role    | Font                           |
| ------- | ------------------------------ |
| UI text | Athletics (licensed for app use; bundle in `app/assets/fonts/`) |
| Arabic  | Uthmani-compatible Quran font — TBD, must render Uthmani script correctly |


## Border Radius

| Context               | Radius  |
| --------------------- | ------- |
| Buttons, chips, pills | 999 (fully rounded) |
| Cards / panels        | 24–28   |
| Chat bubbles          | 22, with one 6 corner |
| Icon buttons, dots    | circle  |

## Component Library

Custom widgets on top of Material 3 with the theme above. Shared widgets live
in `app/lib/core/widgets/`.

## Layout Patterns

- Onboarding: skippable welcome intro slides, then four full-screen steps
  with a "n of 4" indicator (location, prayer times, notifications,
  reciter).
- Sign in: optional. Offered once after onboarding (with "Not now") and
  from the account card at the top of Profile, as in the prototype. Screens:
  sign in, register, forgot password. Apple and Google buttons first, email
  below. Signed-out Profile card invites sign in to "sync settings across
  devices"; signed-in card shows name/email.
- Profile holds the account card, settings, journal count, premium status,
  restore purchases, privacy, "Our sources", sign out and delete account.
- Voice input: a mic option next to text entry; a "Listening" state with
  "Tap to finish"; the transcript is shown before it is sent.
- Home: date + location header, next-prayer hero, shortcut tiles, mood card.
- Bottom navigation between Home, Shama, Tasbih, Journal and Profile.
- Playback: Arabic above translation, source labels ("ARABIC · UTHMANI ·
  FROM QURAN API"), reciter and time remaining.
- Privacy cues ("Only on this phone") shown where users write.

## Icons

Lucide (via `lucide_icons` Flutter package). Stroke icons only.
