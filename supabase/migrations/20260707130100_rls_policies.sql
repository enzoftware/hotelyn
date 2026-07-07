-- BE-203 · Row Level Security policies
--
-- With Supabase the client talks to Postgres fairly directly, so RLS *is* the
-- authorization boundary — an app-layer check is not sufficient. Every table
-- below has RLS enabled (no table left open by default) and policies that are
-- deliberately scoped per role and per tenant (hotel). Intent is commented so a
-- future reader understands *why*, not just *what*.
--
-- A wrong policy fails silently: over-permissive leaks data, over-strict breaks
-- a feature. The accompanying pgTAP test (supabase/tests/rls_test.sql) asserts
-- the cross-tenant boundary rather than relying on a manual check.

-- ---------------------------------------------------------------------------
-- Helper functions
-- ---------------------------------------------------------------------------
-- Policies need the caller's role and hotel, both stored in `profiles`. Reading
-- `profiles` directly from inside another table's policy would re-trigger
-- profiles' own RLS (and can recurse). These SECURITY DEFINER helpers read the
-- caller's own row with RLS bypassed, which is safe because they only ever
-- return data about `auth.uid()` itself. (Named *_profile_* to avoid shadowing
-- Postgres' built-in `current_role`.)

create or replace function public.current_profile_role()
returns public.user_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

create or replace function public.current_profile_hotel_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select hotel_id from public.profiles where id = auth.uid();
$$;

-- CREATE FUNCTION grants EXECUTE to PUBLIC by default. These definer functions
-- bypass RLS, so restrict them to authenticated callers to trim attack surface.
revoke execute on function public.current_profile_role()     from public;
revoke execute on function public.current_profile_hotel_id() from public;
grant  execute on function public.current_profile_role()     to authenticated;
grant  execute on function public.current_profile_hotel_id() to authenticated;

-- ---------------------------------------------------------------------------
-- Enable RLS everywhere
-- ---------------------------------------------------------------------------

alter table public.hotels       enable row level security;
alter table public.rooms        enable row level security;
alter table public.reservations enable row level security;
alter table public.profiles     enable row level security;

-- ---------------------------------------------------------------------------
-- Table grants
-- ---------------------------------------------------------------------------
-- RLS only filters rows a role is otherwise allowed to touch; without a GRANT the
-- role cannot reach the table at all. This project does not auto-expose new
-- tables to the API roles, so grant the DML that the policies below gate. Rows
-- are still restricted per-role/per-tenant by those policies.
--
-- `profiles` is granted at COLUMN level on purpose: `role` and `hotel_id` drive
-- every authorization decision, so a client that could write them could
-- self-escalate to admin/staff. RLS WITH CHECK cannot compare against the
-- pre-update value, so those columns are simply not writable by `authenticated`
-- — they are provisioned out-of-band (service_role / seed / admin tooling).

grant select, update                 on public.hotels       to authenticated;
grant select, insert, update, delete on public.rooms        to authenticated;
grant select, insert, update         on public.reservations to authenticated;
grant select                         on public.profiles     to authenticated;
grant insert (id, full_name)         on public.profiles     to authenticated;
grant update (full_name)             on public.profiles     to authenticated;

-- ---------------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------------

-- A user may read and maintain only their own profile row. Admins may read all
-- (e.g. support tooling). role/hotel_id are not writable by clients (see the
-- column grants above), so no client can change another user's — or their own —
-- role or hotel link.
create policy profiles_select_own
  on public.profiles for select
  to authenticated
  using (id = auth.uid() or (select public.current_profile_role()) = 'admin');

create policy profiles_insert_own
  on public.profiles for insert
  to authenticated
  with check (id = auth.uid());

create policy profiles_update_own
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- ---------------------------------------------------------------------------
-- hotels
-- ---------------------------------------------------------------------------

-- Hotels are a public catalogue: any authenticated user may browse them.
create policy hotels_select_all
  on public.hotels for select
  to authenticated
  using (true);

-- Only the hotel's own staff (or an admin) may modify it. New hotels are
-- provisioned out-of-band (service_role / admin), so there is no staff INSERT
-- policy here. Helper calls are wrapped in a scalar subquery so the planner
-- evaluates them once per statement (initplan) instead of once per row.
create policy hotels_update_own
  on public.hotels for update
  to authenticated
  using (
    (select public.current_profile_role()) = 'admin'
    or (
      (select public.current_profile_role()) = 'hotel_staff'
      and id = (select public.current_profile_hotel_id())
    )
  )
  with check (
    (select public.current_profile_role()) = 'admin'
    or (
      (select public.current_profile_role()) = 'hotel_staff'
      and id = (select public.current_profile_hotel_id())
    )
  );

-- ---------------------------------------------------------------------------
-- rooms
-- ---------------------------------------------------------------------------

-- Guests browse broadly: any available room is visible. A hotel's own staff (and
-- admins) additionally see their unavailable rooms for management.
create policy rooms_select_visible
  on public.rooms for select
  to authenticated
  using (
    is_available
    or (select public.current_profile_role()) = 'admin'
    or (
      (select public.current_profile_role()) = 'hotel_staff'
      and hotel_id = (select public.current_profile_hotel_id())
    )
  );

