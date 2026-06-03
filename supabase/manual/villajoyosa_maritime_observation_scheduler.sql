-- Refresca la boya fija de Villajoyosa sin depender del boton de la app.
-- Requiere tener pg_cron, pg_net y vault disponibles en Supabase.
-- Guarda el service role key como JWT porque copernicus-marine-nearby tiene verify_jwt=true.

select vault.create_secret(
  'https://tefbkhwaxlsfxvnleutb.supabase.co',
  'windwisher_project_url'
)
where not exists (
  select 1 from vault.decrypted_secrets where name = 'windwisher_project_url'
);

select vault.create_secret(
  'REPLACE_WITH_SUPABASE_SERVICE_ROLE_KEY',
  'windwisher_service_role_key'
)
where not exists (
  select 1
  from vault.decrypted_secrets
  where name = 'windwisher_service_role_key'
);

do $$
begin
  if exists (
    select 1
    from cron.job
    where jobname = 'villajoyosa-maritime-observation-every-30-min'
  ) then
    perform cron.unschedule('villajoyosa-maritime-observation-every-30-min');
  end if;
  if exists (
    select 1
    from cron.job
    where jobname = 'villajoyosa-maritime-observation-every-10-min'
  ) then
    perform cron.unschedule('villajoyosa-maritime-observation-every-10-min');
  end if;
  if exists (
    select 1
    from cron.job
    where jobname = 'villajoyosa-maritime-observation-every-3-hours'
  ) then
    perform cron.unschedule('villajoyosa-maritime-observation-every-3-hours');
  end if;
  if exists (
    select 1
    from cron.job
    where jobname = 'villajoyosa-maritime-observation-every-30-min'
  ) then
    perform cron.unschedule('villajoyosa-maritime-observation-every-30-min');
  end if;
end $$;

select
  cron.schedule(
    'villajoyosa-maritime-observation-every-30-min',
    '*/30 * * * *',
    $$
    select
      net.http_post(
        url := (
          select decrypted_secret
          from vault.decrypted_secrets
          where name = 'windwisher_project_url'
        ) || '/functions/v1/copernicus-marine-nearby',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || (
            select decrypted_secret
            from vault.decrypted_secrets
            where name = 'windwisher_service_role_key'
          )
        ),
        body := jsonb_build_object(
          'spotKey', 'villajoyosa-espigon',
          'spotName', 'Villajoyosa - Espigon',
          'latitude', 38.50250939174642,
          'longitude', -0.23176962068917067,
          'radiusKm', 10,
          'maxResults', 10,
          'offset', 0,
          'forceRefresh', true
        )
      );
    $$
  );
