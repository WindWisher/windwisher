create or replace function public.has_advanced_saved_spot_access()
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
      and ur.role in ('pro', 'vip', 'moderator', 'admin', 'super_admin')
  )
$$;

create or replace function public.can_insert_saved_spot(target_is_custom boolean)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select case
    when auth.uid() is null then false
    when public.has_advanced_saved_spot_access() then true
    when coalesce(target_is_custom, false) then false
    else (
      select count(*)
      from public.user_saved_spots uss
      where uss.user_id = auth.uid()
        and coalesce(uss.is_custom, false) = false
    ) < 2
  end
$$;

drop policy if exists "saved spots owner full access" on public.user_saved_spots;
drop policy if exists "saved spots owner read" on public.user_saved_spots;
create policy "saved spots owner read"
on public.user_saved_spots
for select
using (auth.uid() = user_id);

drop policy if exists "saved spots owner insert with limits" on public.user_saved_spots;
create policy "saved spots owner insert with limits"
on public.user_saved_spots
for insert
with check (
  auth.uid() = user_id
  and public.can_insert_saved_spot(is_custom)
);

drop policy if exists "saved spots owner advanced update" on public.user_saved_spots;
create policy "saved spots owner advanced update"
on public.user_saved_spots
for update
using (
  auth.uid() = user_id
  and public.has_advanced_saved_spot_access()
)
with check (
  auth.uid() = user_id
  and public.has_advanced_saved_spot_access()
);

drop policy if exists "saved spots owner advanced delete" on public.user_saved_spots;
create policy "saved spots owner advanced delete"
on public.user_saved_spots
for delete
using (
  auth.uid() = user_id
  and public.has_advanced_saved_spot_access()
);

grant execute on function public.has_advanced_saved_spot_access() to authenticated;
grant execute on function public.can_insert_saved_spot(boolean) to authenticated;
