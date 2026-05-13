create table if not exists public.spot_live_observations (
  id bigserial primary key,
  station_provider text not null,
  station_key text not null,
  station_id text,
  station_name text not null,
  observed_at timestamptz not null,
  source_fetched_at timestamptz not null default timezone('utc', now()),
  wind_knots double precision,
  wind_min_knots double precision,
  gust_knots double precision,
  wind_direction_deg integer,
  temp_c double precision,
  pressure_hpa integer,
  humidity_pct integer,
  rain_mm double precision,
  raw_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  constraint spot_live_observations_station_observed_unique
    unique (station_key, observed_at)
);

create index if not exists spot_live_observations_station_observed_idx
  on public.spot_live_observations (station_key, observed_at desc);

create index if not exists spot_live_observations_observed_idx
  on public.spot_live_observations (observed_at desc);

alter table public.spot_live_observations enable row level security;

grant select on public.spot_live_observations to anon, authenticated;

drop policy if exists "spot live observations public read" on public.spot_live_observations;
create policy "spot live observations public read"
  on public.spot_live_observations
  for select
  to anon, authenticated
  using (true);

create or replace function public.prune_spot_live_observations(
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
  delete from public.spot_live_observations
  where observed_at < timezone('utc', now()) - retention;

  get diagnostics deleted_count = row_count;
  return deleted_count;
end;
$$;

revoke all on function public.prune_spot_live_observations(interval)
  from public, anon, authenticated;
