create or replace function public.get_admin_action_audit(
  limit_count integer default 100,
  offset_count integer default 0
)
returns table (
  id uuid,
  actor_user_id uuid,
  actor_handle text,
  actor_role public.app_role,
  action_name text,
  target_user_id uuid,
  target_handle text,
  target_resource text,
  target_resource_id text,
  details jsonb,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    a.id,
    a.actor_user_id,
    coalesce(actor_profile.handle, '') as actor_handle,
    a.actor_role,
    a.action_name,
    a.target_user_id,
    coalesce(target_profile.handle, '') as target_handle,
    a.target_resource,
    a.target_resource_id,
    a.details,
    a.created_at
  from public.admin_action_audit a
  left join public.profiles actor_profile
    on actor_profile.id = a.actor_user_id
  left join public.profiles target_profile
    on target_profile.id = a.target_user_id
  where public.has_role_at_least('super_admin')
  order by a.created_at desc
  limit greatest(coalesce(limit_count, 100), 1)
  offset greatest(coalesce(offset_count, 0), 0)
$$;

create or replace function public.get_role_directory()
returns table (
  user_id uuid,
  handle text,
  display_name text,
  role public.app_role,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    ur.user_id,
    p.handle,
    p.display_name,
    ur.role,
    ur.created_at
  from public.user_roles ur
  join public.profiles p
    on p.id = ur.user_id
  where public.has_role_at_least('super_admin')
  order by public.role_level(ur.role) desc, ur.created_at asc
$$;

grant execute on function public.get_admin_action_audit(integer, integer) to authenticated;
grant execute on function public.get_role_directory() to authenticated;
