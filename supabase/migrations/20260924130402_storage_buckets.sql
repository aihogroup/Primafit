-- =============================================================================
-- Sprint 1 · Private storage buckets
-- -----------------------------------------------------------------------------
-- avatars            profile photos (owner read/write; superadmin read)
-- verification-docs  STR / SIP / license / NIB scans (owner upload + read,
--                    superadmin read). Documents are immutable: re-upload with
--                    a new name instead of overwriting.
-- Path convention    <bucket>/<auth.uid()>/<file>, ownership comes from the
--                    first folder segment. Files are served via signed URLs.
-- One policy per command covers both buckets, to avoid overlapping permissive
-- policies on storage.objects.
-- Rollback           supabase/rollbacks/20260924130402_storage_buckets.down.sql
-- =============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', false, 2 * 1024 * 1024,
   array['image/jpeg', 'image/png', 'image/webp']),
  ('verification-docs', 'verification-docs', false, 5 * 1024 * 1024,
   array['application/pdf', 'image/jpeg', 'image/png']);

create policy "primafit: read own files or superadmin" on storage.objects
  for select to authenticated
  using (
    bucket_id in ('avatars', 'verification-docs')
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or (select private.is_superadmin())
    )
  );

create policy "primafit: upload to own folder" on storage.objects
  for insert to authenticated
  with check (
    bucket_id in ('avatars', 'verification-docs')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "primafit: replace own avatar" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "primafit: delete own files" on storage.objects
  for delete to authenticated
  using (
    bucket_id in ('avatars', 'verification-docs')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
