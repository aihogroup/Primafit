-- =============================================================================
-- Sprint 1 · Identity & Role-Based Access Control (RBAC)
-- -----------------------------------------------------------------------------
-- Roles     : user, doctor, institution, partner, superadmin
-- Principle : every account is a `user`; professional roles (doctor,
--             institution, partner) are granted only when a superadmin
--             approves the registration. All tables use RLS + explicit grants.
-- Helpers   : SECURITY DEFINER functions live in schema `private`, which is
--             not exposed through the Data API (no RPC access).
-- Rollback  : supabase/rollbacks/20260924130326_identity_rbac.down.sql
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Schema for internal helpers (never add it to "Exposed schemas")
-- ---------------------------------------------------------------------------
create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.app_role as enum ('user', 'doctor', 'institution', 'partner', 'superadmin');

create type public.verification_status as enum ('pending', 'approved', 'rejected', 'suspended');

create type public.institution_type as enum (
  'hospital', 'clinic', 'puskesmas', 'pmr', 'health_organization', 'laboratory'
);

create type public.partner_category as enum (
  'pharmacy', 'skincare', 'fashion', 'fitness', 'nutrition', 'other'
);

-- ---------------------------------------------------------------------------
-- Shared trigger: updated_at
-- ---------------------------------------------------------------------------
create function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- profiles: 1:1 with auth.users, personal data of every account
-- ---------------------------------------------------------------------------
create table public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  full_name    varchar(120) not null check (length(trim(full_name)) > 0),
  phone        varchar(20)  check (phone ~ '^\+?[0-9]{10,15}$'),
  birth_date   date         check (birth_date <= current_date),
  gender       varchar(10)  check (gender in ('male', 'female')),
  blood_type   varchar(3)   check (blood_type in ('A', 'B', 'AB', 'O')),
  avatar_path  text,
  created_at   timestamptz  not null default now(),
  updated_at   timestamptz  not null default now()
);

comment on table public.profiles is 'Personal profile for every account (all roles). Private: owner + superadmin only.';

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- user_roles: many roles per account
-- ---------------------------------------------------------------------------
create table public.user_roles (
  user_id     uuid            not null references public.profiles (id) on delete cascade,
  role        public.app_role not null,
  granted_at  timestamptz     not null default now(),
  granted_by  uuid            references public.profiles (id) on delete set null,
  primary key (user_id, role)
);

create index user_roles_role_idx on public.user_roles (role);
create index user_roles_granted_by_idx on public.user_roles (granted_by);

comment on table public.user_roles is 'Role assignments. Granted by superadmins or by verification approval.';

-- Role checks used by RLS. SECURITY DEFINER avoids recursive RLS evaluation on
-- user_roles; search_path is pinned to prevent object hijacking.
create function private.has_role(check_role public.app_role)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.user_roles ur
    where ur.user_id = (select auth.uid())
      and ur.role = check_role
  );
$$;

create function private.is_superadmin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.has_role('superadmin');
$$;

