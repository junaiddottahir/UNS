# Verse library

`library.json` is the scholar-approved verse library: verse references
(`surah`, `ayah`), an emotion `category` and a `tag` (`comfort`,
`gentle_reminder`, `warning`). It never contains verse text; the app
fetches text and audio from the Quran APIs.

Only reviewed changes go here. Bump `version` with every change.

The current file is a **placeholder** (`"placeholder": true`): every entry
uses surah 0, which does not exist, so it can't be mistaken for approved
content. Replace it with the scholar's file and set `"placeholder": false`;
the server then checks every reference is a real verse before starting.
