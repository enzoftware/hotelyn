-- BE-301 / BE-302 / BE-304 · Geolocation search & recommendations.
--
-- Run with: `supabase test db`. These exercise the three SQL functions'
-- behaviour directly (they are SECURITY DEFINER, so no role juggling is needed);
-- RLS itself is covered by rls_test.sql.
--
-- Seeded coordinates used below (lon, lat):
--   Lima   10000000-...0001  (-77.0428, -12.1219)
--   Bogota 10000000-...0003  (-74.0546,   4.6663)
--   NY     10000000-...0005  (-73.9840,  40.7536)
--   Miami  10000000-...0006  (-80.1918,  25.7617)

begin;

select plan(15);

-- Clean slate for reservation-dependent assertions; rolled back at the end.
delete from public.reservations;

-- ---------------------------------------------------------------------------
-- Tunable window constant (BE-304)
-- ---------------------------------------------------------------------------
select is(
  public.recommendation_window_days(), 30,
  'recommendation window is the documented 30-day constant'
);

-- ---------------------------------------------------------------------------
-- BE-301 · nearby_hotels
-- ---------------------------------------------------------------------------

-- Nearest-first ordering: the closest hotel to a point in Lima is the Lima one.
select is(
  (select city from public.nearby_hotels(-12.11, -77.03, 20000) limit 1),
  'Lima',
  'nearby_hotels returns the nearest hotel first'
);

-- Distance is computed in kilometres and is small for the ~2 km-away Lima hotel.
select cmp_ok(
  (select distance_km from public.nearby_hotels(-12.11, -77.03, 20000)
     where city = 'Lima'),
  '<', 5.0::double precision,
  'nearby_hotels reports distance in km (Lima ~2 km away)'
);

-- Radius filter (ST_DWithin): a 100 km radius around Lima yields only Lima.
select is(
  (select count(*)::int from public.nearby_hotels(-12.11, -77.03, 100)),
  1,
  'nearby_hotels radius filter excludes out-of-range hotels'
);

-- No hotels in range → empty list, not an error.
select is(
  (select count(*)::int from public.nearby_hotels(0, 0, 10)),
  0,
  'nearby_hotels returns an empty set when nothing is in radius'
);

-- Ordering is strictly non-decreasing by distance.
select is(
  (select bool_and(distance_km >= lag_km) from (
     select distance_km, lag(distance_km) over (order by distance_km) as lag_km
     from public.nearby_hotels(-12.11, -77.03, 20000)
   ) t where lag_km is not null),
  true,
  'nearby_hotels rows are ordered nearest-first'
);

-- ---------------------------------------------------------------------------
-- BE-302 · room availability
-- ---------------------------------------------------------------------------
-- Bogota room 200...0005 is flagged available and has no reservations yet.

-- An EXPIRED hold does not block: the room still reads available even though the
-- reservation row is status=held (the core BE-302 acceptance criterion).
insert into public.reservations (id, hotel_id, room_id, guest_id, status, check_in, check_out, hold_expires_at)
values ('30000000-0000-0000-0000-0000000000e1',
        '10000000-0000-0000-0000-000000000003',
        '20000000-0000-0000-0000-000000000005',
        '00000000-0000-0000-0000-000000000001',
        'held', date '2026-08-01', date '2026-08-02', now() - interval '1 hour');

select is(
  public.is_room_available_now('20000000-0000-0000-0000-000000000005'),
  true,
  'a room whose only hold is EXPIRED reads as available'
);

-- Same room, now with an ACTIVE (future) hold → unavailable.
update public.reservations set hold_expires_at = now() + interval '1 hour'
 where id = '30000000-0000-0000-0000-0000000000e1';

select is(
  public.is_room_available_now('20000000-0000-0000-0000-000000000005'),
  false,
  'a room with an active unexpired hold reads as unavailable'
);

