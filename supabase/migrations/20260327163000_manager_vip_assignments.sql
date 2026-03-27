create table if not exists public.manager_vip_accounts (
  manager_user_id uuid not null references public.profiles(id) on delete cascade,
  vip_user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  created_by uuid references public.profiles(id) on delete set null,
  primary key (manager_user_id, vip_user_id),
  constraint manager_vip_accounts_no_self check (manager_user_id <> vip_user_id)
);

create index if not exists manager_vip_accounts_vip_idx
  on public.manager_vip_accounts (vip_user_id, created_at desc);

alter table public.manager_vip_accounts enable row level security;

revoke all on public.manager_vip_accounts from anon, authenticated;
grant select, insert, delete on public.manager_vip_accounts to authenticated;

drop policy if exists "manager vip self or super admin read" on public.manager_vip_accounts;
create policy "manager vip self or super admin read"
  on public.manager_vip_accounts
  for select
  using (
    auth.uid() = manager_user_id
    or public.has_role_at_least('super_admin')
  );

drop policy if exists "manager vip super admin manage" on public.manager_vip_accounts;
create policy "manager vip super admin manage"
  on public.manager_vip_accounts
  for all
  using (public.has_role_at_least('super_admin'))
  with check (public.has_role_at_least('super_admin'));

create or replace function public.assign_vip_to_manager(
  target_manager_user_id uuid,
  target_vip_user_id uuid
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

  if not exists (
    select 1
    from public.user_roles
    where user_id = target_manager_user_id
      and role = 'manager'
  ) then
    raise exception 'target-user-is-not-manager';
  end if;

  if not exists (
    select 1
    from public.user_roles
    where user_id = target_vip_user_id
      and role = 'vip'
  ) then
    raise exception 'target-user-is-not-vip';
  end if;

  insert into public.manager_vip_accounts (
    manager_user_id,
    vip_user_id,
    created_by
  )
  values (
    target_manager_user_id,
    target_vip_user_id,
    auth.uid()
  )
  on conflict do nothing;

  perform public.log_admin_action(
    action_name := 'assign_vip_to_manager',
    target_user_id := target_manager_user_id,
    target_resource := 'manager_vip_accounts',
    target_resource_id := target_manager_user_id::text || ':' || target_vip_user_id::text,
    details := jsonb_build_object(
      'manager_user_id', target_manager_user_id,
      'vip_user_id', target_vip_user_id
    )
  );
end;
$$;

create or replace function public.revoke_vip_from_manager(
  target_manager_user_id uuid,
  target_vip_user_id uuid
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

  delete from public.manager_vip_accounts
  where manager_user_id = target_manager_user_id
    and vip_user_id = target_vip_user_id;

  perform public.log_admin_action(
    action_name := 'revoke_vip_from_manager',
    target_user_id := target_manager_user_id,
    target_resource := 'manager_vip_accounts',
    target_resource_id := target_manager_user_id::text || ':' || target_vip_user_id::text,
    details := jsonb_build_object(
      'manager_user_id', target_manager_user_id,
      'vip_user_id', target_vip_user_id
    )
  );
end;
$$;

create or replace function public.get_manager_vip_directory()
returns table (
  manager_user_id uuid,
  manager_handle text,
  manager_display_name text,
  vip_user_id uuid,
  vip_handle text,
  vip_display_name text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    mva.manager_user_id,
    manager_profile.handle as manager_handle,
    manager_profile.display_name as manager_display_name,
    mva.vip_user_id,
    vip_profile.handle as vip_handle,
    vip_profile.display_name as vip_display_name,
    mva.created_at
  from public.manager_vip_accounts mva
  join public.profiles manager_profile
    on manager_profile.id = mva.manager_user_id
  join public.profiles vip_profile
    on vip_profile.id = mva.vip_user_id
  where
    public.has_role_at_least('super_admin')
    or mva.manager_user_id = auth.uid()
  order by mva.created_at desc
$$;

grant execute on function public.assign_vip_to_manager(uuid, uuid) to authenticated;
grant execute on function public.revoke_vip_from_manager(uuid, uuid) to authenticated;
grant execute on function public.get_manager_vip_directory() to authenticated;
