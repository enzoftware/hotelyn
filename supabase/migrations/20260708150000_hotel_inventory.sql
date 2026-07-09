-- BE-501 · RLS-scoped room list with derived status
-- BE-502 · Toggle room availability (double-allocation guard)
-- BE-503 · Confirm / reject incoming reservations
-- BE-504 · Realtime publication for reservations
--
-- Hotel-side inventory & realtime (EPIC-05). Staff-facing operations over their
-- own hotel's rooms and reservations. Two cross-cutting design decisions:
--
--   * These run through the Dart Frog backend, which holds the SERVICE-ROLE key
--     and therefore BYPASSES RLS. So — exactly as create_reservation_hold does
--     for guests (BE-402) — every staff RPC here re-checks ownership itself
--     rather than trusting RLS alone: it resolves the acting profile and rejects
--     unless that profile is the owning hotel's staff (or an admin). The RLS
--     policies (BE-203) remain the boundary for any direct client access.
--
--   * Status is derived with the QUERY-TIME expiry rule (BE-403): a hold whose
--     hold_expires_at has passed is treated as free, even if status still reads
--     'held'. Reuses the same predicate as is_room_available_now.

-- ---------------------------------------------------------------------------
-- Shared authorization helper
-- ---------------------------------------------------------------------------
-- True when p_actor may manage p_hotel_id: an admin, or that hotel's own staff.
-- Centralizes the ownership rule the staff RPCs below share. SECURITY DEFINER so
-- it can read profiles regardless of the caller's RLS view, and only ever about
-- the passed actor.
create or replace function public.actor_manages_hotel(
  p_actor    uuid,
  p_hotel_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = p_actor
      and (
        p.role = 'admin'
        or (p.role = 'hotel_staff' and p.hotel_id = p_hotel_id)
      )
  );
$$;

comment on function public.actor_manages_hotel(uuid, uuid) is
  'True when the actor is an admin or the owning hotel''s staff. Shared '
  'ownership check for the staff inventory RPCs (they bypass RLS via the '
  'service role, so they must re-check ownership themselves).';

-- ---------------------------------------------------------------------------
-- Derived room status
-- ---------------------------------------------------------------------------
-- One of: 'unavailable' | 'occupied' | 'held' | 'available', evaluated with the
-- query-time expiry rule. Precedence: a staff-disabled room is always
-- 'unavailable'; otherwise an active confirmed booking is 'occupied', an active
-- (unexpired) hold is 'held', and anything else is 'available'.
create or replace function public.room_status(p_room_id uuid)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select case
    when not r.is_available then 'unavailable'
    -- A confirmed booking blocks the room regardless of hold_expires_at:
    -- confirm_reservation nulls the expiry (a confirmed stay is not a ticking
    -- hold), so this branch must NOT gate on it.
    when exists (
      select 1 from public.reservations res
      where res.room_id = r.id
        and res.status = 'confirmed'
    ) then 'occupied'
    -- A hold blocks only while unexpired (query-time expiry, BE-403).
    when exists (
      select 1 from public.reservations res
      where res.room_id = r.id
        and res.status = 'held'
        and res.hold_expires_at is not null
        and res.hold_expires_at > now()
    ) then 'held'
    else 'available'
  end
  from public.rooms r
  where r.id = p_room_id;
$$;

comment on function public.room_status(uuid) is
  'Derived inventory status for a room: unavailable | occupied | held | '
  'available, using the query-time expiry rule (BE-403 / BE-501).';

