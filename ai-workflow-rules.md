# AI Workflow Rules

## Approach

Build Uns incrementally using a spec-driven workflow. The context files
(`project-overview.md`, `architecture.md`, `code-standards.md`,
`ui-context.md`, `progress-tracker.md`) and the MVP 1 Scope PDF define what
to build, how to build it and the current state of progress. Always implement
against these specs — do not infer or invent behavior from scratch.

## Scoping Rules

- Work on one feature unit at a time
- Prefer small, verifiable increments over large
  speculative changes
- Do not combine unrelated system boundaries in a
  single implementation step

## When to Split Work

Split an implementation step if it combines:

- Flutter app changes and backend changes
- More than one feature folder (e.g. prayer times and qibla)
- Behavior not clearly defined in the context files

If a change cannot be verified end to end quickly,
the scope is too broad — split it.

## Handling Missing Requirements

- Do not invent product behavior not defined in the
  context files
- Never add or choose religious content (verses, duas, translations) —
  that is the scholar's job
- If a requirement is ambiguous, resolve it in the
  relevant context file before implementing
- If a requirement is missing, add it as an open question
  in `progress-tracker.md` before continuing

## Protected Files

Do not modify the following unless explicitly instructed:

- `backend/app/data/` — scholar-approved verse library
- `Muslim Wellness App — MVP 1 Scope.pdf` and `Uns Prototype.html`
- Generated platform folders (`app/ios/`, `app/android/`) except for
  required permission and capability entries
- Third-party package internals

## Keeping Docs in Sync

Update the relevant context file whenever implementation
changes:

- System architecture or boundaries
- Storage model decisions
- Code conventions or standards
- Feature scope

## Before Moving to the Next Unit

1. The current unit works end to end within its defined scope
2. No invariant defined in `architecture.md` was violated
3. `progress-tracker.md` reflects the completed work
4. App: `flutter analyze` and `flutter test` pass
5. Backend: `ruff check` and `pytest` pass
