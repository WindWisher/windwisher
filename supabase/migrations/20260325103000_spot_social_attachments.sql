insert into storage.buckets (id, name, public)
values ('spot-social-media', 'spot-social-media', true)
on conflict (id) do nothing;

create table if not exists public.spot_social_attachments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.spot_social_posts (id) on delete cascade,
  reply_id uuid references public.spot_social_replies (id) on delete cascade,
  author_user_id uuid references auth.users (id) on delete cascade,
  attachment_type text not null check (attachment_type in ('image', 'video')),
  storage_path text not null unique,
  public_url text not null,
  thumbnail_url text,
  file_name text not null,
  mime_type text,
  size_bytes integer,
  created_at timestamptz not null default timezone('utc', now()),
  constraint spot_social_attachments_target_check
    check (
      (post_id is not null and reply_id is null) or
      (post_id is null and reply_id is not null)
    )
);

create index if not exists spot_social_attachments_post_created_idx
  on public.spot_social_attachments (post_id, created_at asc);

create index if not exists spot_social_attachments_reply_created_idx
  on public.spot_social_attachments (reply_id, created_at asc);

alter table public.spot_social_attachments enable row level security;

revoke all on public.spot_social_attachments from anon, authenticated;
grant select on public.spot_social_attachments to anon, authenticated;
grant insert, delete on public.spot_social_attachments to authenticated;

drop policy if exists "spot_social_attachments public read" on public.spot_social_attachments;
create policy "spot_social_attachments public read"
  on public.spot_social_attachments
  for select
  using (true);

drop policy if exists "spot_social_attachments own insert" on public.spot_social_attachments;
create policy "spot_social_attachments own insert"
  on public.spot_social_attachments
  for insert
  to authenticated
  with check (auth.uid() = author_user_id);

drop policy if exists "spot_social_attachments own delete" on public.spot_social_attachments;
create policy "spot_social_attachments own delete"
  on public.spot_social_attachments
  for delete
  to authenticated
  using (auth.uid() = author_user_id);

drop policy if exists "spot social media public read" on storage.objects;
create policy "spot social media public read"
  on storage.objects
  for select
  using (bucket_id = 'spot-social-media');

drop policy if exists "spot social media authenticated upload" on storage.objects;
create policy "spot social media authenticated upload"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'spot-social-media' and
    (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "spot social media own delete" on storage.objects;
create policy "spot social media own delete"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'spot-social-media' and
    (storage.foldername(name))[1] = auth.uid()::text
  );
