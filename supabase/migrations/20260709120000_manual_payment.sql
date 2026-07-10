-- BE-702 · Manual payment confirmation (EPIC-07).
--
-- Hotelyn's MVP has no online payment integration: a guest pays in person and a
-- staff member marks the reservation paid. That action completes the booking —
-- the held reservation transitions to 'confirmed' — and is recorded (who + when)
-- so a later payment dispute can be traced to the staff member who took it.
--
-- Design decisions, consistent with the rest of the staff-side surface:
--
--   * This runs through the Dart Frog backend on the SERVICE-ROLE key, which
--     bypasses RLS. So — exactly as confirm_reservation / reject_reservation do
--     (BE-503) — the RPC re-checks ownership itself via actor_manages_hotel
--     rather than trusting RLS: only the owning hotel's staff (or an admin) may
--     mark a reservation paid.
--
--   * Marking paid is only meaningful for a live hold. A hold that already
--     lapsed (query-time expiry, BE-403), or a reservation already in a terminal
--     state (rejected / cancelled / expired), is refused with a clear, stable
--     error token rather than silently resurrected — a payment must never revive
--     a booking whose room may since have been re-let. An already-'confirmed'
--     reservation is likewise refused (it is not awaiting payment).

-- ---------------------------------------------------------------------------
-- Audit columns
-- ---------------------------------------------------------------------------
-- Who took the in-person payment and when. Populated only by
-- mark_reservation_paid; null on every reservation that was never manually paid.
-- Kept for dispute resolution, so paid_by references the acting profile and is
-- preserved (ON DELETE SET NULL) even if that staff member is later removed —
-- the audit fact (a payment happened at paid_at) survives the staff account.
alter table public.reservations
  add column paid_by uuid references public.profiles (id) on delete set null,
  add column paid_at timestamptz;

comment on column public.reservations.paid_by is
  'Staff/admin profile that marked this reservation paid in person (BE-702). '
  'Null unless mark_reservation_paid recorded a payment. ON DELETE SET NULL so '
  'the payment timestamp survives the staff account for dispute resolution.';

comment on column public.reservations.paid_at is
  'When the in-person payment was recorded (BE-702). Null unless paid.';

-- ---------------------------------------------------------------------------
-- BE-702 · mark_reservation_paid
-- ---------------------------------------------------------------------------
-- Mark a held reservation as paid in person: transition it to 'confirmed',
-- clear its ticking expiry (a paid booking blocks the room until staff free it,
-- like confirm_reservation), and stamp who/when for audit. Returns the updated
-- reservation row.
--
-- Rejections (raise, surfaced to the caller as a typed RpcException → 4xx):
--   * reservation does not exist                 -> 'reservation_not_found'
--   * caller is not the owning hotel's staff/adm -> 'not_authorized'
--   * reservation is not an active, live hold    -> 'reservation_not_payable'
--     (already confirmed, terminal, or an expired hold)
create or replace function public.mark_reservation_paid(
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
  -- FOR UPDATE locks the row for this transaction so the status/expiry we
  -- validate below cannot be changed by a concurrent transition (a reject,
  -- cancel, or a second mark-paid) between the check and the write. Without it,
  -- under READ COMMITTED such a transition could commit in the gap and this
  -- UPDATE — whose WHERE has no status predicate — would blindly overwrite it to
  -- 'confirmed', exactly the "a payment must never revive a booking" case above.
  select hotel_id, status, hold_expires_at
    into v_hotel_id, v_status, v_expires_at
    from public.reservations where id = p_id
    for update;

  if not found then
    raise exception 'reservation_not_found' using errcode = 'no_data_found';
  end if;

  if not public.actor_manages_hotel(p_actor, v_hotel_id) then
    raise exception 'not_authorized' using errcode = 'insufficient_privilege';
  end if;

  -- Only a live hold is payable. An already-confirmed booking is not awaiting
  -- payment, and a terminal reservation (rejected/cancelled/expired) must not be
  -- resurrected by a payment.
  if v_status <> 'held' then
    raise exception 'reservation_not_payable' using errcode = 'check_violation';
  end if;

  -- Query-time expiry (BE-403): a lapsed hold cannot be paid. As in
  -- confirm_reservation we do NOT flip status to 'expired' here — the raise would
  -- roll that write back, and the read paths already treat an expired hold as
  -- free, so the stale 'held' status is harmless (reconciled on the room's next
  -- hold attempt).
  if v_expires_at is null or v_expires_at <= now() then
    raise exception 'reservation_not_payable' using errcode = 'check_violation';
  end if;

  return query
    update public.reservations
       set status = 'confirmed',
           hold_expires_at = null,
           paid_by = p_actor,
           paid_at = now()
     where id = p_id
    returning *;
end;
$$;

comment on function public.mark_reservation_paid(uuid, uuid) is
  'BE-702: owning staff mark a held reservation paid in person. Transitions it '
  'to confirmed, clears the expiry, and stamps paid_by/paid_at for dispute '
  'resolution. Refuses (reservation_not_payable) anything that is not a live '
  'hold — an already-confirmed, terminal, or expired reservation.';

-- ---------------------------------------------------------------------------
-- Execute grant
-- ---------------------------------------------------------------------------
-- SECURITY: like the other staff RPCs, this takes the acting profile as an
-- argument and resolves authorization from it while bypassing RLS. If it were
-- callable by `authenticated`, any logged-in user could invoke it via PostgREST
-- passing another user's id as p_actor. Restrict to the backend's trusted
-- service_role (CREATE FUNCTION grants EXECUTE to PUBLIC by default, so revoke
-- that first). service_role is a member of every role and so retains access; we
-- grant it explicitly to make intent unambiguous.
revoke execute on function public.mark_reservation_paid(uuid, uuid) from public;
grant  execute on function public.mark_reservation_paid(uuid, uuid) to service_role;