-- ---------------------------------------------------------------------------
-- BE-501 · staff room list
-- ---------------------------------------------------------------------------
-- Every room of the acting staff member's hotel, each with its derived status.
-- Scoping is NOT a client-supplied hotel_id: the function resolves the actor's
-- own hotel from their profile, so a client cannot ask for another hotel's
-- inventory. Admins may pass an explicit p_hotel_id to inspect any hotel.
create or replace function public.staff_room_list(
  p_actor    uuid,
  p_hotel_id uuid default null
)
returns table (
  id              uuid,
  hotel_id        uuid,
  name            text,
  room_type       text,
  capacity        integer,
  price_per_night numeric,
  is_available    boolean,
  status          text
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_role     public.user_role;
  v_hotel_id uuid;
  v_target   uuid;
begin
  select p.role, p.hotel_id into v_role, v_hotel_id
    from public.profiles p where p.id = p_actor;

  if v_role is null then
    raise exception 'not_authorized' using errcode = 'insufficient_privilege';
  end if;

  -- Admins may target any hotel (or all when null); staff are pinned to theirs.
  if v_role = 'admin' then
    v_target := p_hotel_id;
  elsif v_role = 'hotel_staff' then
    -- A staff profile with no hotel link must not fall through to an unscoped
    -- (v_target is null) listing of every hotel's rooms.
    if v_hotel_id is null then
      raise exception 'not_authorized' using errcode = 'insufficient_privilege';
    end if;
    v_target := v_hotel_id;
  else
    raise exception 'not_authorized' using errcode = 'insufficient_privilege';
  end if;

  return query
    select
      r.id, r.hotel_id, r.name, r.room_type, r.capacity, r.price_per_night,
      r.is_available, public.room_status(r.id)
    from public.rooms r
    where v_target is null or r.hotel_id = v_target
    order by r.hotel_id, r.name;
end;
$$;

comment on function public.staff_room_list(uuid, uuid) is
  'BE-501: a staff member''s own hotel rooms (admins: any hotel) with a derived '
  'status. Hotel scope comes from the actor''s profile, never a tamperable '
  'client filter.';

-- ---------------------------------------------------------------------------
-- BE-502 · toggle room availability (double-allocation guard)
-- ---------------------------------------------------------------------------
-- Set a room's is_available flag. Guarded two ways:
--   * ownership: only the owning hotel's staff (or an admin) may toggle.
--   * double-allocation: a room with an active (unexpired) hold or confirmed
--     reservation cannot be flipped to available — doing so would advertise a
--     room that is really taken. Blocking to unavailable is always allowed.
-- Returns the updated room row.
create or replace function public.set_room_availability(
  p_actor        uuid,
  p_room_id      uuid,
  p_is_available boolean
)
returns table (
  id              uuid,
  hotel_id        uuid,
  name            text,
  room_type       text,
  capacity        integer,
  price_per_night numeric,
  is_available    boolean,
  status          text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_hotel_id uuid;
begin
  select r.hotel_id into v_hotel_id
    from public.rooms r where r.id = p_room_id;

  if not found then
    raise exception 'room_not_found' using errcode = 'no_data_found';
  end if;

  if not public.actor_manages_hotel(p_actor, v_hotel_id) then
    raise exception 'not_authorized' using errcode = 'insufficient_privilege';
  end if;

  -- Guard against re-advertising a room that is currently claimed: a confirmed
  -- booking (expiry nulled) always blocks; a held row blocks only while its hold
  -- is unexpired (query-time expiry, BE-403).
  if p_is_available and exists (
    select 1 from public.reservations res
    where res.room_id = p_room_id
      and (
        res.status = 'confirmed'
        or (
          res.status = 'held'
          and res.hold_expires_at is not null
          and res.hold_expires_at > now()
        )
      )
  ) then
    raise exception 'room_has_active_reservation'
      using errcode = 'check_violation';
  end if;

  update public.rooms
     set is_available = p_is_available
   where rooms.id = p_room_id;

  -- Return the updated room in the same shape as staff_room_list, so the caller
  -- gets the freshly derived status without a second query.
  return query
    select
      r.id, r.hotel_id, r.name, r.room_type, r.capacity, r.price_per_night,
      r.is_available, public.room_status(r.id)
    from public.rooms r
    where r.id = p_room_id;
end;
$$;

comment on function public.set_room_availability(uuid, uuid, boolean) is
  'BE-502: staff toggle of a room''s availability, RLS/ownership-checked. '
  'Refuses to set available while an active hold/confirmed reservation would '
  'double-allocate the room (raises room_has_active_reservation).';

-- ---------------------------------------------------------------------------
-- BE-503 · confirm / reject incoming reservations
-- ---------------------------------------------------------------------------
-- Both are staff (owning-hotel) actions on a single reservation.

-- Confirm a pending hold. Fails on an already-expired hold rather than silently
-- resurrecting it, and only acts on a row still in 'held'. On success the row
-- becomes 'confirmed' and its expiry is cleared (a confirmed booking is not a
-- ticking hold — it blocks the room until staff free it).
create or replace function public.confirm_reservation(
  p_actor uuid,
  p_id    uuid
)
returns setof public.reservations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_hotel_id   uuid;
  v_status     public.reservation_status;
  v_expires_at timestamptz;
begin
  select hotel_id, status, hold_expires_at
    into v_hotel_id, v_status, v_expires_at
    from public.reservations where id = p_id;

  if not found then
    raise exception 'reservation_not_found' using errcode = 'no_data_found';
  end if;

  if not public.actor_manages_hotel(p_actor, v_hotel_id) then
    raise exception 'not_authorized' using errcode = 'insufficient_privilege';
  end if;

  if v_status <> 'held' then
    raise exception 'reservation_not_held' using errcode = 'check_violation';
  end if;

  -- Query-time expiry (BE-403): a lapsed hold cannot be confirmed. We do NOT
  -- also flip status to 'expired' here — raising would roll that write back
  -- anyway, and the read paths already treat an expired hold as free, so the
  -- stale 'held' status is harmless (it is reconciled on the next hold attempt
  -- for the room, per create_reservation_hold).
  if v_expires_at is null or v_expires_at <= now() then
    raise exception 'hold_expired' using errcode = 'check_violation';
  end if;

  return query
    update public.reservations
       set status = 'confirmed', hold_expires_at = null
     where id = p_id
    returning *;
end;
$$;

comment on function public.confirm_reservation(uuid, uuid) is
  'BE-503: owning staff confirm a held reservation. Fails (hold_expired) on an '
  'already-expired hold instead of resurrecting it; clears the expiry so the '
  'confirmed booking blocks the room until explicitly freed.';

-- Reject a reservation. Transitions to 'rejected' and frees the room
-- immediately (clears hold_expires_at) rather than waiting for the TTL.
create or replace function public.reject_reservation(
  p_actor uuid,
  p_id    uuid
)
returns setof public.reservations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_hotel_id uuid;
  v_status   public.reservation_status;
begin
  select hotel_id, status into v_hotel_id, v_status
    from public.reservations where id = p_id;

  if not found then
    raise exception 'reservation_not_found' using errcode = 'no_data_found';
  end if;

  if not public.actor_manages_hotel(p_actor, v_hotel_id) then
    raise exception 'not_authorized' using errcode = 'insufficient_privilege';
  end if;

  -- Only an active (held/confirmed) reservation can be rejected; a terminal one
  -- (already cancelled/rejected/expired) is a no-op error, not a silent success.
  if v_status not in ('held', 'confirmed') then
    raise exception 'reservation_not_active' using errcode = 'check_violation';
  end if;

  return query
    update public.reservations
       set status = 'rejected', hold_expires_at = null
     where id = p_id
    returning *;
end;
$$;

comment on function public.reject_reservation(uuid, uuid) is
  'BE-503: owning staff reject a reservation. Sets status=rejected and frees the '
  'room immediately (clears hold_expires_at) instead of waiting for the TTL.';

-- ---------------------------------------------------------------------------
-- Execute grants
-- ---------------------------------------------------------------------------
-- SECURITY: the staff RPCs below take the acting profile as an argument (p_actor)
-- and resolve authorization from it while bypassing RLS (SECURITY DEFINER). If
-- they were callable by `authenticated`, any logged-in user could invoke them
-- directly via PostgREST (/rest/v1/rpc/...) passing another user's id as p_actor
-- and impersonate them. They are therefore restricted to the backend's
-- `service_role` (the trusted caller that derives p_actor from the verified
-- session) — CREATE FUNCTION grants EXECUTE to PUBLIC by default, so we revoke
-- that first. `service_role` is a member of every role, so it retains access
-- without an explicit grant; we grant it anyway to make the intent unambiguous.
revoke execute on function public.actor_manages_hotel(uuid, uuid)            from public;
revoke execute on function public.staff_room_list(uuid, uuid)               from public;
revoke execute on function public.set_room_availability(uuid, uuid, boolean) from public;
revoke execute on function public.confirm_reservation(uuid, uuid)           from public;
revoke execute on function public.reject_reservation(uuid, uuid)            from public;

grant execute on function public.actor_manages_hotel(uuid, uuid)            to service_role;
grant execute on function public.staff_room_list(uuid, uuid)               to service_role;
grant execute on function public.set_room_availability(uuid, uuid, boolean) to service_role;
grant execute on function public.confirm_reservation(uuid, uuid)           to service_role;
grant execute on function public.reject_reservation(uuid, uuid)            to service_role;

-- room_status is a read-only helper with no p_actor / auth bypass; safe for any
-- authenticated session (e.g. for an RLS-scoped direct read).
grant execute on function public.room_status(uuid)                          to authenticated;

-- ---------------------------------------------------------------------------
-- BE-504 · Realtime publication for reservations
-- ---------------------------------------------------------------------------
-- The dashboard subscribes to reservation changes for its own hotel. Supabase
-- Realtime broadcasts changes for tables in the `supabase_realtime` publication,
-- and — crucially — respects RLS on the subscribing user's session, so a staff
-- session only receives rows its reservations_select_scoped policy allows (its
-- own hotel). Adding the table here is the DB-side enabler; the dashboard
-- subscription (filtered to hotel_id) is wired in the app layer.
--
-- Idempotent: only add the table if it is not already a member (a fresh Supabase
-- project ships an empty supabase_realtime publication).
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'reservations'
  ) then
    alter publication supabase_realtime add table public.reservations;
  end if;
end;
$$;
