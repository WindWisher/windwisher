do $$
begin
  if not exists (
    select 1
    from pg_type
    where typname = 'app_role'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.app_role as enum ('user', 'moderator', 'admin');
  end if;
end
$$;

create table if not exists public.user_roles (
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.app_role not null,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, role)
);

create index if not exists user_roles_role_idx
on public.user_roles (role, created_at desc);

create or replace function public.role_level(target_role public.app_role)
returns integer
language sql
immutable
as $$
  select case target_role
    when 'user' then 10
    when 'moderator' then 50
    when 'admin' then 100
  end
$$;

create or replace function public.has_role_at_least(required_role public.app_role)
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
      and public.role_level(ur.role) >= public.role_level(required_role)
  )
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

  if not public.has_role_at_least('admin') then
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

  if not public.has_role_at_least('admin') then
    raise exception 'forbidden';
  end if;

  delete from public.user_roles
  where user_id = target_user_id
    and role = target_role;
end;
$$;

alter table public.user_roles enable row level security;

create policy "user roles self read or admin read"
on public.user_roles
for select
using (
  auth.uid() = user_id
  or public.has_role_at_least('admin')
);

create policy "user roles admin manage"
on public.user_roles
for all
using (public.has_role_at_least('admin'))
with check (public.has_role_at_least('admin'));

grant execute on function public.has_role_at_least(public.app_role) to authenticated;
grant execute on function public.assign_user_role(uuid, public.app_role) to authenticated;
grant execute on function public.revoke_user_role(uuid, public.app_role) to authenticated;
