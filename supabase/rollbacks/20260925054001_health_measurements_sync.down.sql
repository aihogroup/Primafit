-- Rollback for 20260925054001_health_measurements_sync.sql (destructive: drops synced records).
drop function if exists public.sync_health_measurements(jsonb);
drop table if exists public.health_measurements;
drop function if exists private.touch_server_updated_at();
drop type if exists public.health_metric;
