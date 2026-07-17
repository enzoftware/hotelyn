# feat(domain): repository interfaces + Guest/Message/Hold entities (BE-803)

- **PR:** #243 — https://github.com/enzoftware/hotelyn/pull/243
- **Branch:** feat/issue-183-repository-interfaces → main
- **Status:** merged (2026-07-17)
- **Created:** 2026-07-17
- **Author:** Enzo Lizama

## Summary
Implements BE-803 (#183): the shared-vocabulary repository contracts plus the remaining domain entities, so the server and any future client speak a common language without coupling to Supabase or Ferry types. Adds five pure abstract repository interfaces and three new value-type entities to the `hotelyn_domain` package. No shipped code is rewired here — the Dart Frog service layer implements these contracts later in BE-902.

## Changes

### `hotelyn_domain` — repository interfaces (`lib/src/repositories/`)
- `HotelRepository`, `RoomRepository`, `ReservationRepository`, `AuthRepository`, `MessageRepository` — pure abstract, domain-typed only. No Supabase `PostgrestList`, no Ferry `GData`; every method takes/returns domain entities.
- Docstrings import the specific `src/*.dart` entity files (not the package barrel) to avoid a `lib/src` file importing its own barrel.

### `hotelyn_domain` — new entities (`lib/src/`)
- `ReservationHold` — held-reservation projection with a guaranteed non-null `expiresAt` + `confirmationCode` (the value it adds over `Reservation`, whose `holdExpiresAt` is nullable).
- `Guest` — lightweight booking identity (`id`, `fullName?`, `email?`), distinct from the role-carrying `User` from BE-802.
- `Message` — forward-looking messaging contract (no `messages` table exists yet; Messages tab is currently mock-only).
- Simple value types via `equatable`, no hand-written JSON.

### Package exports
- `lib/hotelyn_domain.dart` — expanded barrel to export the three new entities and five repository interfaces.

### Tests (`test/`)
- `guest_test.dart`, `message_test.dart`, `reservation_hold_test.dart` — value-equality + per-field inequality (incl. `hashCode`).
- `repositories_test.dart` — implements all 5 interfaces with fakes; compile-time proof every signature is expressible in domain types alone, and fakes return correct domain shapes.

## Verification
- `melos analyze --no-select` — clean across all packages (`--fatal-infos`).
- `melos test --no-select` — green across all packages (domain: 63 tests).
- `hotelyn_domain` dependencies confirmed to remain `equatable` + `json_annotation` only (no `supabase`, `ferry`, or `flutter`).
- CodeRabbit review could not complete (account review rate limit reached during the prior issue). A self-review was performed in its place: clarified the `Guest` equality test and removed a self-barrel-import anti-pattern.

## Notes / follow-ups
- `Message` / `MessageRepository` are contracts ahead of backend support — there is no `messages` table in the schema and the app's Messages tab is mock-only, per the issue's "shared vocabulary" framing.
- The Dart Frog service layer implements these interfaces in BE-902.
- `Hotel`, `Room`, `Reservation` already existed (BE-802 and earlier), so this issue only added the three new entities.
