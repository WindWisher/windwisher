-- Recommended setup based on Supabase docs:
-- store secrets in Vault, then schedule the HTTP call with pg_cron + pg_net.

select vault.create_secret(
  'https://tefbkhwaxlsfxvnleutb.supabase.co',
  'account_deletion_runner_project_url'
);

select vault.create_secret(
  'REPLACE_WITH_ACCOUNT_DELETION_RUNNER_SECRET',
  'account_deletion_runner_secret'
);

select cron.unschedule('account-deletion-runner-every-15-min');

select
  cron.schedule(
    'account-deletion-runner-every-15-min',
    '*/15 * * * *',
    $$
    select
      net.http_post(
        url := (
          select decrypted_secret
          from vault.decrypted_secrets
          where name = 'account_deletion_runner_project_url'
        ) || '/functions/v1/account-deletion-runner',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || (
            select decrypted_secret
            from vault.decrypted_secrets
            where name = 'account_deletion_runner_secret'
          )
        ),
        body := '{}'::jsonb
      );
    $$
  );
