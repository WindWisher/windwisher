create table if not exists public.spot_alarms (
  id text primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  spot_key text not null,
  spot_name text not null,
  spot_area text not null,
  station_key text not null,
  station_name text not null,
  wind_range_start double precision not null,
  wind_range_end double precision not null,
  start_hour integer not null,
  end_hour integer not null,
  directions text[] not null default '{}',
  repeat_window text not null,
  max_repeats integer not null default 3,
  trigger_count integer not null default 0,
  last_triggered_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists spot_alarms_user_spot_idx
  on public.spot_alarms (user_id, spot_key, created_at desc);

create table if not exists public.spot_alarm_preferences (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  scope_key text not null,
  enabled boolean not null default true,
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, scope_key)
);

alter table public.spot_alarms enable row level security;
alter table public.spot_alarm_preferences enable row level security;

revoke all on public.spot_alarms from anon, authenticated;
revoke all on public.spot_alarm_preferences from anon, authenticated;

grant select, insert, update, delete on public.spot_alarms to authenticated;
grant select, insert, update, delete on public.spot_alarm_preferences to authenticated;

drop policy if exists "spot_alarms own rows" on public.spot_alarms;
create policy "spot_alarms own rows"
  on public.spot_alarms
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "spot_alarm_preferences own rows" on public.spot_alarm_preferences;
create policy "spot_alarm_preferences own rows"
  on public.spot_alarm_preferences
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
