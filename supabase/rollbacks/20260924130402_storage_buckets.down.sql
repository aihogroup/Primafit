-- Rollback for 20260924130402_storage_buckets.sql (run manually; deletes files' metadata).
drop policy if exists "primafit: read own files or superadmin" on storage.objects;
drop policy if exists "primafit: upload to own folder" on storage.objects;
drop policy if exists "primafit: replace own avatar" on storage.objects;
drop policy if exists "primafit: delete own files" on storage.objects;
-- Buckets must be emptied (via Storage API/dashboard) before they can be deleted.
delete from storage.buckets where id in ('avatars', 'verification-docs');
