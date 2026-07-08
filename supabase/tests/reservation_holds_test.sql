-- BE-401 / BE-402 / BE-403 / BE-404 · Reservation-hold engine (EPIC-04).
--
-- Run with: `supabase test db`. Exercises the hold RPC, the partial unique index
-- that guarantees single-winner, and the query-time expiry rules.
--
-- On concurrency (BE-404): pgTAP runs inside one transaction, so it cannot open
-- 20 real parallel connections. Instead we prove the *mechanism* that forces
-- exactly one winner — the partial unique index rejects a second active hold on
-- the same room — which is what makes the concurrent race resolve to one winner
-- regardless of arrival order. A true 20-connection race is exercised out of
-- band (see the PR description); this pins the invariant it relies on.
--
-- Seeded rooms used below:
--   Bogota  20000000-...0005  is_available = true   (bookable)
--   Lima    20000000-...0002  is_available = false  (staff-disabled)
--   Guest   00000000-...0001

begin;

select plan(14);

-- Clean slate so seeded reservations don't interfere; rolled back at the end.
delete from public.reservations;

-- ---------------------------------------------------------------------------
-- Structure (BE-401 / BE-701)
-- ---------------------------------------------------------------------------

select has_column('public', 'reservations', 'confirmation_code',
  'reservations has a confirmation_code column');

select has_column('public', 'reservations', 'hold_expires_at',
  'reservations has a hold_expires_at column');

-- The partial unique index that makes double-booking impossible.
select has_index('public', 'reservations', 'reservations_active_room_uidx',
  'the partial unique index on active holds exists');

-- ---------------------------------------------------------------------------
-- BE-402 · create_reservation_hold — happy path
-- ---------------------------------------------------------------------------

-- A hold on a free, available room succeeds and returns exactly one row.
select is(
  (select count(*)::int from public.create_reservation_hold(
     '20000000-0000-0000-0000-000000000005',
     '00000000-0000-0000-0000-000000000001',
     current_date + 60, current_date + 62)),
  1,
  'create_reservation_hold returns the created row for a free room'
);

-- That row is status=held, carries a confirmation code, and an active expiry
-- ~hold_duration() in the future.
select is(
  (select status from public.reservations
     where room_id = '20000000-0000-0000-0000-000000000005'),
  'held'::public.reservation_status,
  'the created hold has status = held'
);

select ok(
  (select confirmation_code is not null and confirmation_code like 'HZ-%'
     from public.reservations
    where room_id = '20000000-0000-0000-0000-000000000005'),
  'the created hold has a HZ- confirmation code'
);

select ok(
  (select hold_expires_at > now()
     from public.reservations
    where room_id = '20000000-0000-0000-0000-000000000005'),
  'the created hold has an active (future) expiry'
);

-- ---------------------------------------------------------------------------
-- BE-401 / BE-404 · second active hold loses (single-winner mechanism)
-- ---------------------------------------------------------------------------

-- A second hold on the SAME (now actively held) room returns ZERO rows — the
-- "already held" signal the Dart repo maps to a 409. This is the per-attempt
-- outcome that, under real concurrency, leaves exactly one winner.
select is(
  (select count(*)::int from public.create_reservation_hold(
     '20000000-0000-0000-0000-000000000005',
     '00000000-0000-0000-0000-000000000001',
     current_date + 64, current_date + 66)),
  0,
  'a second hold on an actively-held room returns zero rows (already held)'
);

-- And the room still has exactly one active held reservation (no duplicate slipped in).
select is(
  (select count(*)::int from public.reservations
     where room_id = '20000000-0000-0000-0000-000000000005'
       and status = 'held'),
  1,
  'the actively-held room has exactly one held reservation'
);

-- A raw INSERT of a second active reservation is rejected by the unique index
-- itself (proving the guarantee is in the DB, not just the RPC).
select throws_ok(
  $$insert into public.reservations
      (hotel_id, room_id, guest_id, status, check_in, check_out, hold_expires_at)
    values ('10000000-0000-0000-0000-000000000003',
            '20000000-0000-0000-0000-000000000005',
            '00000000-0000-0000-0000-000000000001',
            'confirmed', current_date + 90, current_date + 91, now() + interval '1 hour')$$,
  '23505',
  null,
  'a direct second active reservation is rejected by the unique constraint'
);

-- ---------------------------------------------------------------------------
-- BE-402 · staff-disabled room is rejected
-- ---------------------------------------------------------------------------

-- Room 200...0002 is seeded is_available = false. A hold on it is a hard
-- rejection (raise), not an "already held" empty result.
select throws_ok(
  $$select public.create_reservation_hold(
      '20000000-0000-0000-0000-000000000002',
      '00000000-0000-0000-0000-000000000001',
      current_date + 60, current_date + 62)$$,
  'room_unavailable',
  'a hold on a staff-disabled room is rejected'
);

-- ---------------------------------------------------------------------------
-- BE-403 · query-time expiry frees the room (status may lag reality)
-- ---------------------------------------------------------------------------

delete from public.reservations;

-- A hold whose expiry has already passed, still stored as status='held'.
insert into public.reservations
  (hotel_id, room_id, guest_id, status, check_in, check_out, hold_expires_at, confirmation_code)
values ('10000000-0000-0000-0000-000000000003',
        '20000000-0000-0000-0000-000000000005',
        '00000000-0000-0000-0000-000000000001',
        'held', current_date + 60, current_date + 62,
        now() - interval '1 minute', 'HZ-EXPIRED0');

-- The room reads available even though its only reservation is status=held:
-- expiry is authoritative, status is allowed to lag (documented, not a bug).
select is(
  public.is_room_available_now('20000000-0000-0000-0000-000000000005'),
  true,
  'an expired hold (still status=held) does not block availability'
);

-- Because the expired hold does not occupy the active slot, a fresh hold on the
-- same room succeeds.
select is(
  (select count(*)::int from public.create_reservation_hold(
     '20000000-0000-0000-0000-000000000005',
     '00000000-0000-0000-0000-000000000001',
     current_date + 70, current_date + 72)),
  1,
  'a new hold succeeds once the prior hold has expired'
);

-- ---------------------------------------------------------------------------
-- BE-402 · a guest cannot place a hold in another guest's name
-- ---------------------------------------------------------------------------
-- The RPC is SECURITY DEFINER (it bypasses RLS for the conflict check), so it
-- must bind the hold to the caller: a logged-in guest may only hold for their
-- own id. Authenticate as guest ...0001 and try to hold for staff ...0002.
delete from public.reservations;
set local role authenticated;
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated"}';

select throws_ok(
  $$select public.create_reservation_hold(
      '20000000-0000-0000-0000-000000000006',
      '00000000-0000-0000-0000-000000000002',
      current_date + 60, current_date + 62)$$,
  'not_authorized',
  'a guest cannot place a hold in another guest''s name'
);

reset role;

select * from finish();

rollback;
