-- BE-301 · Nearby hotels function
-- BE-302 · Room availability query
-- BE-304 · Recommended hotels function
--
-- Geolocation search & recommendations (EPIC-03). Three read-only functions the
-- backend GraphQL layer calls; all are SECURITY DEFINER with a pinned
-- search_path so they can compute availability across every reservation (a guest
-- cannot see other guests' holds under RLS) while only ever returning public
-- catalogue data (hotels/rooms) — never another guest's reservation rows.

-- ---------------------------------------------------------------------------
-- BE-302 · hold_expires_at
-- ---------------------------------------------------------------------------
-- We use the free-tier, query-time expiry model (BE-403): a hold is not cleaned
-- up by a background job, so "available now" must ignore holds whose expiry has
-- already passed. Nullable: only active holds/bookings carry an expiry.
alter table public.reservations
  add column hold_expires_at timestamptz;

comment on column public.reservations.hold_expires_at is
  'When a held/confirmed reservation stops blocking the room. A row whose '
  'hold_expires_at is in the past no longer counts against availability, even '
  'if it is still status=held (query-time expiry, BE-403).';

-- Availability lookups scan reservations by room + status + expiry.
create index reservations_room_active_idx
  on public.reservations (room_id, status, hold_expires_at);

-- ---------------------------------------------------------------------------
-- Tunable constants
-- ---------------------------------------------------------------------------
-- The trailing popularity window (BE-304). A single documented definition so it
-- can be tuned in one place later.
create or replace function public.recommendation_window_days()
returns integer
language sql
immutable
as $$
  select 30;
$$;

comment on function public.recommendation_window_days() is
  'Trailing window (days) over which confirmed reservations count toward the '
  'recommended-hotels popularity signal (BE-304). Tune here.';

-- ---------------------------------------------------------------------------
-- BE-302 · room availability
-- ---------------------------------------------------------------------------

-- Is a single room bookable right now? Reusable by the search functions below.
-- available_now == room flagged available AND no held/confirmed reservation with
-- an unexpired hold blocks it.
create or replace function public.is_room_available_now(p_room_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, extensions
as $$
  select r.is_available
     and not exists (
       select 1
       from public.reservations res
       where res.room_id = r.id
         and res.status in ('held', 'confirmed')
         and res.hold_expires_at is not null
         and res.hold_expires_at > now()
     )
  from public.rooms r
  where r.id = p_room_id;
$$;

-- Every room (optionally scoped to one hotel) with a computed `available_now`.
-- Consumed via the backend data client — no availability SQL lives in UI code.
create or replace function public.rooms_with_availability(p_hotel_id uuid default null)
returns table (
  id              uuid,
  hotel_id        uuid,
  name            text,
  room_type       text,
  capacity        integer,
  price_per_night numeric,
  is_available    boolean,
  available_now   boolean
)
language sql
stable
security definer
set search_path = public, extensions
as $$
  select
    r.id,
    r.hotel_id,
    r.name,
    r.room_type,
    r.capacity,
    r.price_per_night,
    r.is_available,
    r.is_available
      and not exists (
        select 1
        from public.reservations res
        where res.room_id = r.id
          and res.status in ('held', 'confirmed')
          and res.hold_expires_at is not null
          and res.hold_expires_at > now()
      ) as available_now
  from public.rooms r
  where p_hotel_id is null or r.hotel_id = p_hotel_id
  order by r.hotel_id, r.name;
$$;

-- ---------------------------------------------------------------------------
-- BE-301 · nearby hotels
-- ---------------------------------------------------------------------------

-- Hotels within `radius_km` of (lat, lng), nearest-first, each with its great-
-- circle distance in km. ST_DWithin filters the radius (metres, via geography so
-- it is accurate near the poles/antimeridian); ST_Distance drives the ordering.
-- Returns zero rows (an empty list, not an error) when nothing is in range.
create or replace function public.nearby_hotels(
  lat       double precision,
  lng       double precision,
  radius_km double precision
)
returns table (
  id          uuid,
  name        text,
  description text,
  address     text,
  city        text,
  country     text,
  latitude    double precision,
  longitude   double precision,
  distance_km double precision
)
language sql
stable
security definer
set search_path = public, extensions
as $$
  with origin as (
    select st_setsrid(st_makepoint(lng, lat), 4326)::geography as g
  )
  select
    h.id,
    h.name,
    h.description,
    h.address,
    h.city,
    h.country,
    st_y(h.location::geometry) as latitude,
    st_x(h.location::geometry) as longitude,
    st_distance(h.location::geography, origin.g) / 1000.0 as distance_km
  from public.hotels h, origin
  where h.location is not null
    and st_dwithin(h.location::geography, origin.g, radius_km * 1000.0)
  order by st_distance(h.location::geography, origin.g);
$$;

-- ---------------------------------------------------------------------------
-- BE-304 · recommended hotels
-- ---------------------------------------------------------------------------

-- Popular-yet-nearby hotels: rank in-radius hotels by their count of `confirmed`
-- reservations booked in the trailing window (rejected/expired/cancelled never
-- count), breaking ties by proximity (nearest-first within equal rank).
--
-- Cold-start: at launch there are no confirmed reservations, so every hotel's
-- popularity is 0. In that case proximity must carry the experience, so we fall
-- back to the nearby_hotels result filtered to hotels that have at least one
-- available-now room — never empty (when hotels exist in range), never
-- arbitrarily ordered.
--
-- Future extension: a "most rated" signal is intentionally out of scope until
-- the Phase 2 ratings feature exists; it would blend in as an additional term.
create or replace function public.recommended_hotels(
  lat       double precision,
  lng       double precision,
  radius_km double precision
)
returns table (
  id          uuid,
  name        text,
  description text,
  address     text,
  city        text,
  country     text,
  latitude    double precision,
  longitude   double precision,
  distance_km double precision,
  popularity  bigint
)
language sql
stable
security definer
set search_path = public, extensions
as $$
  with base as (
    select * from public.nearby_hotels(lat, lng, radius_km)
  ),
  ranked as (
    select
      b.*,
      (
        select count(*)
        from public.reservations res
        where res.hotel_id = b.id
          and res.status = 'confirmed'
          and res.created_at >= now()
            - make_interval(days => public.recommendation_window_days())
      ) as popularity
    from base b
  ),
  has_signal as (
    select coalesce(max(popularity), 0) > 0 as any_popular from ranked
  )
  select
    r.id, r.name, r.description, r.address, r.city, r.country,
    r.latitude, r.longitude, r.distance_km, r.popularity
  from ranked r, has_signal
  where has_signal.any_popular
     -- Cold-start branch: keep only hotels with an available-now room.
     or exists (
       select 1
       from public.rooms rm
       where rm.hotel_id = r.id
         and public.is_room_available_now(rm.id)
     )
  order by r.popularity desc, r.distance_km asc;
$$;

-- ---------------------------------------------------------------------------
-- Execute grants (callable by authenticated app sessions / the backend)
-- ---------------------------------------------------------------------------
grant execute on function public.is_room_available_now(uuid)                         to authenticated;
grant execute on function public.rooms_with_availability(uuid)                       to authenticated;
grant execute on function public.nearby_hotels(double precision, double precision, double precision)      to authenticated;
grant execute on function public.recommended_hotels(double precision, double precision, double precision) to authenticated;
