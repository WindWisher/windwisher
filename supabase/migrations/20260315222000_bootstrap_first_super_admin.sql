create or replace function public.bootstrap_first_super_admin()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'not-authenticated';
  end if;

  if exists (
    select 1
    from public.user_roles
    where role = 'super_admin'
  ) then
    raise exception 'super-admin-already-exists';
  end if;

  insert into public.user_roles (user_id, role)
  values (current_user_id, 'super_admin')
  on conflict do nothing;

  insert into public.admin_action_audit (
    actor_user_id,
    actor_role,
    action_name,
    target_user_id,
    target_resource,
    target_resource_id,
    details
  )
  values (
    current_user_id,
    'super_admin',
    'bootstrap_first_super_admin',
    current_user_id,
    'user_roles',
    current_user_id::text,
    jsonb_build_object('assigned_role', 'super_admin')
  );
end;
$$;

grant execute on function public.bootstrap_first_super_admin() to authenticated;
