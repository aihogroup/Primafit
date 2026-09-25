-- =============================================================================
-- Sprint 1 · Verification note rules (fix found by supabase/tests T30)
-- -----------------------------------------------------------------------------
-- * credential edit that sends an approved record back to 'pending' also clears
--   the old review note
-- * reject / suspend requires a NEW note (not the previous one)
-- Rollback: re-run guard_verification() from 20260924142210_verification_resubmission.sql
-- =============================================================================

create or replace function private.guard_verification()
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

    if old.verification_status = 'rejected' then
      -- The owner fixed their data: resubmit for review.
      new.verification_status := 'pending';
      new.verification_note := null;
      new.verified_at := null;
      new.verified_by := null;
    elsif old.verification_status = 'approved' then
      for i in 2 .. tg_nargs - 1 loop
        if (new_row ->> tg_argv[i]) is distinct from (old_row ->> tg_argv[i]) then
          new.verification_status := 'pending';
          new.verification_note := null;
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
    -- A fresh note is required: an older note (e.g. from the approval) must
    -- not silently justify a rejection or suspension.
    if new.verification_status in ('rejected', 'suspended')
       and (nullif(trim(new.verification_note), '') is null
            or new.verification_note is not distinct from old.verification_note) then
      raise exception 'A note is required when rejecting or suspending'
        using errcode = '23514';
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
        'note', coalesce(new.verification_note, old.verification_note),
        'by_owner', not is_admin
      )
    );
  end if;

  return new;
end;
$$;

revoke all on function private.guard_verification() from public, anon, authenticated;
