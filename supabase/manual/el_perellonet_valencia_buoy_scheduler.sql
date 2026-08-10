-- Refresca la boya de Valencia para El Perellonet sin depender del boton de la app.
-- Requiere tener pg_cron, pg_net y vault disponibles en Supabase.
-- Guarda el service role key como JWT porque copernicus-marine-nearby tiene verify_jwt=true.

select vault.create_secret(
  'https://uayzvkjqiiupbeevxrtc.supabase.co',
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
    where jobname = 'el-perellonet-valencia-buoy-every-30-min'
  ) then
    perform cron.unschedule('el-perellonet-valencia-buoy-every-30-min');
  end if;
  if exists (
    select 1
    from cron.job
    where jobname = 'el-perellonet-valencia-buoy-hourly'
  ) then
    perform cron.unschedule('el-perellonet-valencia-buoy-hourly');
  end if;
end $$;

select
  cron.schedule(
    'el-perellonet-valencia-buoy-hourly',
    '8 * * * *',
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
          'spotKey', 'el-perellonet',
          'spotName', 'El Perellonet',
          'latitude', 39.28220282720261,
          'longitude', -0.2768460668785311,
          'radiusKm', 50,
          'maxResults', 10,
          'offset', 0,
          'forceRefresh', true
        )
      );
    $$
  );
