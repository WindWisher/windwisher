do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'windwisher_aemet_oliva'
  ) then
    execute 'drop policy if exists "windwisher_aemet_oliva public read" on public.windwisher_aemet_oliva';
  end if;
end
$$;

drop table if exists public.windwisher_aemet_oliva;
