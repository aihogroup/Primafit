-- =============================================================================
-- Sprint 1 · Identity & Role-Based Access Control (RBAC)
-- -----------------------------------------------------------------------------
-- Roles     : user, doctor, institution, partner, superadmin
-- Principle : every account is a `user`; professional roles (doctor,
--             institution, partner) are granted only after a superadmin
--             approves a verification request. All tables use RLS.
-- Rollback  : supabase/rollbacks/20260924000100_identity_rbac.down.sql
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.app_role as enum ('user', 'doctor', 'institution', 'partner', 'superadmin');

create type public.verification_status as enum ('pending', 'approved', 'rejected', 'suspended');

create type public.institution_type as enum ('hospital', 'clinic', 'puskesmas', 'pmr', 'health_organization', 'laboratory');

create type public.partner_category as enum ('pharmacy', 'skincare', 'fashion', 'fitness', 'nutrition', 'other');

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
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

comment on table public.profiles is 'Personal profile for every account (all roles).';

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

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

comment on table public.user_roles is 'Role assignments. Only superadmins (or verification approval) may grant roles.';

-- Role checks used by RLS. SECURITY DEFINER avoids recursive RLS evaluation
-- on user_roles; search_path is pinned to prevent hijacking.
create or replace function public.has_role(check_role public.app_role)
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

create or replace function public.is_superadmin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.has_role('superadmin');
$$;

-- ---------------------------------------------------------------------------
-- Institutions (hospital, clinic, PMR, health organisation)
-- ---------------------------------------------------------------------------
create table public.institutions (
  id                   uuid primary key default gen_random_uuid(),
  owner_id             uuid not null references public.profiles (id) on delete restrict,
  name                 varchar(160) not null,
  type                 public.institution_type not null,
  license_number       varchar(64)  not null unique,
  address              text not null,
  latitude             numeric(9, 6) check (latitude between -90 and 90),
  longitude            numeric(9, 6) check (longitude between -180 and 180),
  phone                varchar(20),
  email                varchar(254),
  verification_status  public.verification_status not null default 'pending',
  verified_at          timestamptz,
  verified_by          uuid references public.profiles (id) on delete set null,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index institutions_owner_idx on public.institutions (owner_id);
create index institutions_pending_idx on public.institutions (created_at) where verification_status = 'pending';

create trigger institutions_set_updated_at
  before update on public.institutions
  for each row execute function public.set_updated_at();

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
  verified_at          timestamptz,
  verified_by          uuid references public.profiles (id) on delete set null,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index doctor_profiles_institution_idx on public.doctor_profiles (institution_id);
create index doctor_profiles_specialization_idx on public.doctor_profiles (specialization)
  where verification_status = 'approved';
create index doctor_profiles_pending_idx on public.doctor_profiles (created_at) where verification_status = 'pending';

create trigger doctor_profiles_set_updated_at
  before update on public.doctor_profiles
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Partners (pharmacy, skincare store, fashion, gym, ...)
-- ---------------------------------------------------------------------------
create table public.partners (
  id                   uuid primary key default gen_random_uuid(),
  owner_id             uuid not null references public.profiles (id) on delete restrict,
  business_name        varchar(160) not null,
  category             public.partner_category not null,
  nib                  varchar(20)  not null unique, -- Nomor Induk Berusaha (OSS)
  address              text,
  phone                varchar(20),
  logo_path            text,
  verification_status  public.verification_status not null default 'pending',
  verified_at          timestamptz,
  verified_by          uuid references public.profiles (id) on delete set null,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index partners_owner_idx on public.partners (owner_id);
create index partners_category_idx on public.partners (category) where verification_status = 'approved';
create index partners_pending_idx on public.partners (created_at) where verification_status = 'pending';

create trigger partners_set_updated_at
  before update on public.partners
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Audit log (append-only)
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

-- ---------------------------------------------------------------------------
-- Verification guard: only superadmins may change verification fields.
-- Approval grants the matching role; revoking approval removes it.
-- ---------------------------------------------------------------------------
create or replace function public.guard_verification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_role  public.app_role := tg_argv[0]::public.app_role;
  subject_user uuid;
begin
  if new.verification_status is distinct from old.verification_status then
    if not public.is_superadmin() then
      raise exception 'Only superadmin can change verification status'
        using errcode = '42501';
    end if;

    new.verified_by := (select auth.uid());
    new.verified_at := case when new.verification_status = 'approved' then now() end;

    subject_user := case tg_table_name
      when 'doctor_profiles' then new.user_id
      else new.owner_id
    end;

    if new.verification_status = 'approved' then
      insert into public.user_roles (user_id, role, granted_by)
      values (subject_user, target_role, (select auth.uid()))
      on conflict (user_id, role) do nothing;
    elsif old.verification_status = 'approved' then
      delete from public.user_roles where user_id = subject_user and role = target_role;
    end if;

    insert into public.audit_logs (actor_id, action, entity, entity_id, payload)
    values (
      (select auth.uid()),
      'verification.' || new.verification_status,
      tg_table_name,
      case tg_table_name when 'doctor_profiles' then new.user_id::text else new.id::text end,
      jsonb_build_object('from', old.verification_status, 'to', new.verification_status)
    );
  elsif new.verified_by is distinct from old.verified_by
     or new.verified_at is distinct from old.verified_at then
    raise exception 'Verification metadata is read-only' using errcode = '42501';
  end if;

  return new;
end;
$$;

create trigger doctor_profiles_guard_verification
  before update on public.doctor_profiles
  for each row execute function public.guard_verification('doctor');

create trigger institutions_guard_verification
  before update on public.institutions
  for each row execute function public.guard_verification('institution');

create trigger partners_guard_verification
  before update on public.partners
  for each row execute function public.guard_verification('partner');

-- New registrations always start as pending, regardless of client payload.
create or replace function public.force_pending_on_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.verification_status := 'pending';
  new.verified_at := null;
  new.verified_by := null;
  return new;
end;
$$;

create trigger doctor_profiles_force_pending
  before insert on public.doctor_profiles
  for each row execute function public.force_pending_on_insert();

create trigger institutions_force_pending
  before insert on public.institutions
  for each row execute function public.force_pending_on_insert();

create trigger partners_force_pending
  before insert on public.partners
  for each row execute function public.force_pending_on_insert();

-- ---------------------------------------------------------------------------
-- New auth user -> profile + default `user` role
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''), split_part(new.email, '@', 1), 'Pengguna')
  );

  insert into public.user_roles (user_id, role) values (new.id, 'user');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles        enable row level security;
