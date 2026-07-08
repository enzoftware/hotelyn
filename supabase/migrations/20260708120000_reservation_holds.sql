-- BE-401 · Partial unique index for active holds
-- BE-402 · Create-hold RPC function
-- BE-403 · Hold expiry (free-tier, query-time)
--
-- The reservation-hold engine (EPIC-04). A "hold" is a short-lived, exclusive
-- claim on a room so a guest can finish checkout without a second guest booking
-- the same room underneath them.
--
-- Design decisions worth stating up front:
--
--   * Correctness is the DATABASE's job, not the app's. Two active reservations
--     for the same room are made physically impossible by a partial unique index
--     (BE-401), so double-booking cannot happen even under concurrency — no Redis
--     lock, no extra service. The insert simply loses to the unique constraint.
--
--   * Expiry is QUERY-TIME, not swept by a background job (BE-403). Supabase's
--     pg_cron is Pro-gated (https://supabase.com/docs/guides/cron), so instead of
--     paying to flip `status` on a schedule we let every read path treat an
--     expired hold as free. CONSEQUENCE, BY DESIGN — NOT A BUG: the `status`
--     column can read 'held' after the hold has really expired, until something
--     next touches the row. No user ever sees a stale-blocked room, because
--     availability is computed from `hold_expires_at`, never from `status` alone
--     (see is_room_available_now / rooms_with_availability in the geo_search
--     migration, and the active-hold index below).

-- ---------------------------------------------------------------------------
-- Tunable constant: hold duration
-- ---------------------------------------------------------------------------
-- How long a fresh hold stays active. One documented definition so the window
-- can be tuned in a single place rather than scattered through call sites.
create or replace function public.hold_duration()
returns interval
language sql
immutable
as $$
  select interval '15 minutes';
$$;

comment on function public.hold_duration() is
  'How long a newly created hold blocks its room before expiring '
  '(create_reservation_hold sets hold_expires_at = now() + this). Tune here.';

-- ---------------------------------------------------------------------------
-- BE-701 (partial) · confirmation code
-- ---------------------------------------------------------------------------
-- A short, human-quotable code generated for every reservation at hold time and
-- returned to the guest ("your booking is HZ-XXXXXXXX"). Unique so it can serve
-- as a lookup handle. Nullable only for legacy rows; new holds always populate
-- it inside create_reservation_hold, in the same transaction as the insert.
alter table public.reservations
  add column confirmation_code text;

alter table public.reservations
  add constraint reservations_confirmation_code_key unique (confirmation_code);

comment on column public.reservations.confirmation_code is
  'Human-quotable booking handle (e.g. HZ-3F7K9Q2A), generated in '
  'create_reservation_hold within the insert transaction. Unique.';

-- Generates a collision-resistant, unambiguous confirmation code. Uses Crockford
-- base32 (no I/L/O/U) so a code read aloud over the phone is unambiguous.
create or replace function public.generate_confirmation_code()
returns text
language sql
volatile
set search_path = public, extensions
as $$
  select 'HZ-' || string_agg(
    substr('0123456789ABCDEFGHJKMNPQRSTVWXYZ',
           1 + floor(random() * 32)::int, 1),
    ''
  )
  from generate_series(1, 8);
$$;

comment on function public.generate_confirmation_code() is
  'Returns a Crockford-base32 booking code like HZ-3F7K9Q2A (no I/L/O/U). '
  'Uniqueness is enforced by the reservations.confirmation_code constraint; '
  'create_reservation_hold retries on the (astronomically rare) collision.';

-- ---------------------------------------------------------------------------
-- BE-401 · partial unique index for active holds
-- ---------------------------------------------------------------------------
-- The double-booking guarantee. At most ONE reservation per room may be in an
-- active-blocking status ('held' or 'confirmed') at a time. A concurrent second
-- INSERT for the same room violates this and is rejected by Postgres — which is
-- exactly what create_reservation_hold's ON CONFLICT keys off.
--
-- Note this indexes by `status` only: a still-'held' row whose hold_expires_at
-- has passed continues to occupy the slot until it is touched (see the BE-403
-- note above). That is acceptable — the guest who let their hold lapse simply
-- has to re-attempt, and the first re-attempt that flips/replaces the row wins.
create unique index reservations_active_room_uidx
  on public.reservations (room_id)
  where status in ('held', 'confirmed');

comment on index public.reservations_active_room_uidx is
  'BE-401: makes double-booking physically impossible — at most one held/'
  'confirmed reservation per room. create_reservation_hold relies on this.';

-- ---------------------------------------------------------------------------
-- BE-402 · create_reservation_hold
-- ---------------------------------------------------------------------------
-- Atomically place a hold on a room for a guest. Returns the created reservation
-- row on success, or ZERO rows when the room is already actively held/confirmed
-- (the caller maps "no row" to a typed 409-style "already held" error).
--
-- SECURITY DEFINER with a pinned search_path: the insert must succeed regardless
-- of the caller's RLS visibility of other guests' reservations, but the function
-- only ever inserts on behalf of, and returns, the caller's own hold.
--
-- Rejections (raise, surfaced as errors — distinct from the "already held" empty
-- result):
--   * caller is a guest holding for someone else -> 'not_authorized'
--   * the room does not exist                     -> 'room_not_found'
--   * the room is flagged unavailable             -> 'room_unavailable'
create or replace function public.create_reservation_hold(
  p_room_id   uuid,
  p_guest_id  uuid,
  p_check_in  date,
  p_check_out date
)
returns setof public.reservations
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_hotel_id uuid;
  v_flagged_available boolean;
  v_code text;
begin
  -- Authorization: this function is SECURITY DEFINER (it bypasses RLS to see
  -- other guests' holds for the conflict check), so it must NOT trust p_guest_id
  -- blindly — otherwise any authenticated caller could place a hold in someone
  -- else's name. A logged-in guest may only hold for themselves. auth.uid() is
  -- NULL for the trusted backend service role, which is allowed to pass any
  -- guest id (it acts on the authenticated user's behalf after its own checks).
  if auth.uid() is not null and auth.uid() <> p_guest_id then
    raise exception 'not_authorized'
      using errcode = 'insufficient_privilege';
  end if;

  -- Resolve the room's hotel and staff-availability flag. A missing room or a
  -- room staff have marked unavailable is a hard rejection, not a "try later".
  select r.hotel_id, r.is_available
    into v_hotel_id, v_flagged_available
    from public.rooms r
   where r.id = p_room_id;

  if not found then
    raise exception 'room_not_found'
      using errcode = 'no_data_found';
  end if;

  -- `is not true` treats a NULL is_available as unavailable (defensive; the
  -- column is NOT NULL today, but this never lets a NULL slip a hold through).
  if v_flagged_available is not true then
    raise exception 'room_unavailable'
      using errcode = 'check_violation';
  end if;

  -- Reclaim any LAPSED hold on this room before attempting the insert. Under the
  -- query-time-expiry model (BE-403) an expired hold can still read status='held'
  -- and therefore still occupy the BE-401 partial-unique slot — which would wrongly
  -- block a new hold on a room that availability already reports as free. Flipping
  -- it to 'expired' here is the "touch" that reconciles status with reality: the
  -- row leaves the held/confirmed predicate, freeing the slot, while the audit row
  -- is preserved. A 'confirmed' booking (a real, paid reservation) is never
  -- reclaimed. Same transaction as the insert, so it is atomic w.r.t. concurrent
  -- callers — the one that reclaims-and-inserts first wins the slot.
  update public.reservations
     set status = 'expired'
   where room_id = p_room_id
     and status = 'held'
     and hold_expires_at is not null
     and hold_expires_at <= now();

  -- Generate a confirmation code, retrying on the (astronomically unlikely)
  -- unique collision so a code clash never surfaces as an error to the caller.
  loop
    v_code := public.generate_confirmation_code();
    begin
      return query
        insert into public.reservations (
          hotel_id, room_id, guest_id, status,
          check_in, check_out, hold_expires_at, confirmation_code
        )
        values (
          v_hotel_id, p_room_id, p_guest_id, 'held',
          p_check_in, p_check_out, now() + public.hold_duration(), v_code
        )
        -- BE-401: another active hold/confirmation on this room already occupies
        -- the partial-unique slot. DO NOTHING → this statement inserts no row →
        -- the function returns zero rows → caller reads "already held".
        on conflict (room_id) where status in ('held', 'confirmed')
        do nothing
        returning *;
      return;
    exception
      when unique_violation then
        -- Only a confirmation_code collision reaches here (the room_id conflict
        -- is handled by ON CONFLICT above). Loop to try a fresh code.
        if sqlerrm like '%confirmation_code%'
           or sqlerrm like '%reservations_confirmation_code_key%' then
          continue;
        end if;
        raise;
    end;
  end loop;
end;
$$;

comment on function public.create_reservation_hold(uuid, uuid, date, date) is
  'BE-402: atomically holds a room for a guest for hold_duration(). Reclaims any '
  'lapsed hold on the room first (BE-403), then returns the created reservation, '
  'or ZERO rows when the room is already actively held/confirmed (caller maps to '
  'a 409 "already held"). Raises room_not_found / room_unavailable for a missing '
  'or staff-disabled room.';

-- Callable by authenticated app sessions / the backend service role.
grant execute
  on function public.create_reservation_hold(uuid, uuid, date, date)
  to authenticated;
