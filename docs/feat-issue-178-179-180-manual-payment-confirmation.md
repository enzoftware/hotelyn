# feat(booking): manual payment confirmation (BE-701..703)

- **PR:** #236 — https://github.com/enzoftware/hotelyn/pull/236
- **Branch:** feat/issue-178-179-180-manual-payment-confirmation → main
- **Status:** open
- **Created:** 2026-07-10
- **Author:** Enzo Lizama

## Summary

Adds staff-side **manual payment confirmation** (BE-702) for the MVP, which has no online payment integration: a guest pays in person and hotel staff mark the reservation paid, completing the booking. The action is recorded (who + when) for later dispute resolution. The related epic issues BE-701 (confirmation code) and BE-703 (ID/age verification) required no code here — BE-701 already shipped with the reservation-hold engine (#231) and BE-703 is an explicit phase-2 deferral — both are documented in the README.

## Changes

- **`supabase/migrations/20260709120000_manual_payment.sql`** (new) — `paid_by`/`paid_at` audit columns on `reservations` (`paid_by` FK → `profiles`, `ON DELETE SET NULL` so the payment fact survives a removed staff account) + the `mark_reservation_paid(actor, id)` RPC. It re-checks ownership via `actor_manages_hotel` (SECURITY DEFINER bypasses RLS, like the other staff RPCs), locks the row `FOR UPDATE` to close the check-then-write race, transitions a live hold → `confirmed`, clears the expiry, and stamps `paid_by`/`paid_at`. Refuses `reservation_not_payable` for anything that is not a live hold (already-confirmed, terminal, or an expired hold per BE-403 query-time expiry), plus `not_authorized` / `reservation_not_found`. Granted to `service_role` only.
- **`backend/lib/src/data/hotel_data_client.dart`** — `markReservationPaid({actorId, reservationId})` on the interface + Supabase impl (`mark_reservation_paid` RPC).
- **`backend/routes/reservations/[id]/pay.dart`** (new) — `POST /reservations/{id}/pay`, staff-gated via `staffAction`.
- **`backend/lib/src/http/auth.dart`** — map `reservation_not_payable` → `409` in `rpcErrorResponse`.
- **`packages/hotelyn_domain/lib/src/reservation.dart`** (+ generated `.g.dart`) — `Reservation.paidBy` / `paidAt` fields (snake_case JSON, nullable).
- **`README.md`** — new "Booking confirmation & manual payment (EPIC-07)" section documenting BE-701 (already-landed confirmation code), BE-702, and the BE-703 deferral/compliance gap; added the `/reservations/{id}/pay` REST row.
- **Tests** — `supabase/tests/manual_payment_test.sql` (new, 13 assertions), `backend/test/routes/reservations/pay_test.dart` (new), plus updates to `packages/hotelyn_domain/test/reservation_test.dart`, `backend/test/helpers/fake_hotel_data_client.dart`, and `backend/test/helpers/unused_staff_methods.dart`.

## Verification

- `dart analyze` clean on `backend/` and `packages/hotelyn_domain/`.
- Backend `dart test` green (incl. new `pay_test.dart`: 405 / 401 / paid-with-audit-fields / 403 / 404 / 409-with-message / 500).
- Domain `dart test` green (incl. new paid-fields mapping + null-tolerance cases).
- `supabase db reset` applies all migrations cleanly from scratch.
- `supabase test db` green — 81 pgTAP assertions across the suite, including the new `manual_payment_test.sql` (structure, happy path + audit stamps, and the already-confirmed / non-owning / missing / terminal / expired refusals).
- CodeRabbit review: 5 findings. Applied the `FOR UPDATE` race fix, the terminal-status test case, and the audit-field + error-message assertions. Did not apply the JWT-signature-boundary finding — a pre-existing, documented, project-wide design decision (README "Auth note") and a tracked follow-up, out of scope here.

## Notes / follow-ups

- **BE-701** (confirmation code) shipped with #231; no code change in this PR — only documented.
- **BE-703** (ID/age verification data capture) is a documented phase-2 deferral (decision #3), **not built in the MVP**. Shipping to real users in "hoteles de paso" jurisdictions without it remains a real pre-launch **compliance gap**, not just a missing feature.
- Closes #178, #179, #180.
