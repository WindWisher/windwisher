drop index if exists account_deletion_requests_one_open_per_user_idx;

alter table public.account_deletion_requests
  add column if not exists confirmed_at timestamptz,
  add column if not exists execute_after timestamptz;

update public.account_deletion_requests
set
  confirmed_at = coalesce(confirmed_at, created_at),
  execute_after = coalesce(execute_after, created_at + interval '7 days')
where confirmed_at is null
   or execute_after is null;

alter table public.account_deletion_requests
  drop constraint if exists account_deletion_requests_status_check;

alter table public.account_deletion_requests
  add constraint account_deletion_requests_status_check
  check (
    status in (
      'pending',
      'processing',
      'scheduled',
      'completed',
      'rejected',
      'cancelled'
    )
  );

create unique index if not exists account_deletion_requests_one_open_per_user_idx
on public.account_deletion_requests (user_id)
where status in ('pending', 'processing', 'scheduled');
