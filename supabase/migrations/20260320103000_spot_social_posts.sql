create table if not exists public.spot_social_posts (
  id uuid primary key default gen_random_uuid(),
  spot_name text not null,
  spot_area text not null,
  spot_key text not null,
  author_user_id uuid references auth.users (id) on delete set null,
  author_username text not null,
  author_display_name text not null,
  message text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists spot_social_posts_spot_key_created_idx
  on public.spot_social_posts (spot_key, created_at desc);

create table if not exists public.spot_social_replies (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.spot_social_posts (id) on delete cascade,
  parent_reply_id uuid references public.spot_social_replies (id) on delete cascade,
  author_user_id uuid references auth.users (id) on delete set null,
  author_username text not null,
  author_display_name text not null,
  message text not null,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists spot_social_replies_post_created_idx
  on public.spot_social_replies (post_id, created_at asc);

alter table public.spot_social_posts enable row level security;
alter table public.spot_social_replies enable row level security;

revoke all on public.spot_social_posts from anon, authenticated;
revoke all on public.spot_social_replies from anon, authenticated;

grant select on public.spot_social_posts to anon, authenticated;
grant select on public.spot_social_replies to anon, authenticated;
grant insert, update, delete on public.spot_social_posts to authenticated;
grant insert on public.spot_social_replies to authenticated;

drop policy if exists "spot_social_posts public read" on public.spot_social_posts;
create policy "spot_social_posts public read"
  on public.spot_social_posts
  for select
  using (true);

drop policy if exists "spot_social_replies public read" on public.spot_social_replies;
create policy "spot_social_replies public read"
  on public.spot_social_replies
  for select
  using (true);

drop policy if exists "spot_social_posts own insert" on public.spot_social_posts;
create policy "spot_social_posts own insert"
  on public.spot_social_posts
  for insert
  to authenticated
  with check (auth.uid() = author_user_id);

drop policy if exists "spot_social_posts own update" on public.spot_social_posts;
create policy "spot_social_posts own update"
  on public.spot_social_posts
  for update
  to authenticated
  using (auth.uid() = author_user_id)
  with check (auth.uid() = author_user_id);

drop policy if exists "spot_social_posts own delete" on public.spot_social_posts;
create policy "spot_social_posts own delete"
  on public.spot_social_posts
  for delete
  to authenticated
  using (auth.uid() = author_user_id);

drop policy if exists "spot_social_replies own insert" on public.spot_social_replies;
create policy "spot_social_replies own insert"
  on public.spot_social_replies
  for insert
  to authenticated
  with check (auth.uid() = author_user_id);
