create or replace function public.current_user_roles()
returns table (role public.app_role)
language sql
stable
security definer
set search_path = public
as $$
  select ur.role
  from public.user_roles ur
  where ur.user_id = auth.uid()
  order by public.role_level(ur.role) desc, ur.created_at asc;
$$;

grant execute on function public.current_user_roles()
to authenticated;
