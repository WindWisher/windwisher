create or replace function public.is_manager_of_vip(target_vip_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    auth.uid() is not null
    and (
      public.has_role_at_least('super_admin')
      or exists (
        select 1
        from public.manager_vip_accounts mva
        where mva.manager_user_id = auth.uid()
          and mva.vip_user_id = target_vip_user_id
      )
    )
$$;

create or replace function public.get_my_managed_vips()
returns table (
  vip_user_id uuid,
  vip_handle text,
  vip_display_name text,
  assigned_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    mva.vip_user_id,
    p.handle as vip_handle,
    p.display_name as vip_display_name,
    mva.created_at as assigned_at
  from public.manager_vip_accounts mva
  join public.profiles p
    on p.id = mva.vip_user_id
  where
    mva.manager_user_id = auth.uid()
    or public.has_role_at_least('super_admin')
  order by mva.created_at desc
$$;

grant execute on function public.is_manager_of_vip(uuid) to authenticated;
grant execute on function public.get_my_managed_vips() to authenticated;
