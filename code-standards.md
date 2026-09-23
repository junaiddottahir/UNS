# Code Standards

## General

- Keep modules small and single-purpose; one feature per folder.
- Fix root causes, do not layer workarounds.
- Do not mix unrelated concerns in one widget, provider or route.
- No religious text, verse references or translations hardcoded in code —
  they come from the Quran APIs and the approved library.

## Dart / Flutter

- Sound null safety; `flutter analyze` must pass with zero issues
  (`flutter_lints` baseline).
- Avoid `dynamic`; model API data with typed, immutable classes.
- Validate and parse all network JSON at the client boundary before use.
- Widgets render; logic lives in providers/services. No network or DB calls
  from `build`.
- Riverpod for state, go_router for navigation.
- All user-facing strings go through localisation (English and Arabic);
  layouts must work right-to-left.
- Use theme tokens from `app/lib/core/theme/` — no hardcoded colors.

## Python / FastAPI

- Python 3.12, type hints everywhere, Pydantic v2 models for every request
  and response body.
- Routers stay thin; logic lives in `services/`.
- Never log request text from `/v1/classify`.
- Classifier output is validated against the fixed category enum; anything
  else is treated as "unknown", never passed through.
- `ruff` for lint and format.

## API Routes

- Versioned under `/v1`.
- Validate and parse request input before any logic runs.
- Return consistent response shapes; errors as `{"error": {"code", "message"}}`.

## Data and Storage

- User data lives only in the encrypted on-device database.
- The encryption key lives in platform secure storage.
- Verse library records hold references and tags only, never text.

## File Organization

- `app/lib/core/` — theme, routing, storage, API clients, l10n.
- `app/lib/features/<feature>/` — screens, widgets, providers for one feature.
- `app/test/` — unit and widget tests.
- `backend/app/routers/` — HTTP routes.
- `backend/app/services/` — business logic (library, classifier).
- `backend/app/data/` — approved verse library.
- `backend/tests/` — pytest tests.

## Verification

- App: `flutter analyze` and `flutter test` pass.
- Backend: `ruff check` and `pytest` pass.
