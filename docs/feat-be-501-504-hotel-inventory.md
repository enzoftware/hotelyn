# feat(inventory): hotel-side staff inventory & realtime (BE-501..504)

- **PR:** #232 — https://github.com/enzoftware/hotelyn/pull/232
- **Branch:** feat/be-501-504-hotel-inventory → main
- **Status:** open
- **Created:** 2026-07-08
- **Author:** Enzo Lizama

## Summary
Adds the EPIC-05 **hotel-side inventory** operations (#171–#174): staff manage
their own hotel's rooms and reservations, enforced in Postgres and exposed over
the Dart Frog REST layer. Staff see a room list with derived status, toggle
availability (guarded against double-allocation), and confirm/reject holds;
`reservations` is published for Supabase Realtime (RLS-scoped per hotel). Builds
on the EPIC-04 hold engine.

## Changes
- **db — migration `..._hotel_inventory.sql`:**
  - **BE-501 (#171):** `staff_room_list(actor, hotel_id?)` — the actor's own
    hotel rooms with a derived status (`available`/`unavailable`/`held`/
    `occupied`) via query-time expiry; scope comes from the actor's profile, and
    a staff row with a null hotel link is rejected.
  - **BE-502 (#172):** `set_room_availability(actor, room_id, is_available)` —
    ownership-checked toggle refusing to re-enable a room with an active hold
    **or confirmed booking** (`room_has_active_reservation`).
  - **BE-503 (#173):** `confirm_reservation` / `reject_reservation` — owning
    staff; confirming an expired hold fails (`hold_expired`); rejecting frees the
    room immediately (nulls `hold_expires_at`).
  - **BE-504 (#174):** `reservations` added to the `supabase_realtime`
    publication (idempotently).
  - Shared `actor_manages_hotel` / `room_status` helpers. The `p_actor`-trusting
    RPCs are granted to **`service_role` only** (not `authenticated`) so a
    logged-in user cannot call them directly via PostgREST with a forged actor.
- **db — pgTAP (`hotel_inventory_test.sql`):** room-list scope/status, toggle
  guard (hold *and* confirmed), confirm/reject incl. expired-hold and cross-hotel
  rejection, null-hotel-id guard, service-role-only grants, realtime membership.
- **backend (Dart Frog):** routes `GET /staff/rooms`,
  `PATCH /staff/rooms/{id}/availability`,
  `POST /reservations/{id}/confirm|reject`, sharing a `staffAction` wrapper that
  resolves the JWT actor and maps `RpcException` → HTTP (unknown code → 500, not
  a masking 409). New `auth.dart` (JWT `sub` extraction, response helpers);
  `HotelDataClient` gains the four staff methods + a typed `RpcException`.
- **hotelyn_domain:** `StaffRoom` model + `RoomStatus` enum (generated
  `*.g.dart`).
- **hotelyn_api_client:** `getStaffRooms`, `setRoomAvailability`,
  `confirmReservation`, `rejectReservation`; `_postJson` generalized to
  `_sendJson` (POST/PATCH, full-exchange timeout).
- **docs:** README documents the inventory engine, endpoints, and the auth/
  realtime boundaries.
- Fixes a pre-existing `nearby_test` that used a radius above the route's 100 km
  cap.

## Verification
- `supabase db reset` applies cleanly from scratch.
- `supabase test db` green — **65 pgTAP assertions** across geo_search,
  reservation_holds, rls, hotel_inventory.
- `dart analyze --fatal-infos` clean on `hotelyn_domain`, `hotelyn_api_client`,
  and `backend`; `dart test` green — domain (20), api_client (15), backend (48);
  `dart format` clean.
- Live integration through `SupabaseHotelDataClient` (service-role) against real
  Supabase: staff list, toggle, and the `not_authorized` guard.
- A CodeRabbit review (18 findings) was run and its actionable items fixed —
  notably a **real critical bug**: confirmed bookings (expiry nulled) were read
  as `available` and could be double-allocated, because `room_status` and the
  toggle guard gated on a live expiry. Both were fixed and are now covered by
  tests that exercise the real `confirm_reservation` path. Also fixed: RPC
  impersonation (grants → `service_role`), null-hotel-id scoping, and the auth/
  error boilerplate (extracted `staffAction`).

## Notes / follow-ups
- **Dashboard Realtime subscription** — this PR lands only the DB-side enabler
  (publication + RLS scoping). #174's literal wording ("the dashboard subscribes
  to a Supabase Realtime channel") conflicts with the repo's REST-only rule (no
  `supabase_flutter` in `apps/`), so the Flutter subscription is deferred to an
  app-layer follow-up.
- **Backend JWT signature verification** — the backend decodes the JWT `sub` but
  does not verify the signature; it relies on an upstream verifying ingress and
  the `service_role`-only grants. Server-side verification (defence in depth) is
  a tracked follow-up. **This server must not be exposed directly to clients.**
- Closes #171, #172, #173, #174.
