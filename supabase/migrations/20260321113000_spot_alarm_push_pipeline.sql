alter table public.spot_alarms
  add column if not exists station_provider text not null default '';

create table if not exists public.user_push_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  platform text not null,
  provider text not null default 'fcm',
  device_token text not null,
  enabled boolean not null default true,
  device_label text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint user_push_subscriptions_user_token_unique unique (user_id, device_token)
);

create index if not exists user_push_subscriptions_user_enabled_idx
  on public.user_push_subscriptions (user_id, enabled, updated_at desc);

create table if not exists public.spot_alarm_delivery_log (
  id uuid primary key default gen_random_uuid(),
  alarm_id text not null references public.spot_alarms (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  station_provider text not null,
  station_key text not null,
  status text not null,
  reason text,
  triggered_at timestamptz not null default timezone('utc', now()),
  payload jsonb
);

create index if not exists spot_alarm_delivery_log_alarm_triggered_idx
  on public.spot_alarm_delivery_log (alarm_id, triggered_at desc);

alter table public.user_push_subscriptions enable row level security;
alter table public.spot_alarm_delivery_log enable row level security;

revoke all on public.user_push_subscriptions from anon, authenticated;
revoke all on public.spot_alarm_delivery_log from anon, authenticated;

grant select, insert, update, delete on public.user_push_subscriptions to authenticated;
grant select on public.spot_alarm_delivery_log to authenticated;

drop policy if exists "user_push_subscriptions own rows" on public.user_push_subscriptions;
create policy "user_push_subscriptions own rows"
  on public.user_push_subscriptions
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "spot_alarm_delivery_log own read" on public.spot_alarm_delivery_log;
create policy "spot_alarm_delivery_log own read"
  on public.spot_alarm_delivery_log
  for select
  to authenticated
  using (auth.uid() = user_id);
