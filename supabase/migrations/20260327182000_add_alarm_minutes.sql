alter table public.spot_alarms
  add column if not exists start_minute integer not null default 0,
  add column if not exists end_minute integer not null default 0;
