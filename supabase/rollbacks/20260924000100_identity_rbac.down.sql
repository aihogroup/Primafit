-- Rollback for 20260924000100_identity_rbac.sql (run manually; destructive).
drop trigger if exists on_auth_user_created on auth.users;

drop table if exists public.audit_logs;
drop table if exists public.partners;
drop table if exists public.doctor_profiles;
drop table if exists public.institutions;
drop table if exists public.user_roles;
drop table if exists public.profiles;

drop function if exists public.handle_new_user();
drop function if exists public.force_pending_on_insert();
drop function if exists public.guard_verification();
drop function if exists public.is_superadmin();
drop function if exists public.has_role(public.app_role);
drop function if exists public.set_updated_at();

drop type if exists public.partner_category;
drop type if exists public.institution_type;
drop type if exists public.verification_status;
drop type if exists public.app_role;
