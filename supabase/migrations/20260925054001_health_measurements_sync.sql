-- =============================================================================
-- Sprint 2 · Health measurements (cloud copy of the on-device health records)
-- -----------------------------------------------------------------------------
-- One row per measurement for the 6 tracked metrics. Rows are created on the
-- device (client-generated UUID = idempotency key) and synced through
-- public.sync_health_measurements(): batch upsert, last-write-wins on
-- client_updated_at, soft delete via deleted_at. Pull uses a keyset cursor on
-- (server_updated_at, id).
-- Access: owner only (doctor access with explicit consent comes in Sprint 4).
-- Rollback: supabase/rollbacks/20260925054001_health_measurements_sync.down.sql
-- =============================================================================

create type public.health_metric as enum (
  'cholesterol', 'blood_sugar', 'uric_acid', 'body_temperature', 'blood_pressure', 'bmi'
);

create table public.health_measurements (
  id                 uuid primary key,
  user_id            uuid not null default auth.uid()
                       references public.profiles (id) on delete cascade,
  metric             public.health_metric not null,
  measured_on        date not null,
  measured_time      time,
  value              numeric(8, 2) not null check (value >= 0 and value < 100000),
  value2             numeric(8, 2) check (value2 >= 0 and value2 < 100000), -- diastolic
  weight_kg          numeric(6, 2) check (weight_kg > 0 and weight_kg < 1000),
  height_cm          numeric(6, 2) check (height_cm > 0 and height_cm < 300),
  unit               varchar(16),
  note               text check (length(note) <= 2000),
  client_updated_at  timestamptz not null,
  deleted_at         timestamptz,
  created_at         timestamptz not null default now(),
  server_updated_at  timestamptz not null default now(),
  constraint health_measurements_bp_needs_diastolic
    check (metric <> 'blood_pressure' or deleted_at is not null or value2 is not null)
);

comment on table public.health_measurements is
  'Health records synced from devices. Owner-only; soft-deleted rows keep a tombstone for sync.';

-- Pull cursor + per-metric history views.
create index health_measurements_sync_idx
  on public.health_measurements (user_id, server_updated_at, id);
create index health_measurements_history_idx
  on public.health_measurements (user_id, metric, measured_on desc)
  where deleted_at is null;

create function private.touch_server_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.server_updated_at := clock_timestamp();
  return new;
end;
$$;

create trigger health_measurements_touch
  before insert or update on public.health_measurements
  for each row execute function private.touch_server_updated_at();

revoke all on function private.touch_server_updated_at() from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Privileges + RLS (owner only; no hard delete from clients)
-- ---------------------------------------------------------------------------
revoke all on public.health_measurements from public, anon, authenticated;
grant select, insert, update on public.health_measurements to authenticated;
grant all on public.health_measurements to service_role;

alter table public.health_measurements enable row level security;

create policy "health_measurements: owner reads" on public.health_measurements
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "health_measurements: owner inserts" on public.health_measurements
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "health_measurements: owner updates" on public.health_measurements
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Batch sync RPC (SECURITY INVOKER: RLS still applies)
-- ---------------------------------------------------------------------------
-- p_rows: json array of measurements (max 500). Each row is upserted by id;
-- an existing row is only overwritten when the incoming client_updated_at is
-- newer (last-write-wins), so replays and out-of-order batches are harmless.
-- user_id always comes from the JWT, never from the payload.
-- Returns the ids whose incoming version was stored or was already current.
create function public.sync_health_measurements(p_rows jsonb)
returns table (id uuid, server_updated_at timestamptz)
language plpgsql
security invoker
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Not authenticated' using errcode = '42501';
  end if;
  if jsonb_typeof(p_rows) <> 'array' then
    raise exception 'p_rows must be a JSON array' using errcode = '22023';
  end if;
  if jsonb_array_length(p_rows) > 500 then
    raise exception 'At most 500 rows per request' using errcode = '54000';
  end if;

  return query
  with incoming as (
    select *
    from jsonb_to_recordset(p_rows) as r(
      id uuid,
      metric public.health_metric,
      measured_on date,
      measured_time time,
      value numeric,
      value2 numeric,
      weight_kg numeric,
      height_cm numeric,
      unit varchar,
      note text,
      client_updated_at timestamptz,
      deleted_at timestamptz
    )
  ),
  upserted as (
    insert into public.health_measurements as t (
      id, user_id, metric, measured_on, measured_time, value, value2,
      weight_kg, height_cm, unit, note, client_updated_at, deleted_at
    )
    select
      i.id, v_uid, i.metric, i.measured_on, i.measured_time, i.value, i.value2,
      i.weight_kg, i.height_cm, i.unit, i.note, i.client_updated_at, i.deleted_at
    from incoming i
    on conflict on constraint health_measurements_pkey do update
      set metric            = excluded.metric,
          measured_on       = excluded.measured_on,
          measured_time     = excluded.measured_time,
          value             = excluded.value,
          value2            = excluded.value2,
          weight_kg         = excluded.weight_kg,
          height_cm         = excluded.height_cm,
          unit              = excluded.unit,
          note              = excluded.note,
          client_updated_at = excluded.client_updated_at,
          deleted_at        = excluded.deleted_at
      where t.user_id = v_uid
        and excluded.client_updated_at > t.client_updated_at
    returning t.id, t.server_updated_at
  )
  select u.id, u.server_updated_at from upserted u
  union all
  -- Already stored with the same or a newer version: acknowledged, not changed.
  select h.id, h.server_updated_at
  from public.health_measurements h
  join incoming i on i.id = h.id
  where h.user_id = v_uid
    and h.client_updated_at >= i.client_updated_at
    and not exists (select 1 from upserted u where u.id = h.id);
end;
$$;

revoke all on function public.sync_health_measurements(jsonb) from public, anon;
grant execute on function public.sync_health_measurements(jsonb) to authenticated, service_role;
