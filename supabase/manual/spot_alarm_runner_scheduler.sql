do $$
begin
  if exists (select 1 from cron.job where jobname = 'spot-alarm-runner-every-5-min') then
    perform cron.unschedule('spot-alarm-runner-every-5-min');
  end if;
  if exists (select 1 from cron.job where jobname = 'spot-alarm-runner-every-1-min') then
    perform cron.unschedule('spot-alarm-runner-every-1-min');
  end if;
end $$;

select
  cron.schedule(
    'spot-alarm-runner-every-1-min',
    '* * * * *',
    $$
    select
      net.http_post(
        url := 'https://uayzvkjqiiupbeevxrtc.supabase.co/functions/v1/spot-alarm-runner',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer REPLACE_WITH_SPOT_ALARM_RUNNER_SECRET'
        ),
        body := '{}'::jsonb
      );
    $$
  );
