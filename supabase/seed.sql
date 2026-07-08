-- BE-204 · Seed data script
--
-- Idempotent, deterministic seed so local dev and integration tests always start
-- from realistic, known data. Every id and coordinate is fixed so tests can
-- assert against them, and every statement is re-runnable (ON CONFLICT), so
-- `supabase db reset` — and a manual re-run — both succeed with no follow-up.
--
-- Contents:
--   * 6 hotels across real LatAm + North America launch cities (BE-202 coords)
--   * rooms with a deliberate mix of available / unavailable
--   * one test guest        (guest@hotelyn.test)
--   * one test hotel-staff  (staff@hotelyn.test), owning the Lima hotel
--
-- Test account password (local only): "password123".

-- PostGIS + pgcrypto (crypt/gen_salt) live in the extensions schema.
set search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- Auth users (Supabase identity)
-- ---------------------------------------------------------------------------
-- Inserted directly for local dev; on hosted environments real users sign up via
-- email OTP. Fixed UUIDs let profiles/reservations reference them deterministically.

-- The token/change columns are set to '' (not left NULL): GoTrue's Go scanner
-- errors with "converting NULL to string is unsupported" when a directly-inserted
-- row is used to sign in, so empty strings keep these accounts loginable locally.
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data,
  confirmation_token, recovery_token, email_change, email_change_token_new
)
values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-000000000001',
    'authenticated', 'authenticated', 'guest@hotelyn.test',
    crypt('password123', gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Test Guest"}',
    '', '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-000000000002',
    'authenticated', 'authenticated', 'staff@hotelyn.test',
    crypt('password123', gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Test Staff"}',
    '', '', '', ''
  )
on conflict (id) do nothing;

-- Email/password identities so the seeded accounts can actually sign in locally.
insert into auth.identities (
  id, user_id, provider_id, identity_data, provider,
  last_sign_in_at, created_at, updated_at
)
values
  (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    '{"sub":"00000000-0000-0000-0000-000000000001","email":"guest@hotelyn.test"}',
    'email', now(), now(), now()
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000002',
    '{"sub":"00000000-0000-0000-0000-000000000002","email":"staff@hotelyn.test"}',
    'email', now(), now(), now()
  )
on conflict (provider_id, provider) do nothing;

-- ---------------------------------------------------------------------------
-- Hotels (real launch-city coordinates, lon/lat WGS 84)
-- ---------------------------------------------------------------------------

insert into public.hotels (id, name, description, address, city, country, location)
values
  (
    '10000000-0000-0000-0000-000000000001',
    'Miraflores Bay Hotel', 'Oceanfront rooms above the Costa Verde.',
    'Malecon de la Reserva 615', 'Lima', 'Peru',
    st_setsrid(st_makepoint(-77.0428, -12.1219), 4326)
  ),
  (
    '10000000-0000-0000-0000-000000000002',
    'Reforma Grand', 'Business hotel on Paseo de la Reforma.',
    'Paseo de la Reforma 500', 'Mexico City', 'Mexico',
    st_setsrid(st_makepoint(-99.1682, 19.4270), 4326)
  ),
  (
    '10000000-0000-0000-0000-000000000003',
    'Zona Rosa Suites', 'Boutique stay in the heart of Bogota.',
    'Carrera 13 85-32', 'Bogota', 'Colombia',
    st_setsrid(st_makepoint(-74.0546, 4.6663), 4326)
  ),
  (
    '10000000-0000-0000-0000-000000000004',
    'Recoleta Palace', 'Classic elegance near the Recoleta cemetery.',
    'Av. Alvear 1900', 'Buenos Aires', 'Argentina',
    st_setsrid(st_makepoint(-58.3920, -34.5875), 4326)
  ),
  (
    '10000000-0000-0000-0000-000000000005',
    'Midtown Central', 'Steps from Bryant Park and Times Square.',
    '500 5th Ave', 'New York', 'United States',
    st_setsrid(st_makepoint(-73.9840, 40.7536), 4326)
  ),
  (
    '10000000-0000-0000-0000-000000000006',
    'Brickell Waterside', 'Modern tower overlooking Biscayne Bay.',
    '1300 Brickell Bay Dr', 'Miami', 'United States',
    st_setsrid(st_makepoint(-80.1918, 25.7617), 4326)
  )
on conflict (id) do update set
  name        = excluded.name,
  description = excluded.description,
  address     = excluded.address,
  city        = excluded.city,
  country     = excluded.country,
  location    = excluded.location;

-- ---------------------------------------------------------------------------
-- Profiles (extends auth.users)
-- ---------------------------------------------------------------------------

insert into public.profiles (id, full_name, role, hotel_id)
values
  ('00000000-0000-0000-0000-000000000001', 'Test Guest', 'guest', null),
  (
    '00000000-0000-0000-0000-000000000002', 'Test Staff', 'hotel_staff',
    '10000000-0000-0000-0000-000000000001' -- owns the Lima hotel
  )
on conflict (id) do update set
  full_name = excluded.full_name,
  role      = excluded.role,
  hotel_id  = excluded.hotel_id;

-- ---------------------------------------------------------------------------
-- Rooms (deliberate mix of available / unavailable)
-- ---------------------------------------------------------------------------

insert into public.rooms (id, hotel_id, name, room_type, capacity, price_per_night, is_available)
values
  -- Lima (owned by test staff): one available, one occupied.
  ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'Ocean View 101', 'double', 2, 180.00, true),
  ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'City View 102',  'single', 1,  90.00, false),
  -- Mexico City
  ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', 'Executive Suite', 'suite',  4, 320.00, true),
  ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002', 'Standard 210',    'double', 2, 140.00, false),
  -- Bogota
  ('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000003', 'Boutique King',   'double', 2, 160.00, true),
  -- Buenos Aires
  ('20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000004', 'Palace Double',   'double', 2, 210.00, true),
  ('20000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000004', 'Palace Single',   'single', 1, 120.00, false),
  -- New York
  ('20000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000005', 'Midtown Queen',   'double', 2, 290.00, true),
  -- Miami
  ('20000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000006', 'Bay View Suite',  'suite',  3, 350.00, true),
  ('20000000-0000-0000-0000-00000000000a', '10000000-0000-0000-0000-000000000006', 'City Twin',       'twin',   2, 175.00, false)
on conflict (id) do update set
  hotel_id        = excluded.hotel_id,
  name            = excluded.name,
  room_type       = excluded.room_type,
  capacity        = excluded.capacity,
  price_per_night = excluded.price_per_night,
  is_available    = excluded.is_available;

-- ---------------------------------------------------------------------------
-- Reservations (one confirmed booking for the test guest at the Lima hotel)
-- ---------------------------------------------------------------------------

insert into public.reservations (id, hotel_id, room_id, guest_id, status, check_in, check_out, hold_expires_at)
values
  (
    '30000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000001',
    -- Confirmed booking that blocks the room through check-out (BE-302).
    'confirmed', date '2026-08-01', date '2026-08-05', timestamptz '2026-08-05 00:00:00+00'
  )
on conflict (id) do update set
  hotel_id        = excluded.hotel_id,
  room_id         = excluded.room_id,
  guest_id        = excluded.guest_id,
  status          = excluded.status,
  check_in        = excluded.check_in,
  check_out       = excluded.check_out,
  hold_expires_at = excluded.hold_expires_at;