-- A room flagged is_available = false is never available_now.
select is(
  (select available_now from public.rooms_with_availability('10000000-0000-0000-0000-000000000001')
     where id = '20000000-0000-0000-0000-000000000002'),
  false,
  'a room flagged unavailable is never available_now'
);

-- rooms_with_availability reports available_now = true for a truly free room.
select is(
  (select available_now from public.rooms_with_availability('10000000-0000-0000-0000-000000000001')
     where id = '20000000-0000-0000-0000-000000000001'),
  true,
  'rooms_with_availability reports a free room as available_now'
);

delete from public.reservations;

-- ---------------------------------------------------------------------------
-- BE-304 · recommended_hotels
-- ---------------------------------------------------------------------------

-- A second Bogota room so the two confirmed bookings below can live on distinct
-- rooms — the BE-401 partial unique index allows only one active (held/confirmed)
-- reservation per room, and popularity counts by hotel, not room. Rolled back
-- with the surrounding transaction, so the shared seed's room counts are intact.
insert into public.rooms (id, hotel_id, name, room_type, capacity, price_per_night, is_available)
values ('20000000-0000-0000-0000-0000000000b0', '10000000-0000-0000-0000-000000000003',
        'Boutique Twin', 'twin', 2, 150.00, true);

-- Two confirmed bookings at Bogota (on its two rooms), one at Lima, all in window.
insert into public.reservations (hotel_id, room_id, guest_id, status, check_in, check_out, hold_expires_at)
values
  ('10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000005',
   '00000000-0000-0000-0000-000000000001', 'confirmed', date '2026-08-01', date '2026-08-03', now() + interval '10 days'),
  ('10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-0000000000b0',
   '00000000-0000-0000-0000-000000000001', 'confirmed', date '2026-08-04', date '2026-08-06', now() + interval '10 days'),
  ('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001', 'confirmed', date '2026-08-01', date '2026-08-03', now() + interval '10 days');

-- Popularity ranking: Bogota (2 confirmed) outranks Lima (1) regardless of the
-- fact that Lima is nearer the query point.
select is(
  (select city from public.recommended_hotels(-12.11, -77.03, 20000) limit 1),
  'Bogota',
  'recommended_hotels ranks the more-booked hotel first, over a nearer one'
);

select is(
  (select popularity from public.recommended_hotels(-12.11, -77.03, 20000)
     where city = 'Bogota'),
  2::bigint,
  'recommended_hotels counts confirmed reservations in the window'
);

-- Non-confirmed statuses and out-of-window bookings do NOT count.
insert into public.reservations (hotel_id, room_id, guest_id, status, check_in, check_out, created_at)
values
  ('10000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000009',
   '00000000-0000-0000-0000-000000000001', 'cancelled', date '2026-08-01', date '2026-08-02', now()),
  ('10000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000009',
   '00000000-0000-0000-0000-000000000001', 'rejected',  date '2026-08-01', date '2026-08-02', now()),
  ('10000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000009',
   '00000000-0000-0000-0000-000000000001', 'expired',   date '2026-08-01', date '2026-08-02', now()),
  ('10000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000009',
   '00000000-0000-0000-0000-000000000001', 'confirmed', date '2026-08-01', date '2026-08-02', now() - interval '60 days');

select is(
  (select popularity from public.recommended_hotels(25.76, -80.19, 20000)
     where city = 'Miami'),
  0::bigint,
  'rejected/expired/cancelled and out-of-window bookings do not count'
);

-- Cold-start: with zero qualifying reservations, recommended falls back to
-- nearby filtered to available-now — non-empty and nearest-first.
delete from public.reservations;

select cmp_ok(
  (select count(*)::int from public.recommended_hotels(-12.11, -77.03, 20000)),
  '>', 0,
  'cold-start recommended_hotels is never empty when hotels are in range'
);

select is(
  (select city from public.recommended_hotels(-12.11, -77.03, 20000) limit 1),
  'Lima',
  'cold-start recommended_hotels falls back to nearest-first'
);

select * from finish();

rollback;
