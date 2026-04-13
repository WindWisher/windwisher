create or replace function public.is_thread_creator(target_thread_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.direct_threads t
    where t.id = target_thread_id
      and t.created_by = auth.uid()
  );
$$;

grant execute on function public.is_thread_creator(uuid) to authenticated;

drop policy if exists "threads visible to participants" on public.direct_threads;
create policy "threads visible to creator or participants"
on public.direct_threads
for select
using (
  created_by = auth.uid()
  or public.is_thread_participant(id)
);

drop policy if exists "thread participants visible to participants" on public.direct_thread_participants;
create policy "thread participants visible to creator or participants"
on public.direct_thread_participants
for select
using (
  public.is_thread_creator(thread_id)
  or public.is_thread_participant(thread_id)
);

drop policy if exists "thread participants creator manages" on public.direct_thread_participants;
create policy "thread participants creator manages"
on public.direct_thread_participants
for all
using (public.is_thread_creator(thread_id))
with check (public.is_thread_creator(thread_id));
