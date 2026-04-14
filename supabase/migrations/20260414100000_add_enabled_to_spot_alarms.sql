alter table public.spot_alarms
  add column if not exists enabled boolean not null default true;

create or replace function public.get_backend_spot_alarm_runner_alarms()
returns table (
  id text,
  user_id uuid,
  spot_key text,
  spot_name text,
  spot_area text,
  station_provider text,
  station_key text,
  station_name text,
  wind_range_start double precision,
  wind_range_end double precision,
  start_hour integer,
  end_hour integer,
  start_minute integer,
  end_minute integer,
  directions text[],
  repeat_window text,
  max_repeats integer,
  trigger_count integer,
  last_triggered_at timestamptz,
  snoozed_until timestamptz,
  stopped_until_reset boolean
)
language sql
security definer
set search_path = public
as $$
  select
    a.id,
    a.user_id,
    a.spot_key,
    a.spot_name,
    a.spot_area,
    a.station_provider,
    a.station_key,
    a.station_name,
    a.wind_range_start,
    a.wind_range_end,
    a.start_hour,
    a.end_hour,
    coalesce(a.start_minute, 0) as start_minute,
    coalesce(a.end_minute, 0) as end_minute,
    a.directions,
    a.repeat_window,
    a.max_repeats,
    coalesce(r.trigger_count, a.trigger_count) as trigger_count,
    coalesce(r.last_triggered_at, a.last_triggered_at) as last_triggered_at,
    r.snoozed_until,
    coalesce(r.stopped_until_reset, false) as stopped_until_reset
  from public.spot_alarms a
  left join public.spot_alarm_runtime r
    on r.alarm_id = a.id
  left join public.spot_alarm_preferences g
    on g.user_id = a.user_id
   and g.scope_key = '__global__'
  left join public.spot_alarm_preferences s
    on s.user_id = a.user_id
   and s.scope_key = a.spot_key
  where coalesce(g.enabled, true)
    and coalesce(s.enabled, true)
    and coalesce(a.enabled, true);
$$;

grant execute on function public.get_backend_spot_alarm_runner_alarms() to anon, authenticated;
