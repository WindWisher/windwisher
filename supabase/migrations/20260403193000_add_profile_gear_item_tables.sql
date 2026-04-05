create table if not exists public.user_kites (
  id text primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  brand text not null default '',
  model text not null default '',
  size_meters text not null default '',
  year text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_bars (
  id text primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  brand text not null default '',
  model text not null default '',
  line_length_meters text not null default '',
  width_cm text not null default '',
  year text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_boards (
  id text primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  brand text not null default '',
  model text not null default '',
  type text not null default '',
  size_cm text not null default '',
  year text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_harnesses (
  id text primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  brand text not null default '',
  model text not null default '',
  size text not null default '',
  year text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_wetsuits (
  id text primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  brand text not null default '',
  model text not null default '',
  thickness text not null default '',
  size text not null default '',
  year text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_helmets (
  id text primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  brand text not null default '',
  model text not null default '',
  year text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_vests (
  id text primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  brand text not null default '',
  model text not null default '',
  size text not null default '',
  year text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists user_kites_user_id_idx on public.user_kites (user_id);
create index if not exists user_bars_user_id_idx on public.user_bars (user_id);
create index if not exists user_boards_user_id_idx on public.user_boards (user_id);
create index if not exists user_harnesses_user_id_idx on public.user_harnesses (user_id);
create index if not exists user_wetsuits_user_id_idx on public.user_wetsuits (user_id);
create index if not exists user_helmets_user_id_idx on public.user_helmets (user_id);
create index if not exists user_vests_user_id_idx on public.user_vests (user_id);

drop trigger if exists set_user_kites_updated_at on public.user_kites;
create trigger set_user_kites_updated_at
  before update on public.user_kites
  for each row execute procedure public.set_updated_at();

drop trigger if exists set_user_bars_updated_at on public.user_bars;
create trigger set_user_bars_updated_at
  before update on public.user_bars
  for each row execute procedure public.set_updated_at();

drop trigger if exists set_user_boards_updated_at on public.user_boards;
create trigger set_user_boards_updated_at
  before update on public.user_boards
  for each row execute procedure public.set_updated_at();

drop trigger if exists set_user_harnesses_updated_at on public.user_harnesses;
create trigger set_user_harnesses_updated_at
  before update on public.user_harnesses
  for each row execute procedure public.set_updated_at();

drop trigger if exists set_user_wetsuits_updated_at on public.user_wetsuits;
create trigger set_user_wetsuits_updated_at
  before update on public.user_wetsuits
  for each row execute procedure public.set_updated_at();

drop trigger if exists set_user_helmets_updated_at on public.user_helmets;
create trigger set_user_helmets_updated_at
  before update on public.user_helmets
  for each row execute procedure public.set_updated_at();

drop trigger if exists set_user_vests_updated_at on public.user_vests;
create trigger set_user_vests_updated_at
  before update on public.user_vests
  for each row execute procedure public.set_updated_at();

alter table public.user_kites enable row level security;
alter table public.user_bars enable row level security;
alter table public.user_boards enable row level security;
alter table public.user_harnesses enable row level security;
alter table public.user_wetsuits enable row level security;
alter table public.user_helmets enable row level security;
alter table public.user_vests enable row level security;

drop policy if exists "user kites owner full access" on public.user_kites;
create policy "user kites owner full access"
on public.user_kites
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "user bars owner full access" on public.user_bars;
create policy "user bars owner full access"
on public.user_bars
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "user boards owner full access" on public.user_boards;
create policy "user boards owner full access"
on public.user_boards
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "user harnesses owner full access" on public.user_harnesses;
create policy "user harnesses owner full access"
on public.user_harnesses
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "user wetsuits owner full access" on public.user_wetsuits;
create policy "user wetsuits owner full access"
on public.user_wetsuits
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "user helmets owner full access" on public.user_helmets;
create policy "user helmets owner full access"
on public.user_helmets
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "user vests owner full access" on public.user_vests;
create policy "user vests owner full access"
on public.user_vests
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
