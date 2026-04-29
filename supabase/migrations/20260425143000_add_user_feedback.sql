create table if not exists public.user_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  message text not null,
  status text not null default 'open',
  admin_note text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  resolved_at timestamptz,
  constraint user_feedback_message_not_empty
    check (length(trim(message)) > 0),
  constraint user_feedback_status_check
    check (status in ('open', 'reviewed', 'resolved', 'archived'))
);

create index if not exists user_feedback_status_created_idx
on public.user_feedback (status, created_at desc);

create index if not exists user_feedback_user_created_idx
on public.user_feedback (user_id, created_at desc);

drop trigger if exists set_user_feedback_updated_at
on public.user_feedback;

create trigger set_user_feedback_updated_at
  before update on public.user_feedback
  for each row execute procedure public.set_updated_at();

alter table public.user_feedback enable row level security;

drop policy if exists "user feedback own read or admin read"
on public.user_feedback;
create policy "user feedback own read or admin read"
on public.user_feedback
for select
using (
  auth.uid() = user_id
  or public.has_role_at_least('admin')
);

drop policy if exists "user feedback own insert"
on public.user_feedback;
create policy "user feedback own insert"
on public.user_feedback
for insert
with check (
  auth.uid() = user_id
  and status = 'open'
  and admin_note = ''
  and resolved_at is null
);

drop policy if exists "user feedback admin update"
on public.user_feedback;
create policy "user feedback admin update"
on public.user_feedback
for update
using (public.has_role_at_least('admin'))
with check (public.has_role_at_least('admin'));

create or replace function public.get_user_feedback_admin(
  limit_count integer default 100,
  offset_count integer default 0
)
returns table (
  id uuid,
  user_id uuid,
  user_handle text,
  user_display_name text,
  message text,
  status text,
  admin_note text,
  created_at timestamptz,
  updated_at timestamptz,
  resolved_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    uf.id,
    uf.user_id,
    coalesce(p.handle, '') as user_handle,
    coalesce(p.display_name, '') as user_display_name,
    uf.message,
    uf.status,
    uf.admin_note,
    uf.created_at,
    uf.updated_at,
    uf.resolved_at
  from public.user_feedback uf
  left join public.profiles p
    on p.id = uf.user_id
  where public.has_role_at_least('admin')
  order by
    case uf.status
      when 'open' then 0
      when 'reviewed' then 1
      when 'resolved' then 2
      else 3
    end,
    uf.created_at desc
  limit greatest(coalesce(limit_count, 100), 1)
  offset greatest(coalesce(offset_count, 0), 0)
$$;

create or replace function public.update_user_feedback_status(
  feedback_id uuid,
  next_status text,
  next_admin_note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  updated_user_id uuid;
begin
  if auth.uid() is null then
    raise exception 'not-authenticated';
  end if;

  if not public.has_role_at_least('admin') then
    raise exception 'forbidden';
  end if;

  if next_status not in ('open', 'reviewed', 'resolved', 'archived') then
    raise exception 'invalid-feedback-status';
  end if;

  update public.user_feedback
  set
    status = next_status,
    admin_note = coalesce(next_admin_note, admin_note),
    resolved_at = case
      when next_status = 'resolved' then coalesce(resolved_at, timezone('utc', now()))
      when next_status in ('open', 'reviewed') then null
      else resolved_at
    end
  where id = feedback_id
  returning user_id into updated_user_id;

  if updated_user_id is null then
    raise exception 'feedback-not-found';
  end if;

  perform public.log_admin_action(
    action_name := 'update_user_feedback_status',
    target_user_id := updated_user_id,
    target_resource := 'user_feedback',
    target_resource_id := feedback_id::text,
    details := jsonb_build_object(
      'status', next_status,
      'has_admin_note', coalesce(next_admin_note, '') <> ''
    )
  );
end;
$$;

grant select, insert, update on public.user_feedback to authenticated;
grant execute on function public.get_user_feedback_admin(integer, integer) to authenticated;
grant execute on function public.update_user_feedback_status(uuid, text, text) to authenticated;