-- Staff may create/modify/remove rooms only for their own hotel; admins for any.
-- The USING clause keeps a staffer from touching Hotel B's rooms; the WITH CHECK
-- clause keeps them from reassigning a row into another hotel.
create policy rooms_insert_own_hotel
  on public.rooms for insert
  to authenticated
  with check (
    (select public.current_profile_role()) = 'admin'
    or (
      (select public.current_profile_role()) = 'hotel_staff'
      and hotel_id = (select public.current_profile_hotel_id())
    )
  );

create policy rooms_update_own_hotel
  on public.rooms for update
  to authenticated
  using (
    (select public.current_profile_role()) = 'admin'
    or (
      (select public.current_profile_role()) = 'hotel_staff'
      and hotel_id = (select public.current_profile_hotel_id())
    )
  )
  with check (
    (select public.current_profile_role()) = 'admin'
    or (
      (select public.current_profile_role()) = 'hotel_staff'
      and hotel_id = (select public.current_profile_hotel_id())
    )
  );

create policy rooms_delete_own_hotel
  on public.rooms for delete
  to authenticated
  using (
    (select public.current_profile_role()) = 'admin'
    or (
      (select public.current_profile_role()) = 'hotel_staff'
      and hotel_id = (select public.current_profile_hotel_id())
    )
  );

-- ---------------------------------------------------------------------------
-- reservations
-- ---------------------------------------------------------------------------

-- A guest sees only their own reservations. A hotel's staff see every
-- reservation for their hotel; admins see all.
create policy reservations_select_scoped
  on public.reservations for select
  to authenticated
  using (
    guest_id = auth.uid()
    or (select public.current_profile_role()) = 'admin'
    or (
      (select public.current_profile_role()) = 'hotel_staff'
      and hotel_id = (select public.current_profile_hotel_id())
    )
  );

-- A guest may only create a reservation in their own name, and only in the
-- initial `held` state — confirming/rejecting is the hotel's job, so a guest
-- cannot self-confirm. WITH CHECK also stops attributing a booking to someone
-- else. (The composite room/hotel FK keeps room_id and hotel_id consistent.)
create policy reservations_insert_own
  on public.reservations for insert
  to authenticated
  with check (guest_id = auth.uid() and status = 'held');

-- A guest may update only their own reservation and only into guest-permitted
-- states (e.g. cancel) — never self-confirm. Staff may drive their hotel's
-- reservations through any status (confirm/reject); admins anything.
create policy reservations_update_scoped
  on public.reservations for update
  to authenticated
  using (
    guest_id = auth.uid()
    or (select public.current_profile_role()) = 'admin'
    or (
      (select public.current_profile_role()) = 'hotel_staff'
      and hotel_id = (select public.current_profile_hotel_id())
    )
  )
  with check (
    (guest_id = auth.uid() and status in ('held', 'cancelled'))
    or (select public.current_profile_role()) = 'admin'
    or (
      (select public.current_profile_role()) = 'hotel_staff'
      and hotel_id = (select public.current_profile_hotel_id())
    )
  );
