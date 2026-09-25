-- =============================================================================
-- RLS / RBAC integration test for migrations 20260924130326, 20260924130402,
-- 20260924142210 (verification resubmission), 20260924142354 (note rules).
--
-- Run it as `postgres` (SQL editor, psql, or MCP execute_sql). Everything runs
-- in ONE transaction that always ends in an exception, so no test data is ever
-- persisted:
--   success -> ERROR:  ALL <n> TESTS PASSED (changes rolled back)
--   failure -> ERROR:  FAIL <id>: <description>
-- Users are simulated the same way PostgREST does it: role `authenticated`
-- plus `request.jwt.claims`.
-- =============================================================================
do $test$
declare
  u_patient uuid := gen_random_uuid();
  u_doctor  uuid := gen_random_uuid();
  u_admin   uuid := gen_random_uuid();
  u_owner   uuid := gen_random_uuid();
  u_long    uuid := gen_random_uuid();
  u_nometa  uuid := gen_random_uuid();
  passed    int  := 0;
  n         int;
  txt       text;
  inst_id   uuid;
  part_id   uuid;

  -- act as: set_config(..., true) is transaction-local, like PostgREST
begin
  -- ------------------------------------------------------------------ setup
  insert into auth.users (instance_id, id, aud, role, email, raw_user_meta_data)
  values
    ('00000000-0000-0000-0000-000000000000', u_patient, 'authenticated', 'authenticated',
     'patient@test.local', '{"full_name":"Pasien Uji"}'),
    ('00000000-0000-0000-0000-000000000000', u_doctor, 'authenticated', 'authenticated',
     'doctor@test.local', '{"full_name":"dr. Uji"}'),
    ('00000000-0000-0000-0000-000000000000', u_admin, 'authenticated', 'authenticated',
     'admin@test.local', '{"full_name":"Admin Uji"}'),
    ('00000000-0000-0000-0000-000000000000', u_owner, 'authenticated', 'authenticated',
     'rs@test.local', '{"full_name":"Pemilik RS"}'),
    ('00000000-0000-0000-0000-000000000000', u_long, 'authenticated', 'authenticated',
     'long@test.local', jsonb_build_object('full_name', repeat('x', 200))),
    ('00000000-0000-0000-0000-000000000000', u_nometa, 'authenticated', 'authenticated',
     'budi.santoso@test.local', '{}');

  -- T1: signup trigger creates profile from metadata + default `user` role
  select count(*) into n from public.profiles p
    join public.user_roles r on r.user_id = p.id and r.role = 'user'
    where p.id = u_patient and p.full_name = 'Pasien Uji';
  if n <> 1 then raise exception 'FAIL T1: profile/user role not created on signup'; end if;
  passed := passed + 1;

  -- T2: over-long metadata name is truncated instead of failing signup
  select length(full_name) into n from public.profiles where id = u_long;
  if n <> 120 then raise exception 'FAIL T2: long full_name not truncated (len=%)', n; end if;
  passed := passed + 1;

  -- T3: missing metadata falls back to the email local part
  select full_name into txt from public.profiles where id = u_nometa;
  if txt <> 'budi.santoso' then raise exception 'FAIL T3: email fallback gave %', txt; end if;
  passed := passed + 1;

  -- bootstrap superadmin the way the project owner does it (direct SQL)
  insert into public.user_roles (user_id, role) values (u_admin, 'superadmin');

  -- ---------------------------------------------------------------- patient
  perform set_config('role', 'authenticated', true);
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_patient, 'role', 'authenticated')::text, true);

  -- T4: sees only own profile
  select count(*) into n from public.profiles;
  if n <> 1 then raise exception 'FAIL T4: patient sees % profiles', n; end if;
  passed := passed + 1;

  -- T5: sees only own roles
  select count(*) into n from public.user_roles;
  if n <> 1 then raise exception 'FAIL T5: patient sees % role rows', n; end if;
  passed := passed + 1;

  -- T6: cannot grant themselves superadmin
  begin
    insert into public.user_roles (user_id, role) values (u_patient, 'superadmin');
    raise exception 'FAIL T6: patient granted themselves superadmin';
  exception when insufficient_privilege then passed := passed + 1;
  end;

  -- T7: can update own profile
  update public.profiles set full_name = 'Pasien Baru', phone = '081234567890'
    where id = u_patient;
  get diagnostics n = row_count;
  if n <> 1 then raise exception 'FAIL T7: patient could not update own profile'; end if;
  passed := passed + 1;

  -- T8: cannot update someone else's profile (row filtered out)
  update public.profiles set full_name = 'Hacked' where id = u_doctor;
  get diagnostics n = row_count;
  if n <> 0 then raise exception 'FAIL T8: patient updated another profile'; end if;
  passed := passed + 1;

  -- T9: cannot write non-editable columns (column-level grant)
  begin
    update public.profiles set created_at = now() where id = u_patient;
    raise exception 'FAIL T9: patient changed created_at';
  exception when insufficient_privilege then passed := passed + 1;
  end;

  -- T10: audit log is invisible to non-admins
  select count(*) into n from public.audit_logs;
  if n <> 0 then raise exception 'FAIL T10: patient sees audit logs'; end if;
  passed := passed + 1;

  -- ----------------------------------------------------------------- doctor
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_doctor, 'role', 'authenticated')::text, true);

  -- T11: registration is forced to pending even if client sends approved
  insert into public.doctor_profiles (user_id, str_number, specialization, verification_status)
    values (u_doctor, 'STR-001', 'Penyakit Dalam', 'approved');
  select verification_status::text into txt from public.doctor_profiles where user_id = u_doctor;
  if txt <> 'pending' then raise exception 'FAIL T11: doctor registered as %', txt; end if;
  passed := passed + 1;

  -- T12: doctor cannot approve themselves
  begin
    update public.doctor_profiles set verification_status = 'approved' where user_id = u_doctor;
    raise exception 'FAIL T12: doctor self-approved';
  exception when insufficient_privilege then passed := passed + 1;
  end;

  -- T13: cannot register a doctor profile for someone else
  begin
    insert into public.doctor_profiles (user_id, str_number, specialization)
      values (u_patient, 'STR-999', 'Umum');
    raise exception 'FAIL T13: registered doctor profile for another user';
  exception when insufficient_privilege then passed := passed + 1;
  end;

  -- --------------------------------------------------- patient (pending doc)
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_patient, 'role', 'authenticated')::text, true);

  -- T14: pending doctors are not listed
  select count(*) into n from public.doctor_profiles;
  if n <> 0 then raise exception 'FAIL T14: patient sees pending doctor'; end if;
  passed := passed + 1;

  -- ------------------------------------------------------------ superadmin
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_admin, 'role', 'authenticated')::text, true);

  -- T15: approval grants the doctor role and stamps the reviewer
  update public.doctor_profiles
    set verification_status = 'approved', verification_note = 'STR valid'
    where user_id = u_doctor;
  select count(*) into n from public.user_roles where user_id = u_doctor and role = 'doctor';
  if n <> 1 then raise exception 'FAIL T15: doctor role not granted on approval'; end if;
  select count(*) into n from public.doctor_profiles
    where user_id = u_doctor and verified_by = u_admin and verified_at is not null;
  if n <> 1 then raise exception 'FAIL T15: reviewer metadata not stamped'; end if;
  passed := passed + 1;

  -- T16: approval is audit-logged and visible to superadmin
  select count(*) into n from public.audit_logs
    where entity = 'doctor_profiles' and entity_id = u_doctor::text
      and action = 'verification.approved' and actor_id = u_admin;
  if n <> 1 then raise exception 'FAIL T16: approval not in audit log'; end if;
  passed := passed + 1;

  -- T17: superadmin can read every profile (needed for review)
  select count(*) into n from public.profiles;
  if n < 6 then raise exception 'FAIL T17: superadmin sees only % profiles', n; end if;
  passed := passed + 1;

  -- --------------------------------------------------- patient (approved doc)
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_patient, 'role', 'authenticated')::text, true);

  -- T18: approved doctors are listed for every signed-in user
  select count(*) into n from public.doctor_profiles;
  if n <> 1 then raise exception 'FAIL T18: patient does not see approved doctor'; end if;
  passed := passed + 1;

  -- ------------------------------------------------- doctor edits after approval
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_doctor, 'role', 'authenticated')::text, true);

  -- T19: non-credential edits keep the approval
  update public.doctor_profiles set bio = 'Berpengalaman 10 tahun' where user_id = u_doctor;
  select verification_status::text into txt from public.doctor_profiles where user_id = u_doctor;
  if txt <> 'approved' then raise exception 'FAIL T19: bio edit changed status to %', txt; end if;
  passed := passed + 1;

  -- T34: suspending needs a NEW note; the old approval note is not enough
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_admin, 'role', 'authenticated')::text, true);
  begin
    update public.doctor_profiles set verification_status = 'suspended' where user_id = u_doctor;
    raise exception 'FAIL T34: suspended with the stale approval note';
  exception when check_violation then passed := passed + 1;
  end;
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_doctor, 'role', 'authenticated')::text, true);

  -- T20: credential edits send it back to review and revoke the role
  update public.doctor_profiles set str_number = 'STR-002' where user_id = u_doctor;
  select verification_status::text into txt from public.doctor_profiles where user_id = u_doctor;
  select count(*) into n from public.user_roles where user_id = u_doctor and role = 'doctor';
  if txt <> 'pending' or n <> 0 then
    raise exception 'FAIL T20: credential edit left status=% doctor_roles=%', txt, n;
  end if;
  passed := passed + 1;

  -- --------------------------------------------- rejection & resubmission
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_admin, 'role', 'authenticated')::text, true);

  -- T30: rejecting without a note is refused
  begin
    update public.doctor_profiles set verification_status = 'rejected' where user_id = u_doctor;
    raise exception 'FAIL T30: rejected without a note';
  exception when check_violation then passed := passed + 1;
  end;

  -- T31: rejection with a note is visible to the applicant
  update public.doctor_profiles
    set verification_status = 'rejected', verification_note = 'Scan STR tidak terbaca'
    where user_id = u_doctor;
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_doctor, 'role', 'authenticated')::text, true);
  select verification_note into txt from public.doctor_profiles where user_id = u_doctor;
  if txt is distinct from 'Scan STR tidak terbaca' then
    raise exception 'FAIL T31: applicant sees note %', txt;
  end if;
  passed := passed + 1;

  -- T32: editing a rejected registration resubmits it (pending, note cleared)
  update public.doctor_profiles set sip_number = 'SIP-123' where user_id = u_doctor;
  select verification_status::text || '|' || coalesce(verification_note, '<null>') into txt
    from public.doctor_profiles where user_id = u_doctor;
  if txt <> 'pending|<null>' then raise exception 'FAIL T32: resubmission left %', txt; end if;
  passed := passed + 1;

  -- T33: rejection and resubmission are both in the audit trail
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_admin, 'role', 'authenticated')::text, true);
  select count(*) into n from public.audit_logs
    where entity_id = u_doctor::text
      and ((action = 'verification.rejected' and payload ->> 'note' = 'Scan STR tidak terbaca')
        or (action = 'verification.pending' and (payload ->> 'by_owner')::boolean));
  if n < 2 then raise exception 'FAIL T33: audit trail has % matching rows', n; end if;
  passed := passed + 1;

  -- ------------------------------------------ institution (owner_id subject)
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_owner, 'role', 'authenticated')::text, true);
  insert into public.institutions (owner_id, name, type, license_number, address)
    values (u_owner, 'RS Uji Sehat', 'hospital', 'LIC-001', 'Jl. Sehat No. 1')
    returning id into inst_id;

  perform set_config('request.jwt.claims',
    json_build_object('sub', u_admin, 'role', 'authenticated')::text, true);
  update public.institutions set verification_status = 'approved' where id = inst_id;

  -- T21: institution approval grants the institution role to the owner
  select count(*) into n from public.user_roles where user_id = u_owner and role = 'institution';
  if n <> 1 then raise exception 'FAIL T21: institution role not granted'; end if;
  passed := passed + 1;

  -- T22: a superadmin cannot review their own registration
  insert into public.partners (owner_id, business_name, category, nib)
    values (u_admin, 'Apotek Admin', 'pharmacy', 'NIB-001')
    returning id into part_id;
  begin
    update public.partners set verification_status = 'approved' where id = part_id;
    raise exception 'FAIL T22: superadmin approved own registration';
  exception when insufficient_privilege then passed := passed + 1;
  end;

  -- ---------------------------------------------------------------- storage
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_patient, 'role', 'authenticated')::text, true);

  -- T23: upload into own folder is allowed
  insert into storage.objects (bucket_id, name, owner_id)
    values ('verification-docs', u_patient::text || '/str.pdf', u_patient::text);
  passed := passed + 1;

  -- T24: upload into another user's folder is denied
  begin
    insert into storage.objects (bucket_id, name, owner_id)
      values ('verification-docs', u_doctor::text || '/fake.pdf', u_patient::text);
    raise exception 'FAIL T24: uploaded into another user folder';
  exception when insufficient_privilege then passed := passed + 1;
  end;

  -- T25: other users cannot read the file; superadmin can
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_doctor, 'role', 'authenticated')::text, true);
  select count(*) into n from storage.objects where bucket_id = 'verification-docs';
  if n <> 0 then raise exception 'FAIL T25: doctor sees patient documents'; end if;
  perform set_config('request.jwt.claims',
    json_build_object('sub', u_admin, 'role', 'authenticated')::text, true);
  select count(*) into n from storage.objects where bucket_id = 'verification-docs';
  if n <> 1 then raise exception 'FAIL T25: superadmin sees % documents', n; end if;
  passed := passed + 1;

  -- ------------------------------------------------------------------- anon
  perform set_config('role', 'anon', true);
  perform set_config('request.jwt.claims', '{"role":"anon"}', true);

  -- T26: anon has no table access at all
  begin
    select count(*) into n from public.profiles;
    raise exception 'FAIL T26: anon can read profiles';
  exception when insufficient_privilege then passed := passed + 1;
  end;

  -- T27: helper functions are not callable by anon (schema not granted)
  begin
    perform private.is_superadmin();
    raise exception 'FAIL T27: anon executed private.is_superadmin()';
  exception when insufficient_privilege then passed := passed + 1;
  end;

  -- --------------------------------------------------------------- catalog
  perform set_config('role', 'none', true);

  -- T28: no SECURITY DEFINER helpers leaked into the exposed public schema
  select count(*) into n from pg_proc p join pg_namespace ns on ns.oid = p.pronamespace
    where ns.nspname = 'public' and p.prosecdef;
  if n <> 0 then raise exception 'FAIL T28: % security definer functions in public', n; end if;
  passed := passed + 1;

  -- T29: RLS enabled on every table in public
  select count(*) into n from pg_class c join pg_namespace ns on ns.oid = c.relnamespace
    where ns.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity;
  if n <> 0 then raise exception 'FAIL T29: % public tables without RLS', n; end if;
  passed := passed + 1;

  raise exception 'ALL % TESTS PASSED (changes rolled back)', passed;
end;
$test$;
