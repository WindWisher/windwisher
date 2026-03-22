create or replace function public.role_level(target_role public.app_role)
returns integer
language sql
immutable
as $$
  select case target_role
    when 'user' then 10
    when 'moderator' then 50
    when 'admin' then 100
    when 'super_admin' then 1000
  end
$$;

create or replace function public.assign_user_role(
  target_user_id uuid,
  target_role public.app_role
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not-authenticated';
  end if;

  if not public.has_role_at_least('super_admin') then
    raise exception 'forbidden';
  end if;

  insert into public.user_roles (user_id, role)
  values (target_user_id, target_role)
  on conflict do nothing;
end;
$$;

create or replace function public.revoke_user_role(
  target_user_id uuid,
  target_role public.app_role
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not-authenticated';
  end if;

  if not public.has_role_at_least('super_admin') then
    raise exception 'forbidden';
  end if;

  delete from public.user_roles
  where user_id = target_user_id
    and role = target_role;
end;
$$;

drop policy if exists "user roles self read or admin read" on public.user_roles;
drop policy if exists "user roles self read or super admin read" on public.user_roles;
create policy "user roles self read or super admin read"
on public.user_roles
for select
using (
  auth.uid() = user_id
  or public.has_role_at_least('super_admin')
);

drop policy if exists "user roles admin manage" on public.user_roles;
drop policy if exists "user roles super admin manage" on public.user_roles;
create policy "user roles super admin manage"
on public.user_roles
for all
using (public.has_role_at_least('super_admin'))
with check (public.has_role_at_least('super_admin'));
