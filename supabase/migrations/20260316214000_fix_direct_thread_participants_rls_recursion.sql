create or replace function public.is_thread_participant(target_thread_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.direct_thread_participants
    where thread_id = target_thread_id
      and user_id = auth.uid()
  );
$$;

revoke all on function public.is_thread_participant(uuid) from public;
grant execute on function public.is_thread_participant(uuid) to authenticated;

drop policy if exists "threads visible to participants" on public.direct_threads;
create policy "threads visible to participants"
on public.direct_threads
for select
using (public.is_thread_participant(id));

drop policy if exists "thread participants visible to participants" on public.direct_thread_participants;
create policy "thread participants visible to participants"
on public.direct_thread_participants
for select
using (public.is_thread_participant(thread_id));

drop policy if exists "messages visible to participants" on public.direct_messages;
create policy "messages visible to participants"
on public.direct_messages
for select
using (public.is_thread_participant(thread_id));

drop policy if exists "messages participants insert" on public.direct_messages;
create policy "messages participants insert"
on public.direct_messages
for insert
with check (
  auth.uid() = sender_user_id
  and public.is_thread_participant(thread_id)
);
