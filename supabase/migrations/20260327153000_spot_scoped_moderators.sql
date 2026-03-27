create table if not exists public.spot_moderators (
  user_id uuid not null references public.profiles(id) on delete cascade,
  spot_key text not null,
  created_at timestamptz not null default timezone('utc', now()),
  created_by uuid references public.profiles(id) on delete set null,
  primary key (user_id, spot_key)
);

create index if not exists spot_moderators_spot_key_idx
  on public.spot_moderators (spot_key, created_at desc);

alter table public.spot_moderators enable row level security;

revoke all on public.spot_moderators from anon, authenticated;
grant select on public.spot_moderators to authenticated;
grant insert, delete on public.spot_moderators to authenticated;

drop policy if exists "spot moderators self or super admin read" on public.spot_moderators;
create policy "spot moderators self or super admin read"
  on public.spot_moderators
  for select
  using (
    auth.uid() = user_id
    or public.has_role_at_least('super_admin')
  );

drop policy if exists "spot moderators super admin manage" on public.spot_moderators;
create policy "spot moderators super admin manage"
  on public.spot_moderators
  for all
  using (public.has_role_at_least('super_admin'))
  with check (public.has_role_at_least('super_admin'));

create or replace function public.can_moderate_spot(target_spot_key text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    auth.uid() is not null
    and (
      public.has_role_at_least('admin')
      or exists (
        select 1
        from public.user_roles ur
        join public.spot_moderators sm
          on sm.user_id = ur.user_id
        where ur.user_id = auth.uid()
          and ur.role = 'moderator'
          and sm.spot_key = coalesce(target_spot_key, '')
      )
    )
$$;

grant execute on function public.can_moderate_spot(text) to authenticated;

drop policy if exists "spot_social_posts own or moderator update" on public.spot_social_posts;
create policy "spot_social_posts own or spot moderator update"
  on public.spot_social_posts
  for update
  to authenticated
  using (
    auth.uid() = author_user_id
    or public.can_moderate_spot(spot_key)
  )
  with check (
    auth.uid() = author_user_id
    or public.can_moderate_spot(spot_key)
  );

drop policy if exists "spot_social_posts own or moderator delete" on public.spot_social_posts;
create policy "spot_social_posts own or spot moderator delete"
  on public.spot_social_posts
  for delete
  to authenticated
  using (
    auth.uid() = author_user_id
    or public.can_moderate_spot(spot_key)
  );

drop policy if exists "spot_social_replies own or moderator update" on public.spot_social_replies;
create policy "spot_social_replies own or spot moderator update"
  on public.spot_social_replies
  for update
  to authenticated
  using (
    auth.uid() = author_user_id
    or exists (
      select 1
      from public.spot_social_posts p
      where p.id = post_id
        and public.can_moderate_spot(p.spot_key)
    )
  )
  with check (
    auth.uid() = author_user_id
    or exists (
      select 1
      from public.spot_social_posts p
      where p.id = post_id
        and public.can_moderate_spot(p.spot_key)
    )
  );

drop policy if exists "spot_social_replies own or moderator delete" on public.spot_social_replies;
create policy "spot_social_replies own or spot moderator delete"
  on public.spot_social_replies
  for delete
  to authenticated
  using (
    auth.uid() = author_user_id
    or exists (
      select 1
      from public.spot_social_posts p
      where p.id = post_id
        and public.can_moderate_spot(p.spot_key)
    )
  );
