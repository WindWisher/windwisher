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
  directions text[],
  repeat_window text,
  max_repeats integer,
  trigger_count integer,
  last_triggered_at timestamptz
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
    a.directions,
    a.repeat_window,
    a.max_repeats,
    a.trigger_count,
    a.last_triggered_at
  from public.spot_alarms a
  left join public.spot_alarm_preferences g
    on g.user_id = a.user_id
   and g.scope_key = '__global__'
  left join public.spot_alarm_preferences s
    on s.user_id = a.user_id
   and s.scope_key = a.spot_key
  where coalesce(g.enabled, true)
    and coalesce(s.enabled, true);
$$;

create or replace function public.get_backend_push_subscriptions()
returns table (
  user_id uuid,
  device_token text,
  platform text,
  provider text,
  enabled boolean
)
language sql
security definer
set search_path = public
as $$
  select
    user_id,
    device_token,
    platform,
    provider,
    enabled
  from public.user_push_subscriptions
  where enabled = true;
$$;

create or replace function public.log_backend_spot_alarm_delivery(
  target_alarm_id text,
  target_station_provider text,
  target_station_key text,
  delivery_status text,
  delivery_reason text default null,
  delivery_payload jsonb default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  target_user_id uuid;
begin
  select user_id
  into target_user_id
  from public.spot_alarms
  where id = target_alarm_id;

  if target_user_id is null then
    raise exception 'missing-alarm-user';
  end if;

  insert into public.spot_alarm_delivery_log (
    alarm_id,
    user_id,
    station_provider,
    station_key,
    status,
    reason,
    payload
  ) values (
    target_alarm_id,
    target_user_id,
    target_station_provider,
    target_station_key,
    delivery_status,
    delivery_reason,
    delivery_payload
  );
end;
$$;

grant execute on function public.get_backend_spot_alarm_runner_alarms() to anon, authenticated;
grant execute on function public.get_backend_push_subscriptions() to anon, authenticated;
grant execute on function public.log_backend_spot_alarm_delivery(text, text, text, text, text, jsonb) to anon, authenticated;

create or replace function public.update_backend_spot_alarm_trigger_state(
  target_alarm_id text,
  next_trigger_count integer default null,
  next_last_triggered_at timestamptz default null,
  reset_trigger_state boolean default false
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if reset_trigger_state then
    update public.spot_alarms
    set
      trigger_count = 0,
      last_triggered_at = null,
      updated_at = timezone('utc', now())
    where id = target_alarm_id;
    return;
  end if;

  update public.spot_alarms
  set
    trigger_count = coalesce(next_trigger_count, trigger_count),
    last_triggered_at = coalesce(next_last_triggered_at, last_triggered_at),
    updated_at = timezone('utc', now())
  where id = target_alarm_id;
end;
$$;

grant execute on function public.update_backend_spot_alarm_trigger_state(text, integer, timestamptz, boolean) to anon, authenticated;
