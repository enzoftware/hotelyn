-- BE-501 / BE-502 / BE-503 / BE-504 · Hotel-side inventory & realtime (EPIC-05).
--
-- Run with: `supabase test db`. Exercises the staff RPCs' behaviour and
-- ownership guards directly (they are SECURITY DEFINER and take the acting
-- profile as an argument, so no role juggling is needed), plus the realtime
-- publication membership.
--
-- Seeded ids (see supabase/seed.sql):
--   Lima hotel   10000000-...0001, staff 00000000-...0002 (owns Lima)
--   Lima room A1 20000000-...0001 (available), A2 20000000-...0002 (unavailable)
--   Bogota hotel 10000000-...0003, room 20000000-...0005 (available)
--   Guest        00000000-...0001

begin;

select plan(22);

delete from public.reservations;

-- ---------------------------------------------------------------------------
-- BE-501 · staff_room_list
-- ---------------------------------------------------------------------------

-- Lima staff see exactly their own hotel's two rooms.
select is(
  (select count(*)::int from public.staff_room_list(
     '00000000-0000-0000-0000-000000000002')),
  2,
  'staff_room_list returns the acting staff hotel''s rooms'
);

-- ...and only their hotel — never Bogota's room.
select is(
  (select count(*)::int from public.staff_room_list(
     '00000000-0000-0000-0000-000000000002')
   where hotel_id <> '10000000-0000-0000-0000-000000000001'),
  0,
  'staff_room_list is scoped to the actor''s own hotel'
);

-- A guest cannot list any inventory.
select throws_ok(
  $$select public.staff_room_list('00000000-0000-0000-0000-000000000001')$$,
  'not_authorized',
  'a guest cannot call staff_room_list'
);

-- A hotel_staff with no hotel link must be rejected, not shown every hotel.
update public.profiles set hotel_id = null
 where id = '00000000-0000-0000-0000-000000000002';

select throws_ok(
  $$select public.staff_room_list('00000000-0000-0000-0000-000000000002')$$,
  'not_authorized',
  'a hotel_staff with a null hotel_id is rejected (no unscoped listing)'
);

update public.profiles set hotel_id = '10000000-0000-0000-0000-000000000001'
 where id = '00000000-0000-0000-0000-000000000002';

-- Derived status: A2 is is_available=false → 'unavailable'.
select is(
  (select status from public.staff_room_list(
     '00000000-0000-0000-0000-000000000002')
   where id = '20000000-0000-0000-0000-000000000002'),
  'unavailable',
  'a staff-disabled room reports status = unavailable'
);

-- A1 is free → 'available'.
select is(
  (select status from public.staff_room_list(
     '00000000-0000-0000-0000-000000000002')
   where id = '20000000-0000-0000-0000-000000000001'),
  'available',
  'a free room reports status = available'
);

-- An active hold on A1 → 'held'.
insert into public.reservations
  (hotel_id, room_id, guest_id, status, check_in, check_out, hold_expires_at)
values ('10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001',
        'held', current_date + 10, current_date + 12, now() + interval '10 min');

select is(
  (select status from public.staff_room_list(
     '00000000-0000-0000-0000-000000000002')
   where id = '20000000-0000-0000-0000-000000000001'),
  'held',
  'a room with an active hold reports status = held'
);

-- Confirmed booking → 'occupied'. Confirm through the REAL RPC (which nulls
-- hold_expires_at), so this proves 'occupied' does not depend on a live expiry —
-- the confirmed-booking regression CodeRabbit caught.
select confirm_reservation(
  '00000000-0000-0000-0000-000000000002',
  (select id from public.reservations
     where room_id = '20000000-0000-0000-0000-000000000001' and status = 'held')
);

select is(
  (select hold_expires_at from public.reservations
     where room_id = '20000000-0000-0000-0000-000000000001'),
  null,
  'confirm_reservation nulls hold_expires_at (guards against a live-expiry gate)'
);

select is(
  (select status from public.staff_room_list(
     '00000000-0000-0000-0000-000000000002')
   where id = '20000000-0000-0000-0000-000000000001'),
  'occupied',
  'a confirmed booking (expiry nulled) still reports status = occupied'
);

-- An EXPIRED hold does not count: the room reads 'available' again.
update public.reservations
   set status = 'held', hold_expires_at = now() - interval '1 min'
 where room_id = '20000000-0000-0000-0000-000000000001';

select is(
  (select status from public.staff_room_list(
     '00000000-0000-0000-0000-000000000002')
   where id = '20000000-0000-0000-0000-000000000001'),
  'available',
  'an expired hold does not change status from available (query-time expiry)'
);

delete from public.reservations;

-- ---------------------------------------------------------------------------
-- BE-502 · set_room_availability
-- ---------------------------------------------------------------------------