-- ---------------------------------------------------------------------------
-- Institutions (hospital, clinic, puskesmas, PMR, health organisation, lab)
-- ---------------------------------------------------------------------------
create table public.institutions (
  id                   uuid primary key default gen_random_uuid(),
  owner_id             uuid not null references public.profiles (id) on delete restrict,
  name                 varchar(160) not null check (length(trim(name)) > 0),
  type                 public.institution_type not null,
  license_number       varchar(64)  not null unique,
  address              text not null,
  latitude             numeric(9, 6) check (latitude between -90 and 90),
  longitude            numeric(9, 6) check (longitude between -180 and 180),
  phone                varchar(20),
  email                varchar(254),
  verification_status  public.verification_status not null default 'pending',
  verification_note    text,
  verified_at          timestamptz,
  verified_by          uuid references public.profiles (id) on delete set null,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index institutions_owner_idx on public.institutions (owner_id);
create index institutions_verified_by_idx on public.institutions (verified_by);
create index institutions_pending_idx on public.institutions (created_at)
  where verification_status = 'pending';

create trigger institutions_set_updated_at
  before update on public.institutions
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Doctors
-- ---------------------------------------------------------------------------
create table public.doctor_profiles (
  user_id              uuid primary key references public.profiles (id) on delete cascade,
  str_number           varchar(32)  not null unique, -- Surat Tanda Registrasi (KKI)
  sip_number           varchar(64),                  -- Surat Izin Praktik
  specialization       varchar(80)  not null,
  institution_id       uuid references public.institutions (id) on delete set null,
  consultation_fee     numeric(12, 2) not null default 0 check (consultation_fee >= 0),
  bio                  text,
  verification_status  public.verification_status not null default 'pending',
  verification_note    text,
  verified_at          timestamptz,
  verified_by          uuid references public.profiles (id) on delete set null,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index doctor_profiles_institution_idx on public.doctor_profiles (institution_id);
create index doctor_profiles_verified_by_idx on public.doctor_profiles (verified_by);
create index doctor_profiles_specialization_idx on public.doctor_profiles (specialization)
  where verification_status = 'approved';
create index doctor_profiles_pending_idx on public.doctor_profiles (created_at)
  where verification_status = 'pending';

create trigger doctor_profiles_set_updated_at
  before update on public.doctor_profiles
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Partners (pharmacy, skincare store, fashion, gym, ...)
-- ---------------------------------------------------------------------------
create table public.partners (
  id                   uuid primary key default gen_random_uuid(),
  owner_id             uuid not null references public.profiles (id) on delete restrict,
  business_name        varchar(160) not null check (length(trim(business_name)) > 0),
  category             public.partner_category not null,
  nib                  varchar(20)  not null unique, -- Nomor Induk Berusaha (OSS)
  address              text,
  phone                varchar(20),
  logo_path            text,
  verification_status  public.verification_status not null default 'pending',
  verification_note    text,
  verified_at          timestamptz,
  verified_by          uuid references public.profiles (id) on delete set null,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index partners_owner_idx on public.partners (owner_id);
create index partners_verified_by_idx on public.partners (verified_by);
create index partners_category_idx on public.partners (category)
  where verification_status = 'approved';
create index partners_pending_idx on public.partners (created_at)
  where verification_status = 'pending';

create trigger partners_set_updated_at
  before update on public.partners
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Audit log (append-only; written only by SECURITY DEFINER triggers)
-- ---------------------------------------------------------------------------
create table public.audit_logs (
  id          bigint generated always as identity primary key,
  actor_id    uuid references public.profiles (id) on delete set null,
  action      varchar(64) not null,
  entity      varchar(64) not null,
  entity_id   text        not null,
  payload     jsonb       not null default '{}'::jsonb,
  created_at  timestamptz not null default now()
);

create index audit_logs_entity_idx on public.audit_logs (entity, entity_id);
create index audit_logs_actor_idx on public.audit_logs (actor_id);
create index audit_logs_created_at_idx on public.audit_logs (created_at desc);

-- ---------------------------------------------------------------------------
-- New registrations always start as pending, whatever the client sends.
-- ---------------------------------------------------------------------------
create function private.force_pending_on_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.verification_status := 'pending';
  new.verification_note := null;
  new.verified_at := null;
  new.verified_by := null;
  return new;
end;
$$;

create trigger doctor_profiles_force_pending
  before insert on public.doctor_profiles
  for each row execute function private.force_pending_on_insert();

create trigger institutions_force_pending
  before insert on public.institutions
  for each row execute function private.force_pending_on_insert();

create trigger partners_force_pending
  before insert on public.partners
  for each row execute function private.force_pending_on_insert();

-- ---------------------------------------------------------------------------
-- Verification guard (shared by doctor_profiles, institutions, partners)
--
-- Trigger arguments: (role, subject_column, credential_column, ...)
--   role              role granted on approval
--   subject_column    column holding the account that receives the role
--   credential_column fields whose change sends an approved record back to review
--
-- Rules:
--   * only a superadmin may change verification_status / note / metadata
--   * a superadmin cannot review their own registration
--   * an owner editing credentials of an approved record -> back to 'pending'
--   * approved -> role granted; leaving approved -> role revoked; audit logged
-- Row fields are read through to_jsonb() so one function serves all tables.
-- ---------------------------------------------------------------------------
create function private.guard_verification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_role  public.app_role := tg_argv[0]::public.app_role;
  new_row      jsonb := to_jsonb(new);
  old_row      jsonb := to_jsonb(old);
  subject_user uuid  := (new_row ->> tg_argv[1])::uuid;
  actor        uuid  := (select auth.uid());
  -- Reviewer = superadmin user, service_role (Edge Functions), or a direct DB
  -- session without JWT (project owner via SQL editor). Data API requests
  -- always carry JWT claims, so clients cannot take the last path.
  is_admin     boolean := private.is_superadmin()
                          or (select auth.role()) = 'service_role'
                          or nullif(current_setting('request.jwt.claims', true), '') is null;
  i            int;
begin
  if not is_admin then
    if new.verification_status is distinct from old.verification_status
       or new.verification_note is distinct from old.verification_note
       or new.verified_by is distinct from old.verified_by
       or new.verified_at is distinct from old.verified_at then
      raise exception 'Only a superadmin can change verification fields'
        using errcode = '42501';
    end if;

    if old.verification_status = 'approved' then
      for i in 2 .. tg_nargs - 1 loop
        if (new_row ->> tg_argv[i]) is distinct from (old_row ->> tg_argv[i]) then
          new.verification_status := 'pending';
          new.verified_at := null;
          new.verified_by := null;
          exit;
        end if;
      end loop;
    end if;
  elsif new.verification_status is distinct from old.verification_status then
    if subject_user = actor then
      raise exception 'A superadmin cannot review their own registration'
        using errcode = '42501';
    end if;
    new.verified_by := actor;
    new.verified_at := case when new.verification_status = 'approved' then now() end;
  end if;

  if new.verification_status is distinct from old.verification_status then
    if new.verification_status = 'approved' then
      insert into public.user_roles (user_id, role, granted_by)
      values (subject_user, target_role, actor)
      on conflict (user_id, role) do nothing;
    elsif old.verification_status = 'approved' then
      delete from public.user_roles
      where user_id = subject_user and role = target_role;
    end if;

    insert into public.audit_logs (actor_id, action, entity, entity_id, payload)
    values (
      actor,
      'verification.' || new.verification_status,
      tg_table_name,
      coalesce(new_row ->> 'id', new_row ->> 'user_id'),
      jsonb_build_object(
        'from', old.verification_status,
        'to', new.verification_status,
        'note', new.verification_note,
        'by_owner', not is_admin
      )
    );
  end if;

  return new;
end;
$$;

create trigger doctor_profiles_guard_verification
  before update on public.doctor_profiles
  for each row execute function private.guard_verification(
    'doctor', 'user_id', 'str_number', 'sip_number', 'specialization'
  );

create trigger institutions_guard_verification
  before update on public.institutions
  for each row execute function private.guard_verification(
    'institution', 'owner_id', 'license_number', 'name', 'type'
  );

create trigger partners_guard_verification
  before update on public.partners
  for each row execute function private.guard_verification(
    'partner', 'owner_id', 'nib', 'business_name', 'category'
  );

-- ---------------------------------------------------------------------------
-- New auth user -> profile + default `user` role
-- ---------------------------------------------------------------------------
create function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    left(
      coalesce(
        nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
        nullif(split_part(new.email, '@', 1), ''),
        'Pengguna'
      ),
      120
    )
  );

  insert into public.user_roles (user_id, role) values (new.id, 'user');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- ---------------------------------------------------------------------------
-- Function privileges: only the RLS helpers are executable, by signed-in users.
-- Trigger functions need no EXECUTE grant to fire.
-- ---------------------------------------------------------------------------
revoke all on all functions in schema private from public, anon, authenticated;
grant execute on function private.has_role(public.app_role), private.is_superadmin()
  to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Table privileges (explicit, least privilege). RLS then filters rows.
-- ---------------------------------------------------------------------------
revoke all on public.profiles, public.user_roles, public.institutions,
              public.doctor_profiles, public.partners, public.audit_logs
  from public, anon, authenticated;

grant select on public.profiles to authenticated;
grant update (full_name, phone, birth_date, gender, blood_type, avatar_path)
  on public.profiles to authenticated;

grant select, insert, delete on public.user_roles to authenticated;

grant select, insert, update on public.doctor_profiles, public.institutions, public.partners
  to authenticated;

grant select on public.audit_logs to authenticated;

grant all on public.profiles, public.user_roles, public.institutions,
             public.doctor_profiles, public.partners, public.audit_logs
  to service_role;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles        enable row level security;
alter table public.user_roles      enable row level security;
alter table public.institutions    enable row level security;
alter table public.doctor_profiles enable row level security;
alter table public.partners        enable row level security;
alter table public.audit_logs      enable row level security;

-- profiles: private to the owner (superadmin can read for verification)
create policy "profiles: read own or superadmin" on public.profiles
  for select to authenticated
  using (id = (select auth.uid()) or (select private.is_superadmin()));

create policy "profiles: update own" on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- user_roles: read own; only superadmin grants/revokes directly
create policy "user_roles: read own or superadmin" on public.user_roles
  for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_superadmin()));

