-- Úložiště fotek (spec 7.1, 8.1): soukromý bucket photos.
-- Cesty: '<gardenId>/<photoId>.jpg' a '<gardenId>/<photoId>_thumb.jpg'.
-- Přístup podle členství v zahradě z první složky cesty: číst smí každý
-- člen, nahrávat, přepisovat a mazat owner a editor.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 10485760, array['image/jpeg'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy photos_objects_select_member on storage.objects
  for select to authenticated
  using (
    bucket_id = 'photos'
    and private.is_garden_member(private.path_garden_id(name))
  );

create policy photos_objects_insert_editor on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'photos'
    and name ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}(_thumb)?\.jpg$'
    and private.is_garden_member(private.path_garden_id(name), array['owner', 'editor'])
  );

create policy photos_objects_update_editor on storage.objects
  for update to authenticated
  using (
    bucket_id = 'photos'
    and private.is_garden_member(private.path_garden_id(name), array['owner', 'editor'])
  )
  with check (
    bucket_id = 'photos'
    and name ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}(_thumb)?\.jpg$'
    and private.is_garden_member(private.path_garden_id(name), array['owner', 'editor'])
  );

create policy photos_objects_delete_editor on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'photos'
    and private.is_garden_member(private.path_garden_id(name), array['owner', 'editor'])
  );
