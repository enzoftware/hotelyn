-- BE-702 · Manual payment confirmation (EPIC-07).
--
-- Run with: `supabase test db`. Exercises mark_reservation_paid — the happy path
-- (held → confirmed, stamped, expiry cleared), the ownership check, and every
-- refusal (missing, non-owning staff, already-confirmed, terminal, expired).
--
-- Seeded fixtures used below (see supabase/seed.sql):
--   Staff    00000000-...0002  hotel_staff, owns hotel 10000000-...0001 (Lima)
--   Guest    00000000-...0001  guest
--   Room     20000000-...0001  belongs to Lima hotel, is_available = true

begin;

select plan(13);

-- Clean slate so seeded reservations don't interfere; rolled back at the end.
delete from public.reservations;

-- ---------------------------------------------------------------------------
-- Structure
-- ---------------------------------------------------------------------------

select has_column('public', 'reservations', 'paid_by',
  'reservations has a paid_by audit column');

select has_column('public', 'reservations', 'paid_at',
  'reservations has a paid_at audit column');

select has_function('public', 'mark_reservation_paid', array['uuid', 'uuid'],
  'mark_reservation_paid(uuid, uuid) exists');

-- ---------------------------------------------------------------------------
-- Happy path: owning staff mark a live hold paid
-- ---------------------------------------------------------------------------

-- A live hold on the Lima room, owned by the seeded guest.
insert into public.reservations
  (id, hotel_id, room_id, guest_id, status, check_in, check_out,
   hold_expires_at, confirmation_code)
values ('40000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001',
        'held', current_date + 30, current_date + 32,
        now() + interval '10 minutes', 'HZ-PAYTEST1');

-- Marking it paid as the owning staff returns exactly one row.
select is(
  (select count(*)::int from public.mark_reservation_paid(
     '00000000-0000-0000-0000-000000000002',
     '40000000-0000-0000-0000-000000000001')),
  1,
  'mark_reservation_paid returns the updated row for the owning staff'
);

-- The reservation is now confirmed, its expiry cleared, and stamped who/when.
select is(
  (select status from public.reservations
     where id = '40000000-0000-0000-0000-000000000001'),
  'confirmed'::public.reservation_status,
  'a paid reservation transitions to confirmed'
);

select ok(
  (select hold_expires_at is null
     from public.reservations
    where id = '40000000-0000-0000-0000-000000000001'),
  'a paid reservation has its ticking expiry cleared'
);

select is(
  (select paid_by from public.reservations
     where id = '40000000-0000-0000-0000-000000000001'),
  '00000000-0000-0000-0000-000000000002'::uuid,
  'paid_by records the staff member who took the payment'
);

select ok(
  (select paid_at is not null
     from public.reservations
    where id = '40000000-0000-0000-0000-000000000001'),
  'paid_at records when the payment was taken'
);

-- ---------------------------------------------------------------------------
-- Already-confirmed reservation is not payable
-- ---------------------------------------------------------------------------
-- The row above is now confirmed; paying it again is refused, not a no-op.
select throws_ok(
  $$select public.mark_reservation_paid(
      '00000000-0000-0000-0000-000000000002',
      '40000000-0000-0000-0000-000000000001')$$,
  'reservation_not_payable',
  'an already-confirmed reservation cannot be marked paid'
);

-- ---------------------------------------------------------------------------
-- Non-owning staff cannot mark another hotel's reservation paid
-- ---------------------------------------------------------------------------
-- The seeded guest (a plain guest, not this hotel's staff) is not authorized.
delete from public.reservations;
insert into public.reservations
  (id, hotel_id, room_id, guest_id, status, check_in, check_out,
   hold_expires_at, confirmation_code)
values ('40000000-0000-0000-0000-000000000002',
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001',
        'held', current_date + 30, current_date + 32,
        now() + interval '10 minutes', 'HZ-PAYTEST2');

select throws_ok(
  $$select public.mark_reservation_paid(
      '00000000-0000-0000-0000-000000000001',
      '40000000-0000-0000-0000-000000000002')$$,
  'not_authorized',
  'a non-owning actor cannot mark a reservation paid'
);

-- ---------------------------------------------------------------------------
-- A missing reservation is refused
-- ---------------------------------------------------------------------------
select throws_ok(
  $$select public.mark_reservation_paid(
      '00000000-0000-0000-0000-000000000002',
      '40000000-0000-0000-0000-0000000000ff')$$,
  'reservation_not_found',
  'marking a non-existent reservation paid is refused'
);

-- ---------------------------------------------------------------------------
-- A terminal reservation is not payable
-- ---------------------------------------------------------------------------
-- A rejected/cancelled/expired reservation must not be resurrected by a payment.
delete from public.reservations;
insert into public.reservations
  (id, hotel_id, room_id, guest_id, status, check_in, check_out,
   hold_expires_at, confirmation_code)
values ('40000000-0000-0000-0000-000000000004',
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001',
        'rejected', current_date + 30, current_date + 32,
        null, 'HZ-PAYTEST4');

select throws_ok(
  $$select public.mark_reservation_paid(
      '00000000-0000-0000-0000-000000000002',
      '40000000-0000-0000-0000-000000000004')$$,
  'reservation_not_payable',
  'a terminal (rejected) reservation cannot be marked paid'
);

-- ---------------------------------------------------------------------------
-- An expired hold is not payable (query-time expiry, BE-403)
-- ---------------------------------------------------------------------------
delete from public.reservations;
insert into public.reservations
  (id, hotel_id, room_id, guest_id, status, check_in, check_out,
   hold_expires_at, confirmation_code)
values ('40000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001',
        'held', current_date + 30, current_date + 32,
        now() - interval '1 minute', 'HZ-PAYTEST3');

select throws_ok(
  $$select public.mark_reservation_paid(
      '00000000-0000-0000-0000-000000000002',
      '40000000-0000-0000-0000-000000000003')$$,
  'reservation_not_payable',
  'an expired hold cannot be marked paid'
);

select * from finish();

rollback;
