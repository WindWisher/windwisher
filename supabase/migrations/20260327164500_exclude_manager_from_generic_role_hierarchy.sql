create or replace function public.has_role_at_least(required_role public.app_role)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select case
    when required_role = 'manager' then
      exists (
        select 1
        from public.user_roles ur
        where ur.user_id = auth.uid()
          and ur.role in ('manager', 'super_admin')
      )
    else
      exists (
        select 1
        from public.user_roles ur
        where ur.user_id = auth.uid()
          and ur.role <> 'manager'
          and public.role_level(ur.role) >= public.role_level(required_role)
      )
  end
$$;

create or replace function public.has_manager_role()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_roles ur
    where ur.user_id = auth.uid()
      and ur.role in ('manager', 'super_admin')
  )
$$;

grant execute on function public.has_manager_role() to authenticated;