-- Staff may disable their own room.
select is(
  (select is_available from public.set_room_availability(
     '00000000-0000-0000-0000-000000000002',
     '20000000-0000-0000-0000-000000000001', false)),
  false,
  'staff can set their own room unavailable'
);

-- ...and re-enable it when nothing blocks it.
select is(
  (select is_available from public.set_room_availability(
     '00000000-0000-0000-0000-000000000002',
     '20000000-0000-0000-0000-000000000001', true)),
  true,
  'staff can re-enable a room with no active reservation'
);

-- A guest cannot toggle a room.
select throws_ok(
  $$select public.set_room_availability(
      '00000000-0000-0000-0000-000000000001',
      '20000000-0000-0000-0000-000000000001', false)$$,
  'not_authorized',
  'a guest cannot toggle room availability'
);

-- Cross-hotel: Lima staff cannot toggle a Bogota room.
select throws_ok(
  $$select public.set_room_availability(
      '00000000-0000-0000-0000-000000000002',
      '20000000-0000-0000-0000-000000000005', false)$$,
  'not_authorized',
  'staff cannot toggle another hotel''s room'
);

-- Double-allocation guard: cannot set available while an active hold exists.
insert into public.reservations
  (hotel_id, room_id, guest_id, status, check_in, check_out, hold_expires_at)
values ('10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001',
        'held', current_date + 10, current_date + 12, now() + interval '10 min');

update public.rooms set is_available = false
 where id = '20000000-0000-0000-0000-000000000001';

select throws_ok(
  $$select public.set_room_availability(
      '00000000-0000-0000-0000-000000000002',
      '20000000-0000-0000-0000-000000000001', true)$$,
  'room_has_active_reservation',
  'cannot re-enable a room that has an active hold (double-allocation guard)'
);

-- Same guard for a CONFIRMED booking (hold_expires_at nulled): it must still
-- block a re-enable, or staff could double-allocate a booked room.
update public.reservations
   set status = 'confirmed', hold_expires_at = null
 where room_id = '20000000-0000-0000-0000-000000000001';

select throws_ok(
  $$select public.set_room_availability(
      '00000000-0000-0000-0000-000000000002',
      '20000000-0000-0000-0000-000000000001', true)$$,
  'room_has_active_reservation',
  'cannot re-enable a room with a confirmed booking (expiry nulled)'
);

delete from public.reservations;

-- ---------------------------------------------------------------------------
-- BE-503 · confirm_reservation / reject_reservation
-- ---------------------------------------------------------------------------

-- A confirmable, active hold on a Lima room.
insert into public.reservations (id, hotel_id, room_id, guest_id, status, check_in, check_out, hold_expires_at)
values ('40000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000001',
        'held', current_date + 10, current_date + 12, now() + interval '10 min');

-- Confirm: status → confirmed, expiry cleared.
select is(
  (select status from public.confirm_reservation(
     '00000000-0000-0000-0000-000000000002',
     '40000000-0000-0000-0000-000000000001')),
  'confirmed'::public.reservation_status,
  'confirm_reservation moves a held reservation to confirmed'
);

select is(
  (select hold_expires_at from public.reservations
     where id = '40000000-0000-0000-0000-000000000001'),
  null,
  'confirming clears hold_expires_at (a confirmed booking is not a ticking hold)'
);

-- Reject the confirmed reservation: status → rejected, room freed immediately.
select is(
  (select status from public.reject_reservation(
     '00000000-0000-0000-0000-000000000002',
     '40000000-0000-0000-0000-000000000001')),
  'rejected'::public.reservation_status,
  'reject_reservation moves a reservation to rejected'
);

-- A guest cannot confirm.
insert into public.reservations (id, hotel_id, room_id, guest_id, status, check_in, check_out, hold_expires_at)
values ('40000000-0000-0000-0000-000000000002',
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000001',
        'held', current_date + 10, current_date + 12, now() + interval '10 min');

select throws_ok(
  $$select public.confirm_reservation(
      '00000000-0000-0000-0000-000000000001',
      '40000000-0000-0000-0000-000000000002')$$,
  'not_authorized',
  'a guest cannot confirm a reservation'
);

-- Confirming an already-expired hold fails clearly instead of resurrecting it.
update public.reservations set hold_expires_at = now() - interval '1 min'
 where id = '40000000-0000-0000-0000-000000000002';

select throws_ok(
  $$select public.confirm_reservation(
      '00000000-0000-0000-0000-000000000002',
      '40000000-0000-0000-0000-000000000002')$$,
  'hold_expired',
  'confirming an expired hold fails with hold_expired'
);

-- ---------------------------------------------------------------------------
-- BE-504 · realtime publication
-- ---------------------------------------------------------------------------

select is(
  (select count(*)::int from pg_publication_tables
     where pubname = 'supabase_realtime'
       and schemaname = 'public'
       and tablename = 'reservations'),
  1,
  'reservations is a member of the supabase_realtime publication'
);

select * from finish();

rollback;
