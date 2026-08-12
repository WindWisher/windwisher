create table if not exists public.user_unit_preferences (
  user_id uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  wind_speed_unit text not null default 'knots'
    check (wind_speed_unit in ('knots', 'kilometersPerHour', 'milesPerHour', 'beaufort')),
  distance_unit text not null default 'kilometers'
    check (distance_unit in ('kilometers', 'miles', 'nauticalMiles')),
  temperature_unit text not null default 'celsius'
    check (temperature_unit in ('celsius', 'fahrenheit')),
  height_unit text not null default 'meters'
    check (height_unit in ('meters', 'feet')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.user_unit_preferences enable row level security;

revoke all on public.user_unit_preferences from anon, authenticated;
grant select, insert, update, delete on public.user_unit_preferences to authenticated;

drop policy if exists "user_unit_preferences own row"
  on public.user_unit_preferences;
create policy "user_unit_preferences own row"
  on public.user_unit_preferences
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop trigger if exists set_user_unit_preferences_updated_at
  on public.user_unit_preferences;
create trigger set_user_unit_preferences_updated_at
  before update on public.user_unit_preferences
  for each row execute procedure public.set_updated_at();
