# feat(reservations): reservation-hold engine (BE-401..404)

- **PR:** #231 — https://github.com/enzoftware/hotelyn/pull/231
- **Branch:** feat/be-401-404-reservation-holds → main
- **Status:** open
- **Created:** 2026-07-08
- **Author:** Enzo Lizama

## Summary
Adds the EPIC-04 **reservation-hold engine** (#167–#170): a short-lived,
exclusive claim on a room so a guest can finish checkout without being
double-booked. Correctness is enforced by Postgres — a partial unique index —
rather than application logic, so concurrent holds resolve to exactly one winner
with no Redis/app lock. Expiry is query-time (no paid scheduler), and the Dart
layer surfaces the "already held" case as a typed 409 error.

## Changes
- **db — migration `..._reservation_holds.sql`:**
  - **BE-401 (#167):** partial unique index
    `reservations(room_id) WHERE status IN ('held','confirmed')` — makes
    double-booking physically impossible.
  - **BE-402 (#168):** `create_reservation_hold(room_id, guest_id, check_in,
    check_out)` RPC (`INSERT … ON CONFLICT DO NOTHING`) returning the created row
    or zero rows ("already held"); generates a unique `confirmation_code` in the
    same transaction; reclaims lapsed holds first. `SECURITY DEFINER` with an
    `auth.uid()` guard so a guest cannot hold in another's name (service role,
    `auth.uid()` null, may pass any guest id). `is not true` NULL-safe
    availability check.
  - **BE-403 (#169):** query-time expiry — read paths treat
    `held AND hold_expires_at < now()` as free; `status` may lag reality until
    touched (documented as intentional).
  - Added `hold_duration()` (15 min) and `generate_confirmation_code()`
    (Crockford base32) tunables.
- **db — pgTAP (`reservation_holds_test.sql`, BE-404 #170):** proves
  single-winner, unavailable-room rejection, expired-hold reclaim, and the
  guest-authorization guard. Uses relative (`current_date + N`) dates.
- **db — fixtures:** updated `geo_search_test.sql` and `rls_test.sql`, which
  relied on double-booking a room the new index now forbids (distinct rooms /
  inactive status).
- **hotelyn_domain:** new `Reservation` model + `ReservationStatus` enum with
  UTC-anchored, timezone-stable `check_in`/`check_out` date converters; excludes
  generated `*.g.dart` from analysis.
- **hotelyn_api_client:** `createReservationHold` (POST `/hotels/{id}/holds`)
  mapping a `409` to a typed `RoomAlreadyHeldException` (subtype of
  `ApiException`); `_asDate` emits a UTC `YYYY-MM-DD`.
- **docs:** README documents the hold engine (table, RPC, expiry model).

## Verification
- `supabase db reset` applies all migrations + seed cleanly from scratch.
- `supabase test db` green — **43 pgTAP assertions** across geo_search,
  reservation_holds, rls.
- 20-connection concurrency check → exactly one winner, 19 "already held".
- `dart analyze --fatal-infos` clean on both packages; `dart test` green
  (hotelyn_domain 16, hotelyn_api_client 10); `dart format` clean.
- A CodeRabbit review was run; all actionable findings fixed (auth guard,
  timezone-safe dates, NULL-safe check, relative test dates, de-duplicated 409
  message). One finding — the index keying on `room_id` alone — is the
  deliberate MVP scope from #167, not a bug.

## Notes / follow-ups
- **REST hold endpoint** — no `POST /hotels/{id}/holds` route yet; these four
  issues are DB-layer and don't specify one. The client method + typed error
  satisfy #168's Dart criterion; the route is the natural next issue.
- **CI wiring for `supabase test db`** — the pgTAP suite runs locally only;
  adding a Supabase job to `.github/workflows/main.yaml` is a follow-up (#170's
  "runs in CI").
- **Overlapping-stay booking** — the per-room index does not support
  non-overlapping date ranges; a `tstzrange` + `btree_gist` exclusion constraint
  is future work if needed.
- Closes #167, #168, #169, #170.
