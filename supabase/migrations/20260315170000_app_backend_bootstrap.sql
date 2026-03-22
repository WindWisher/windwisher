create extension if not exists "pgcrypto";

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text not null default '',
  handle text not null unique,
  public_tagline text not null default '',
  bio text not null default '',
  level text not null default '',
  base_spot text not null default '',
  avatar_path text,
  banner_path text,
  total_sessions integer not null default 0,
  water_hours numeric(10,2) not null default 0,
  jumps integer not null default 0,
  top_jump_m numeric(10,2) not null default 0,
  best_spot text not null default '',
  latest_session_label text not null default '',
  latest_comment_label text not null default '',
  featured_thread_label text not null default '',
  ranking_label text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_gear_setups (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  board text,
  kite text,
  bar text,
  wetsuit text,
  notes text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.spots (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  area text not null,
  latitude double precision,
  longitude double precision,
  aemet_municipality_code text,
  aemet_beach_code text,
  aemet_beach_codes text[] not null default '{}',
  background_image_path text,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create unique index if not exists spots_name_area_key
on public.spots (name, area);

create table if not exists public.user_saved_spots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  spot_id uuid references public.spots(id) on delete set null,
  custom_name text not null,
  area text not null default '',
  is_custom boolean not null default false,
  latitude double precision,
  longitude double precision,
  aemet_municipality_code text,
  aemet_beach_code text,
  aemet_beach_codes text[] not null default '{}',
  background_image_path text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists user_saved_spots_user_id_idx
on public.user_saved_spots (user_id, created_at desc);

create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  summary text not null default '',
  device_name text not null default '',
  ended_at timestamptz not null,
  duration_seconds integer not null default 0,
  gear_setup_id uuid references public.user_gear_setups(id) on delete set null,
  gear_setup_name text,
  session_media_label text not null default '',
  session_photo_path text,
  has_session_photo boolean not null default false,
  spot_id uuid references public.spots(id) on delete set null,
  spot_name text,
  insights jsonb not null default '{}'::jsonb,
  highest_jump_m numeric(10,2) not null default 0,
  distance_km numeric(10,2) not null default 0,
  big_air_score integer not null default 0,
  is_public boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists sessions_user_id_idx
on public.sessions (user_id, ended_at desc);

create index if not exists sessions_public_feed_idx
on public.sessions (is_public, ended_at desc);

create table if not exists public.session_likes (
  session_id uuid not null references public.sessions(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (session_id, user_id)
);

create table if not exists public.session_comments (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  author_username text not null,
  text text not null,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists session_comments_session_id_idx
on public.session_comments (session_id, created_at asc);

create table if not exists public.user_follows (
  follower_user_id uuid not null references public.profiles(id) on delete cascade,
  followed_user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (follower_user_id, followed_user_id),
  constraint user_follows_no_self_follow
    check (follower_user_id <> followed_user_id)
);

create index if not exists user_follows_followed_idx
on public.user_follows (followed_user_id, created_at desc);

create table if not exists public.direct_threads (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references public.profiles(id) on delete cascade,
  title text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.direct_thread_participants (
  thread_id uuid not null references public.direct_threads(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (thread_id, user_id)
);

create table if not exists public.direct_messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.direct_threads(id) on delete cascade,
  sender_user_id uuid not null references public.profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists direct_messages_thread_id_idx
on public.direct_messages (thread_id, created_at asc);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  raw_handle text;
begin
  raw_handle := coalesce(new.raw_user_meta_data ->> 'handle', split_part(coalesce(new.email, ''), '@', 1), 'rider');

  insert into public.profiles (
    id,
    email,
    display_name,
    handle
  )
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'display_name', raw_handle),
    lower(regexp_replace(raw_handle, '[^a-zA-Z0-9_]', '', 'g'))
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace view public.community_leaderboard as
select
  p.id as user_id,
  p.handle as username,
  coalesce(sum(s.big_air_score), 0)::integer as big_air_score,
  coalesce(max(s.highest_jump_m), 0)::numeric(10,2) as highest_jump_meters,
  nullif(p.base_spot, '') as main_spot,
  0 as avatar_color_value
from public.profiles p
left join public.sessions s
  on s.user_id = p.id
 and s.is_public = true
group by p.id, p.handle, p.base_spot;

create or replace view public.community_following_feed as
select
  s.id,
  p.handle as username,
  s.title,
  coalesce(s.spot_name, p.base_spot, '') as spot,
  s.ended_at,
  s.big_air_score,
  s.highest_jump_m,
  s.distance_km,
  s.duration_seconds,
  coalesce(s.gear_setup_name, '') as equipment_label,
  coalesce(l.likes_count, 0)::integer as likes_count,
  s.has_session_photo,
  s.user_id
from public.sessions s
join public.profiles p on p.id = s.user_id
left join (
  select session_id, count(*) as likes_count
  from public.session_likes
  group by session_id
) l on l.session_id = s.id
where s.is_public = true;

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute procedure public.set_updated_at();

create trigger set_user_gear_setups_updated_at
  before update on public.user_gear_setups
  for each row execute procedure public.set_updated_at();

create trigger set_spots_updated_at
  before update on public.spots
  for each row execute procedure public.set_updated_at();

create trigger set_user_saved_spots_updated_at
  before update on public.user_saved_spots
  for each row execute procedure public.set_updated_at();

create trigger set_sessions_updated_at
  before update on public.sessions
  for each row execute procedure public.set_updated_at();

create trigger set_direct_threads_updated_at
  before update on public.direct_threads
  for each row execute procedure public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.user_gear_setups enable row level security;
alter table public.spots enable row level security;
alter table public.user_saved_spots enable row level security;
alter table public.sessions enable row level security;
alter table public.session_likes enable row level security;
alter table public.session_comments enable row level security;
alter table public.user_follows enable row level security;
alter table public.direct_threads enable row level security;
alter table public.direct_thread_participants enable row level security;
alter table public.direct_messages enable row level security;

create policy "profiles are publicly readable"
on public.profiles
for select
using (true);

create policy "profiles insert own row"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "profiles update own row"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "gear setups owner full access"
on public.user_gear_setups
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "spots public read"
on public.spots
for select
using (true);

create policy "saved spots owner full access"
on public.user_saved_spots
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "sessions public read or owner"
on public.sessions
for select
using (is_public or auth.uid() = user_id);

create policy "sessions owner full access"
on public.sessions
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "session likes readable when parent session is public or own"
on public.session_likes
for select
using (
  exists (
    select 1
    from public.sessions s
    where s.id = session_likes.session_id
      and (s.is_public or s.user_id = auth.uid())
  )
);

create policy "session likes owner full access"
on public.session_likes
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "session comments readable when parent session is public or own"
on public.session_comments
for select
using (
  exists (
    select 1
    from public.sessions s
    where s.id = session_comments.session_id
      and (s.is_public or s.user_id = auth.uid())
  )
);

create policy "session comments authenticated insert"
on public.session_comments
for insert
with check (auth.uid() = user_id);

create policy "session comments owner delete"
on public.session_comments
for delete
using (auth.uid() = user_id);

create policy "follows owner full access"
on public.user_follows
for all
using (auth.uid() = follower_user_id)
with check (auth.uid() = follower_user_id);

create policy "threads visible to participants"
on public.direct_threads
for select
using (
  exists (
    select 1
    from public.direct_thread_participants p
    where p.thread_id = direct_threads.id
      and p.user_id = auth.uid()
  )
);

create policy "threads creator insert"
on public.direct_threads
for insert
with check (auth.uid() = created_by);

create policy "thread participants visible to participants"
on public.direct_thread_participants
for select
using (
  exists (
    select 1
    from public.direct_thread_participants p
    where p.thread_id = direct_thread_participants.thread_id
      and p.user_id = auth.uid()
  )
);

create policy "thread participants creator manages"
on public.direct_thread_participants
for all
using (
  exists (
    select 1
    from public.direct_threads t
    where t.id = direct_thread_participants.thread_id
      and t.created_by = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.direct_threads t
    where t.id = direct_thread_participants.thread_id
      and t.created_by = auth.uid()
  )
);

create policy "messages visible to participants"
on public.direct_messages
for select
using (
  exists (
    select 1
    from public.direct_thread_participants p
    where p.thread_id = direct_messages.thread_id
      and p.user_id = auth.uid()
  )
);

create policy "messages participants insert"
on public.direct_messages
for insert
with check (
  auth.uid() = sender_user_id
  and exists (
    select 1
    from public.direct_thread_participants p
    where p.thread_id = direct_messages.thread_id
      and p.user_id = auth.uid()
  )
);

insert into storage.buckets (id, name, public)
values
  ('profile-avatars', 'profile-avatars', true),
  ('profile-banners', 'profile-banners', true),
  ('session-media', 'session-media', true)
on conflict (id) do nothing;