create policy "user_roles: superadmin grants" on public.user_roles
  for insert to authenticated
  with check ((select private.is_superadmin()));

create policy "user_roles: superadmin revokes" on public.user_roles
  for delete to authenticated
  using ((select private.is_superadmin()));

-- doctor_profiles: approved doctors are visible to every signed-in user
create policy "doctors: read approved, own, or superadmin" on public.doctor_profiles
  for select to authenticated
  using (
    verification_status = 'approved'
    or user_id = (select auth.uid())
    or (select private.is_superadmin())
  );

create policy "doctors: register self" on public.doctor_profiles
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "doctors: update own or superadmin" on public.doctor_profiles
  for update to authenticated
  using (user_id = (select auth.uid()) or (select private.is_superadmin()))
  with check (user_id = (select auth.uid()) or (select private.is_superadmin()));

-- institutions
create policy "institutions: read approved, own, or superadmin" on public.institutions
  for select to authenticated
  using (
    verification_status = 'approved'
    or owner_id = (select auth.uid())
    or (select private.is_superadmin())
  );

create policy "institutions: register self" on public.institutions
  for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy "institutions: update own or superadmin" on public.institutions
  for update to authenticated
  using (owner_id = (select auth.uid()) or (select private.is_superadmin()))
  with check (owner_id = (select auth.uid()) or (select private.is_superadmin()));

-- partners
create policy "partners: read approved, own, or superadmin" on public.partners
  for select to authenticated
  using (
    verification_status = 'approved'
    or owner_id = (select auth.uid())
    or (select private.is_superadmin())
  );

create policy "partners: register self" on public.partners
  for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy "partners: update own or superadmin" on public.partners
  for update to authenticated
  using (owner_id = (select auth.uid()) or (select private.is_superadmin()))
  with check (owner_id = (select auth.uid()) or (select private.is_superadmin()));

-- audit_logs: superadmin read-only
create policy "audit_logs: superadmin reads" on public.audit_logs
  for select to authenticated
  using ((select private.is_superadmin()));
