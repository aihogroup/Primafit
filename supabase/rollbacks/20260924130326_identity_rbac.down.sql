-- Rollback for 20260924130326_identity_rbac.sql (run manually; destructive).
-- Run 20260924130402_storage_buckets.down.sql first (its policies use private.is_superadmin).
drop trigger if exists on_auth_user_created on auth.users;

drop table if exists public.audit_logs;
drop table if exists public.partners;
drop table if exists public.doctor_profiles;
drop table if exists public.institutions;
drop table if exists public.user_roles;
drop table if exists public.profiles;

drop function if exists private.handle_new_user();
drop function if exists private.guard_verification();
drop function if exists private.force_pending_on_insert();
drop function if exists private.is_superadmin();
drop function if exists private.has_role(public.app_role);
drop function if exists private.set_updated_at();
drop schema if exists private;

drop type if exists public.partner_category;
drop type if exists public.institution_type;
drop type if exists public.verification_status;
drop type if exists public.app_role;
