create unique index if not exists user_roles_single_super_admin_idx
on public.user_roles (role)
where role = 'super_admin';

create table if not exists public.admin_action_audit (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid not null references public.profiles(id) on delete cascade,
  actor_role public.app_role not null,
  action_name text not null,
  target_user_id uuid references public.profiles(id) on delete set null,
  target_resource text not null default '',
  target_resource_id text not null default '',
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists admin_action_audit_actor_created_idx
on public.admin_action_audit (actor_user_id, created_at desc);

create index if not exists admin_action_audit_created_idx
on public.admin_action_audit (created_at desc);

create or replace function public.current_highest_role()
returns public.app_role
language sql
stable
security definer
set search_path = public
as $$
  select ur.role
  from public.user_roles ur
  where ur.user_id = auth.uid()
  order by public.role_level(ur.role) desc
  limit 1
$$;

create or replace function public.log_admin_action(
  action_name text,
  target_user_id uuid default null,
  target_resource text default '',
  target_resource_id text default '',
  details jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  actor_role public.app_role;
  inserted_id uuid;
begin
  if current_user_id is null then
    raise exception 'not-authenticated';
  end if;

  if not public.has_role_at_least('admin') then
    raise exception 'forbidden';
  end if;

  actor_role := public.current_highest_role();

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
    coalesce(actor_role, 'user'),
    trim(action_name),
    target_user_id,
    coalesce(target_resource, ''),
    coalesce(target_resource_id, ''),
    coalesce(details, '{}'::jsonb)
  )
  returning id into inserted_id;

  return inserted_id;
end;
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
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'not-authenticated';
  end if;

  if not public.has_role_at_least('super_admin') then
    raise exception 'forbidden';
  end if;

  if target_role = 'super_admin'
     and exists (
       select 1
       from public.user_roles ur
       where ur.role = 'super_admin'
         and ur.user_id <> target_user_id
     ) then
    raise exception 'super-admin-already-assigned';
  end if;

  insert into public.user_roles (user_id, role)
  values (target_user_id, target_role)
  on conflict do nothing;

  perform public.log_admin_action(
    action_name := 'assign_user_role',
    target_user_id := target_user_id,
    target_resource := 'user_roles',
    target_resource_id := target_user_id::text,
    details := jsonb_build_object('assigned_role', target_role::text)
  );
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
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'not-authenticated';
  end if;

  if not public.has_role_at_least('super_admin') then
    raise exception 'forbidden';
  end if;

  if target_role = 'super_admin' then
    raise exception 'cannot-revoke-super-admin-via-self-service';
  end if;

  delete from public.user_roles
  where user_id = target_user_id
    and role = target_role;

  perform public.log_admin_action(
    action_name := 'revoke_user_role',
    target_user_id := target_user_id,
    target_resource := 'user_roles',
    target_resource_id := target_user_id::text,
    details := jsonb_build_object('revoked_role', target_role::text)
  );
end;
$$;

alter table public.admin_action_audit enable row level security;

create policy "admin action audit insert by admins"
on public.admin_action_audit
for insert
with check (
  auth.uid() = actor_user_id
  and public.has_role_at_least('admin')
);

create policy "admin action audit visible to super admin"
on public.admin_action_audit
for select
using (public.has_role_at_least('super_admin'));

grant execute on function public.current_highest_role() to authenticated;
grant execute on function public.log_admin_action(text, uuid, text, text, jsonb) to authenticated;
