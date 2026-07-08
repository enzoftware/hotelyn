-- BE-203 · Automated proof of the Row Level Security boundary.
--
-- Run with: `supabase test db` (executes every *_test.sql under supabase/tests
-- inside a rolled-back transaction against the local stack).
--
-- The core assertion the ticket demands: a session authenticated as Hotel A
-- staff must see ZERO rows of, and be unable to write, Hotel B's rooms and
-- reservations. We also spot-check the guest read/write boundary.
--
-- throws_ok asserts on SQLSTATE 42501 (insufficient_privilege) with a NULL
-- message so the tests do not break on a differently-localized error string.

begin;

select plan(14);

-- ---------------------------------------------------------------------------
-- Fixtures (Hotel A = staff's own hotel, Hotel B = a foreign hotel)
-- ---------------------------------------------------------------------------
-- Seeded ids (see supabase/seed.sql):
--   Hotel A  = Lima   10000000-...0001  (owned by staff 000...0002)
--   Hotel B  = Mexico 10000000-...0002
--   Room B   = 200...0003 (Mexico), Room A(available) = 200...0001 (Lima)

-- Inserted as the table owner (bypasses RLS) so the boundary assertions below
-- have foreign rows to (fail to) reach.

-- A reservation on Hotel B, so "select foreign reservations" has a target.
insert into public.reservations (id, hotel_id, room_id, guest_id, status, check_in, check_out)
values (
  '30000000-0000-0000-0000-0000000000b1',
  '10000000-0000-0000-0000-000000000002',           -- Hotel B
  '20000000-0000-0000-0000-000000000003',           -- Room B
  '00000000-0000-0000-0000-000000000001',           -- test guest
  'confirmed', date '2026-09-01', date '2026-09-03'
);

-- A reservation on Hotel A owned by the STAFF profile, so we can prove a guest
-- cannot read a reservation that is not theirs even at a hotel they can browse.
-- Status is 'cancelled' (an inactive status, outside the BE-401 active-hold
-- predicate) so it does not occupy Room A1's single active slot — test 14 below
-- inserts the guest's own *held* reservation on A1. Its visibility (what this
-- fixture actually asserts) does not depend on status.
insert into public.reservations (id, hotel_id, room_id, guest_id, status, check_in, check_out)
values (
  '30000000-0000-0000-0000-0000000000b2',
  '10000000-0000-0000-0000-000000000001',           -- Hotel A
  '20000000-0000-0000-0000-000000000001',           -- Room A1 (available)
  '00000000-0000-0000-0000-000000000002',           -- staff profile, not the guest
  'cancelled', date '2026-09-10', date '2026-09-12'
);

-- ---------------------------------------------------------------------------
-- Authenticate as Hotel A staff
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-000000000002","role":"authenticated"}';

-- Sanity: staff CAN see their own hotel's rooms (both available + unavailable).
select is(
  (select count(*)::int from public.rooms
     where hotel_id = '10000000-0000-0000-0000-000000000001'),
  2,
  'Hotel A staff sees all of their own hotel rooms'
);

-- Boundary #1: staff sees ZERO of Hotel B's *unavailable* rooms.
select is(
  (select count(*)::int from public.rooms
     where hotel_id = '10000000-0000-0000-0000-000000000002'
       and is_available = false),
  0,
  'Hotel A staff cannot see Hotel B unavailable rooms'
);

-- Boundary #2: staff sees ZERO of Hotel B's reservations.
select is(
  (select count(*)::int from public.reservations
     where hotel_id = '10000000-0000-0000-0000-000000000002'),
  0,
  'Hotel A staff cannot read Hotel B reservations'
);

-- Staff CAN see their own hotel's reservations (seeded booking + fixture b2).
select is(
  (select count(*)::int from public.reservations
     where hotel_id = '10000000-0000-0000-0000-000000000001'),
  2,
  'Hotel A staff can read their own hotel reservations'
);

-- Boundary #3: staff UPDATE of a Hotel B room affects ZERO rows.
with upd as (
  update public.rooms set price_per_night = 1.00
   where id = '20000000-0000-0000-0000-000000000003'
  returning 1
)
select is(
  (select count(*)::int from upd),
  0,
  'Hotel A staff UPDATE of a Hotel B room is rejected (0 rows)'
);

-- Boundary #4: staff DELETE of a Hotel B room affects ZERO rows.
with del as (
  delete from public.rooms
   where id = '20000000-0000-0000-0000-000000000003'
  returning 1
)
select is(
  (select count(*)::int from del),
  0,
  'Hotel A staff DELETE of a Hotel B room is rejected (0 rows)'
);

-- Boundary #5: staff INSERT of a room into Hotel B is rejected.
select throws_ok(
  $$insert into public.rooms (hotel_id, name, room_type, price_per_night)
    values ('10000000-0000-0000-0000-000000000002', 'Rogue', 'double', 5.00)$$,
  '42501',
  NULL,
  'Hotel A staff INSERT into Hotel B is rejected'
);

-- Staff CAN update their own hotel's room.
with upd as (
  update public.rooms set price_per_night = price_per_night
   where id = '20000000-0000-0000-0000-000000000001'
  returning 1
)
select is(
  (select count(*)::int from upd),
  1,
  'Hotel A staff CAN update their own hotel room'
);

-- ---------------------------------------------------------------------------
-- Authenticate as the guest
-- ---------------------------------------------------------------------------
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated"}';

-- A guest can browse available rooms broadly (all seeded available rooms).
select cmp_ok(
  (select count(*)::int from public.rooms where is_available = true),
  '>=', 6,
  'Guest can browse available rooms broadly'
);

-- ...but a guest cannot see a seeded UNAVAILABLE room (Lima's City View 102).
select is(
  (select count(*)::int from public.rooms
     where id = '20000000-0000-0000-0000-000000000002'),
  0,
  'Guest cannot see an unavailable room'
);

-- Boundary #6: a guest cannot read a reservation that is not theirs, even at a
-- hotel they can browse (fixture b2 is owned by the staff profile).
select is(
  (select count(*)::int from public.reservations
     where guest_id = '00000000-0000-0000-0000-000000000002'),
  0,
  'Guest cannot read another user''s reservation'
);

-- Boundary #7: a guest cannot escalate privilege by writing their own role.
-- `role`/`hotel_id` are not granted to `authenticated`, so the write is a
-- column-privilege error, not merely an RLS row filter.
select throws_ok(
  $$update public.profiles set role = 'admin'
     where id = '00000000-0000-0000-0000-000000000001'$$,
  '42501',
  NULL,
  'Guest cannot escalate their own role to admin'
);

-- A guest cannot insert a reservation attributed to someone else.
select throws_ok(
  $$insert into public.reservations (hotel_id, room_id, guest_id, status, check_in, check_out)
    values ('10000000-0000-0000-0000-000000000001',
            '20000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000002', -- not the guest
            'held', date '2026-10-01', date '2026-10-02')$$,
  '42501',
  NULL,
  'Guest cannot insert a reservation in another user''s name'
);

-- A guest CAN insert a reservation in their own name (initial held state).
select lives_ok(
  $$insert into public.reservations (hotel_id, room_id, guest_id, status, check_in, check_out)
    values ('10000000-0000-0000-0000-000000000001',
            '20000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000001', -- the guest themself
            'held', date '2026-10-01', date '2026-10-02')$$,
  'Guest CAN insert a reservation in their own name'
);

select * from finish();

rollback;
