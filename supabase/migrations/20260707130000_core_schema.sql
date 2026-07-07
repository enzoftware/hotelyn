-- BE-201 · Core schema migration
-- BE-202 · PostGIS geometry column for hotel location
--
-- Normalized tables for hotels, rooms, reservations, and user profiles. This is
-- the single data foundation every later feature builds on, so constraints are
-- expressed at the DB layer (enums, FKs, NOT NULL, checks) rather than left to
-- the app to enforce.
--
-- Identity lives in Supabase's `auth.users`. App-specific attributes (role,
-- hotel ownership) live in `profiles`, linked 1:1 to `auth.users` — never in a
-- parallel custom users table.

-- ---------------------------------------------------------------------------
-- Enum types
-- ---------------------------------------------------------------------------

-- Who a profile is and what they may do. Guests book; hotel_staff manage a
-- single hotel's rooms/reservations; admin oversees everything.
create type public.user_role as enum ('guest', 'hotel_staff', 'admin');

-- Lifecycle of a reservation. Constrained at the DB layer so a buggy or hostile
-- client can never persist an out-of-set status.
--   held      – temporarily reserved while the guest completes checkout
--   confirmed – payment accepted, booking guaranteed
--   cancelled – withdrawn by the guest
--   rejected  – declined by the hotel
--   expired   – hold lapsed before confirmation
create type public.reservation_status as enum (
  'held',
  'confirmed',
  'cancelled',
  'rejected',
  'expired'
);

-- ---------------------------------------------------------------------------
-- Shared updated_at trigger
-- ---------------------------------------------------------------------------

-- Keeps `updated_at` honest without trusting the client to send it.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- hotels
-- ---------------------------------------------------------------------------

create table public.hotels (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text,
  address     text,
  city        text not null,
  country     text not null,
  -- BE-202: real PostGIS point (SRID 4326 / WGS 84) instead of two hand-rolled
  -- float columns. Stored as geometry; metric ("within N metres") proximity
  -- search casts to geography per query (see the geography GiST index below).
  location    extensions.geometry(Point, 4326),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

comment on column public.hotels.location is
  'WGS 84 point (lon, lat). Query with ST_DWithin against a GiST index; '
  'cast to geography for distances in metres.';

-- GiST index on the raw geometry: nearest-neighbour ordering, bounding-box and
-- degree-unit ST_DWithin.
create index hotels_location_gix on public.hotels using gist (location);

-- Functional GiST index on the geography cast so metre-accurate proximity
-- queries (ST_DWithin(location::geography, point::geography, metres)) are also
-- index-accelerated rather than degree-based and latitude-dependent.
create index hotels_location_geog_gix
  on public.hotels using gist ((location::extensions.geography));

create trigger hotels_set_updated_at
  before update on public.hotels
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- profiles (extends auth.users)
-- ---------------------------------------------------------------------------

create table public.profiles (
  -- 1:1 with the Supabase auth user; deleting the auth user removes the profile.
  id         uuid primary key references auth.users (id) on delete cascade,
  full_name  text,
  role       public.user_role not null default 'guest',
  -- Nullable hotel-ownership link: set for hotel_staff, null for guests/admin.
  -- ON DELETE SET NULL so removing a hotel does not orphan the FK.
  hotel_id   uuid references public.hotels (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index profiles_hotel_id_idx on public.profiles (hotel_id);

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- rooms
-- ---------------------------------------------------------------------------

create table public.rooms (
  id              uuid primary key default gen_random_uuid(),
  -- A room cannot exist without its hotel; cascading delete prevents orphans.
  hotel_id        uuid not null references public.hotels (id) on delete cascade,
  name            text not null,
  room_type       text not null,
  capacity        integer not null default 1 check (capacity > 0),
  price_per_night numeric(10, 2) not null check (price_per_night >= 0),
  is_available    boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  -- Target for reservations' composite FK, so a reservation's room_id and
  -- hotel_id can never disagree (tenant-scoping integrity).
  constraint rooms_id_hotel_id_key unique (id, hotel_id)
);

create index rooms_hotel_id_idx on public.rooms (hotel_id);

create trigger rooms_set_updated_at
  before update on public.rooms
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- reservations
-- ---------------------------------------------------------------------------

create table public.reservations (
  id         uuid primary key default gen_random_uuid(),
  hotel_id   uuid not null references public.hotels (id) on delete cascade,
  room_id    uuid not null,
  -- The booking guest, tied to their profile (and therefore to auth.users).
  guest_id   uuid not null references public.profiles (id) on delete cascade,
  status     public.reservation_status not null default 'held',
  check_in   date not null,
  check_out  date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reservations_dates_ordered check (check_out > check_in),
  -- Composite FK guarantees the room belongs to this hotel; a reservation can
  -- never reference a room from a different hotel.
  constraint reservations_room_hotel_fk
    foreign key (room_id, hotel_id)
    references public.rooms (id, hotel_id) on delete cascade
);

-- Supports the BE-304 recommended-ranking query, which filters by hotel and
-- status and orders by recency, without a full table scan.
create index reservations_hotel_status_created_idx
  on public.reservations (hotel_id, status, created_at);

-- Guest-facing "my reservations" lookups.
create index reservations_guest_id_idx on public.reservations (guest_id);

create trigger reservations_set_updated_at
  before update on public.reservations
  for each row execute function public.set_updated_at();
