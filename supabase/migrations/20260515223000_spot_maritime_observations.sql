create table if not exists public.spot_maritime_observations (
  id bigserial primary key,
  spot_key text not null,
  spot_name text not null,
  provider text not null,
  platform_id text not null,
  platform_type text,
  platform_name text,
  station_key text not null,
  latitude double precision not null,
  longitude double precision not null,
  distance_km double precision not null,
  observed_at timestamptz not null,
  source_fetched_at timestamptz not null default timezone('utc', now()),
  source_file text,
  wind_speed_ms double precision,
  wind_speed_knots double precision,
  wind_dir_deg double precision,
  gust_ms double precision,
  gust_knots double precision,
  air_temp_c double precision,
  pressure_hpa double precision,
  humidity_pct double precision,
  sea_surface_temp_c double precision,
  wave_height_m double precision,
  wave_period_s double precision,
  quality text,
  raw_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  constraint spot_maritime_observations_unique
    unique (spot_key, provider, platform_id, observed_at)
);

create index if not exists spot_maritime_observations_spot_observed_idx
  on public.spot_maritime_observations (spot_key, observed_at desc);

create index if not exists spot_maritime_observations_station_observed_idx
  on public.spot_maritime_observations (station_key, observed_at desc);

create index if not exists spot_maritime_observations_source_fetched_idx
  on public.spot_maritime_observations (source_fetched_at desc);

alter table public.spot_maritime_observations enable row level security;

grant select on public.spot_maritime_observations to anon, authenticated;

drop policy if exists "spot maritime observations public read"
  on public.spot_maritime_observations;
create policy "spot maritime observations public read"
  on public.spot_maritime_observations
  for select
  to anon, authenticated
  using (true);

create or replace function public.prune_spot_maritime_observations(
  retention interval default interval '72 hours'
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  deleted_count integer;
begin
  delete from public.spot_maritime_observations
  where observed_at < timezone('utc', now()) - retention;

  get diagnostics deleted_count = row_count;
  return deleted_count;
end;
$$;

revoke all on function public.prune_spot_maritime_observations(interval)
  from public, anon, authenticated;
