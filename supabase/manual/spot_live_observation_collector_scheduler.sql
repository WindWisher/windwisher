do $$
begin
  if exists (select 1 from cron.job where jobname = 'spot-live-observation-collector-every-5-min') then
    perform cron.unschedule('spot-live-observation-collector-every-5-min');
  end if;
end $$;

select
  cron.schedule(
    'spot-live-observation-collector-every-5-min',
    '*/5 * * * *',
    $$
    select
      net.http_post(
        url := 'https://uayzvkjqiiupbeevxrtc.supabase.co/functions/v1/spot-live-observation-collector',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer REPLACE_WITH_LIVE_WIND_RECORDER_SECRET'
        ),
        body := '{}'::jsonb
      );
    $$
  );
