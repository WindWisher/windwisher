create table if not exists public.spot_alarm_runtime (
  alarm_id text primary key references public.spot_alarms (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  trigger_count integer not null default 0,
  last_triggered_at timestamptz,
  snoozed_until timestamptz,
  stopped_until_reset boolean not null default false,
  last_delivery_status text,
  last_delivery_reason text,
  last_evaluated_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists spot_alarm_runtime_user_updated_idx
  on public.spot_alarm_runtime (user_id, updated_at desc);

insert into public.spot_alarm_runtime (
  alarm_id,
  user_id,
  trigger_count,
  last_triggered_at,
  updated_at
)
select
  id,
  user_id,
  trigger_count,
  last_triggered_at,
  updated_at
from public.spot_alarms
on conflict (alarm_id) do update
set
  user_id = excluded.user_id,
  trigger_count = excluded.trigger_count,
  last_triggered_at = excluded.last_triggered_at,
  updated_at = excluded.updated_at;

alter table public.spot_alarm_runtime enable row level security;

revoke all on public.spot_alarm_runtime from anon, authenticated;
grant select on public.spot_alarm_runtime to authenticated;

drop policy if exists "spot_alarm_runtime own read" on public.spot_alarm_runtime;
create policy "spot_alarm_runtime own read"
  on public.spot_alarm_runtime
  for select
  to authenticated
  using (auth.uid() = user_id);

drop function if exists public.get_backend_spot_alarm_runner_alarms();

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
    and coalesce(s.enabled, true);
$$;

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

  if reset_trigger_state then
    insert into public.spot_alarm_runtime (
      alarm_id,
      user_id,
      trigger_count,
      last_triggered_at,
      snoozed_until,
      stopped_until_reset,
      updated_at
    ) values (
      target_alarm_id,
      target_user_id,
      0,
      null,
      null,
      false,
      timezone('utc', now())
    )
    on conflict (alarm_id) do update
    set
      user_id = excluded.user_id,
      trigger_count = 0,
      last_triggered_at = null,
      snoozed_until = null,
      stopped_until_reset = false,
      updated_at = timezone('utc', now());

    update public.spot_alarms
    set
      trigger_count = 0,
      last_triggered_at = null,
      updated_at = timezone('utc', now())
    where id = target_alarm_id;
    return;
  end if;

  insert into public.spot_alarm_runtime (
    alarm_id,
    user_id,
    trigger_count,
    last_triggered_at,
    updated_at
  ) values (
    target_alarm_id,
    target_user_id,
    coalesce(next_trigger_count, 0),
    next_last_triggered_at,
    timezone('utc', now())
  )
  on conflict (alarm_id) do update
  set
    user_id = excluded.user_id,
    trigger_count = coalesce(next_trigger_count, public.spot_alarm_runtime.trigger_count),
    last_triggered_at = coalesce(next_last_triggered_at, public.spot_alarm_runtime.last_triggered_at),
    snoozed_until = null,
    stopped_until_reset = false,
    updated_at = timezone('utc', now());

  update public.spot_alarms
  set
    trigger_count = coalesce(next_trigger_count, trigger_count),
    last_triggered_at = coalesce(next_last_triggered_at, last_triggered_at),
    updated_at = timezone('utc', now())
  where id = target_alarm_id;
end;
$$;

create or replace function public.set_backend_spot_alarm_runtime_controls(
  target_alarm_id text,
  next_snoozed_until timestamptz default null,
  next_stopped_until_reset boolean default null,
  next_last_delivery_status text default null,
  next_last_delivery_reason text default null
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

  insert into public.spot_alarm_runtime (
    alarm_id,
    user_id,
    snoozed_until,
    stopped_until_reset,
    last_delivery_status,
    last_delivery_reason,
    updated_at
  ) values (
    target_alarm_id,
    target_user_id,
    next_snoozed_until,
    coalesce(next_stopped_until_reset, false),
    next_last_delivery_status,
    next_last_delivery_reason,
    timezone('utc', now())
  )
  on conflict (alarm_id) do update
  set
    user_id = excluded.user_id,
    snoozed_until = next_snoozed_until,
    stopped_until_reset = coalesce(
      next_stopped_until_reset,
      public.spot_alarm_runtime.stopped_until_reset
    ),
    last_delivery_status = coalesce(
      next_last_delivery_status,
      public.spot_alarm_runtime.last_delivery_status
    ),
    last_delivery_reason = coalesce(
      next_last_delivery_reason,
      public.spot_alarm_runtime.last_delivery_reason
    ),
    updated_at = timezone('utc', now());
end;
$$;

grant execute on function public.get_backend_spot_alarm_runner_alarms() to anon, authenticated;
grant execute on function public.update_backend_spot_alarm_trigger_state(text, integer, timestamptz, boolean) to anon, authenticated;
grant execute on function public.set_backend_spot_alarm_runtime_controls(text, timestamptz, boolean, text, text) to anon, authenticated;