alter table public.user_roles      enable row level security;
alter table public.institutions    enable row level security;
alter table public.doctor_profiles enable row level security;
alter table public.partners        enable row level security;
alter table public.audit_logs      enable row level security;

-- profiles
create policy "profiles: read own or superadmin" on public.profiles
  for select to authenticated
  using (id = (select auth.uid()) or (select public.is_superadmin()));

create policy "profiles: update own" on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- user_roles: users can see their roles; only superadmin manages them directly
create policy "user_roles: read own or superadmin" on public.user_roles
  for select to authenticated
  using (user_id = (select auth.uid()) or (select public.is_superadmin()));

create policy "user_roles: superadmin manages" on public.user_roles
  for all to authenticated
  using ((select public.is_superadmin()))
  with check ((select public.is_superadmin()));

-- doctor_profiles: approved doctors are public to signed-in users
create policy "doctors: read approved, own, or superadmin" on public.doctor_profiles
  for select to authenticated
  using (
    verification_status = 'approved'
    or user_id = (select auth.uid())
    or (select public.is_superadmin())
  );

create policy "doctors: register self" on public.doctor_profiles
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "doctors: update own or superadmin" on public.doctor_profiles
  for update to authenticated
  using (user_id = (select auth.uid()) or (select public.is_superadmin()))
  with check (user_id = (select auth.uid()) or (select public.is_superadmin()));

-- institutions
create policy "institutions: read approved, own, or superadmin" on public.institutions
  for select to authenticated
  using (
    verification_status = 'approved'
    or owner_id = (select auth.uid())
    or (select public.is_superadmin())
  );

create policy "institutions: register self" on public.institutions
  for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy "institutions: update own or superadmin" on public.institutions
  for update to authenticated
  using (owner_id = (select auth.uid()) or (select public.is_superadmin()))
  with check (owner_id = (select auth.uid()) or (select public.is_superadmin()));

-- partners
create policy "partners: read approved, own, or superadmin" on public.partners
  for select to authenticated
  using (
    verification_status = 'approved'
    or owner_id = (select auth.uid())
    or (select public.is_superadmin())
  );

create policy "partners: register self" on public.partners
  for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy "partners: update own or superadmin" on public.partners
  for update to authenticated
  using (owner_id = (select auth.uid()) or (select public.is_superadmin()))
  with check (owner_id = (select auth.uid()) or (select public.is_superadmin()));

-- audit_logs: superadmin read-only; writes happen through SECURITY DEFINER functions
create policy "audit_logs: superadmin reads" on public.audit_logs
  for select to authenticated
  using ((select public.is_superadmin()));

-- Least privilege: anon gets nothing on these tables.
revoke all on public.profiles, public.user_roles, public.institutions,
              public.doctor_profiles, public.partners, public.audit_logs from anon;
-- Functions are executable by PUBLIC by default, so revoke from PUBLIC (which
-- anon inherits) and grant back only to signed-in users.
revoke execute on function public.has_role(public.app_role), public.is_superadmin() from public, anon;
grant  execute on function public.has_role(public.app_role), public.is_superadmin() to authenticated;
