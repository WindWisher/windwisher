select cron.unschedule('spot-alarm-runner-every-5-min');

select
  cron.schedule(
    'spot-alarm-runner-every-5-min',
    '*/5 * * * *',
    $$
    select
      net.http_post(
        url := 'https://tefbkhwaxlsfxvnleutb.supabase.co/functions/v1/spot-alarm-runner',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer REPLACE_WITH_SPOT_ALARM_RUNNER_SECRET'
        ),
        body := '{}'::jsonb
      );
    $$
  );
