create or replace function public.get_role_management_directory()
returns table (
  user_id uuid,
  handle text,
  display_name text,
  email text,
  roles text[],
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.id as user_id,
    coalesce(p.handle, '') as handle,
    coalesce(p.display_name, '') as display_name,
    coalesce(p.email, '') as email,
    coalesce(
      array_agg(ur.role::text order by public.role_level(ur.role) desc)
        filter (where ur.role is not null),
      '{}'::text[]
    ) as roles,
    p.created_at
  from public.profiles p
  left join public.user_roles ur
    on ur.user_id = p.id
  where public.has_role_at_least('super_admin')
  group by p.id, p.handle, p.display_name, p.email, p.created_at
  order by lower(coalesce(nullif(p.display_name, ''), nullif(p.handle, ''), p.email, p.id::text));
$$;

grant execute on function public.get_role_management_directory()
to authenticated;
