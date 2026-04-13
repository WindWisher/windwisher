insert into storage.buckets (id, name, public)
values ('direct-chat-media', 'direct-chat-media', true)
on conflict (id) do nothing;

alter table public.direct_messages
  add column if not exists attachment_type text,
  add column if not exists storage_path text,
  add column if not exists public_url text,
  add column if not exists thumbnail_url text,
  add column if not exists file_name text,
  add column if not exists mime_type text,
  add column if not exists size_bytes integer;

update public.direct_messages
set attachment_type = 'text'
where attachment_type is null;

alter table public.direct_messages
  alter column attachment_type set default 'text';

alter table public.direct_messages
  alter column attachment_type set not null;

alter table public.direct_messages
  drop constraint if exists direct_messages_attachment_type_check;

alter table public.direct_messages
  add constraint direct_messages_attachment_type_check
  check (attachment_type in ('text', 'image', 'video'));

alter table public.direct_messages
  drop constraint if exists direct_messages_attachment_presence_check;

alter table public.direct_messages
  add constraint direct_messages_attachment_presence_check
  check (
    (attachment_type = 'text' and storage_path is null and public_url is null)
    or
    (attachment_type in ('image', 'video') and storage_path is not null and public_url is not null)
  );

create unique index if not exists direct_messages_storage_path_idx
  on public.direct_messages (storage_path)
  where storage_path is not null;

drop policy if exists "direct chat media public read" on storage.objects;
create policy "direct chat media public read"
  on storage.objects
  for select
  using (bucket_id = 'direct-chat-media');

drop policy if exists "direct chat media authenticated upload" on storage.objects;
create policy "direct chat media authenticated upload"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'direct-chat-media' and
    (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "direct chat media own delete" on storage.objects;
create policy "direct chat media own delete"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'direct-chat-media' and
    (storage.foldername(name))[1] = auth.uid()::text
  );
