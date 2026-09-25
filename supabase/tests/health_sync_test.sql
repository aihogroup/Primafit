-- =============================================================================
-- Integration test for public.health_measurements + sync_health_measurements().
-- Run as `postgres`; ends with a deliberate exception so nothing is persisted:
--   success -> ERROR:  ALL <n> HEALTH SYNC TESTS PASSED (changes rolled back)
-- =============================================================================
do $test$
declare
  u_a    uuid := gen_random_uuid();
  u_b    uuid := gen_random_uuid();
  m1     uuid := gen_random_uuid();
  m2     uuid := gen_random_uuid();
  passed int  := 0;
  n      int;
  v      numeric;
  big    jsonb;
begin
  insert into auth.users (instance_id, id, aud, role, email, raw_user_meta_data)
  values
    ('00000000-0000-0000-0000-000000000000', u_a, 'authenticated', 'authenticated', 'a@test.local', '{}'),
    ('00000000-0000-0000-0000-000000000000', u_b, 'authenticated', 'authenticated', 'b@test.local', '{}');

  perform set_config('role', 'authenticated', true);
  perform set_config('request.jwt.claims', json_build_object('sub', u_a, 'role', 'authenticated')::text, true);

  -- H1: batch upsert stores rows for the caller; payload user_id is ignored
  select count(*) into n from public.sync_health_measurements(jsonb_build_array(
    jsonb_build_object('id', m1, 'user_id', u_b, 'metric', 'cholesterol', 'measured_on', '2026-09-20',
                       'measured_time', '07:30', 'value', 190, 'unit', 'mg/dL',
                       'client_updated_at', '2026-09-20T07:31:00Z'),
    jsonb_build_object('id', m2, 'metric', 'blood_pressure', 'measured_on', '2026-09-21',
                       'value', 120, 'value2', 80, 'client_updated_at', '2026-09-21T08:00:00Z')
  ));
  if n <> 2 then raise exception 'FAIL H1: % rows acknowledged', n; end if;
  select count(*) into n from public.health_measurements where user_id = u_a;
  if n <> 2 then raise exception 'FAIL H1: % rows stored for caller', n; end if;
  passed := passed + 1;

  -- H2: an older version is acknowledged but does not overwrite (last-write-wins)
  select count(*) into n from public.sync_health_measurements(jsonb_build_array(
    jsonb_build_object('id', m1, 'metric', 'cholesterol', 'measured_on', '2026-09-20',
                       'value', 999, 'client_updated_at', '2026-09-20T07:00:00Z')));
  select value into v from public.health_measurements where id = m1;
  if n <> 1 or v <> 190 then raise exception 'FAIL H2: ack=% value=%', n, v; end if;
  passed := passed + 1;

  -- H3: a newer version overwrites
  perform public.sync_health_measurements(jsonb_build_array(
    jsonb_build_object('id', m1, 'metric', 'cholesterol', 'measured_on', '2026-09-20',
                       'value', 185, 'client_updated_at', '2026-09-20T09:00:00Z')));
  select value into v from public.health_measurements where id = m1;
  if v <> 185 then raise exception 'FAIL H3: value=%', v; end if;
  passed := passed + 1;

  -- H4: replaying the same payload is idempotent
  perform public.sync_health_measurements(jsonb_build_array(
    jsonb_build_object('id', m1, 'metric', 'cholesterol', 'measured_on', '2026-09-20',
                       'value', 185, 'client_updated_at', '2026-09-20T09:00:00Z')));
  select count(*) into n from public.health_measurements;
  if n <> 2 then raise exception 'FAIL H4: % rows after replay', n; end if;
  passed := passed + 1;

  -- H5: soft delete keeps a tombstone
  perform public.sync_health_measurements(jsonb_build_array(
    jsonb_build_object('id', m2, 'metric', 'blood_pressure', 'measured_on', '2026-09-21',
                       'value', 120, 'value2', 80, 'client_updated_at', '2026-09-22T10:00:00Z',
                       'deleted_at', '2026-09-22T10:00:00Z')));
  select count(*) into n from public.health_measurements where id = m2 and deleted_at is not null;
  if n <> 1 then raise exception 'FAIL H5: tombstone missing'; end if;
  passed := passed + 1;

  -- H6: blood pressure without diastolic is rejected
  begin
    perform public.sync_health_measurements(jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'metric', 'blood_pressure',
                         'measured_on', '2026-09-23', 'value', 120,
                         'client_updated_at', '2026-09-23T10:00:00Z')));
    raise exception 'FAIL H6: blood pressure without value2 accepted';
  exception when check_violation then passed := passed + 1;
  end;

  -- H7: more than 500 rows per request is refused
  select jsonb_agg(jsonb_build_object('id', gen_random_uuid(), 'metric', 'bmi',
                   'measured_on', '2026-09-23', 'value', 22,
                   'client_updated_at', '2026-09-23T10:00:00Z'))
    into big from generate_series(1, 501);
  begin
    perform public.sync_health_measurements(big);
    raise exception 'FAIL H7: 501 rows accepted';
  exception when program_limit_exceeded then passed := passed + 1;
  end;

  -- H8: clients cannot hard-delete
  begin
    delete from public.health_measurements where id = m1;
    raise exception 'FAIL H8: hard delete allowed';
  exception when insufficient_privilege then passed := passed + 1;
  end;

  -- ------------------------------------------------------------ other user
  perform set_config('request.jwt.claims', json_build_object('sub', u_b, 'role', 'authenticated')::text, true);

  -- H9: another account sees nothing
  select count(*) into n from public.health_measurements;
  if n <> 0 then raise exception 'FAIL H9: other user sees % rows', n; end if;
  passed := passed + 1;

  -- H10: another account cannot overwrite by reusing an id
  begin
    perform public.sync_health_measurements(jsonb_build_array(
      jsonb_build_object('id', m1, 'metric', 'cholesterol', 'measured_on', '2026-09-20',
                         'value', 1, 'client_updated_at', '2030-01-01T00:00:00Z')));
  exception when insufficient_privilege then null;
  end;
  perform set_config('role', 'none', true);
  select value into v from public.health_measurements where id = m1;
  if v <> 185 then raise exception 'FAIL H10: foreign overwrite changed value to %', v; end if;
  passed := passed + 1;

  -- H11: anon cannot call the RPC
  perform set_config('role', 'anon', true);
  perform set_config('request.jwt.claims', '{"role":"anon"}', true);
  begin
    perform public.sync_health_measurements('[]'::jsonb);
    raise exception 'FAIL H11: anon executed sync RPC';
  exception when insufficient_privilege then passed := passed + 1;
  end;

  -- H12: rows written by one statement get distinct server timestamps
  --      (clock_timestamp), so the keyset pull cursor never skips a row
  perform set_config('role', 'none', true);
  insert into public.health_measurements (id, user_id, metric, measured_on, value, client_updated_at)
  select gen_random_uuid(), u_b, 'bmi', '2026-09-24', 21 + g, now() from generate_series(1, 3) g;
  select count(distinct server_updated_at) into n from public.health_measurements where user_id = u_b;
  if n <> 3 then raise exception 'FAIL H12: % distinct server timestamps for 3 rows', n; end if;
  passed := passed + 1;

  raise exception 'ALL % HEALTH SYNC TESTS PASSED (changes rolled back)', passed;
end;
$test$;
