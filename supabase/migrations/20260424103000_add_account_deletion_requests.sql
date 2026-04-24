create table if not exists public.account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  note text not null default '',
  status text not null default 'pending',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint account_deletion_requests_status_check
    check (status in ('pending', 'processing', 'completed', 'rejected'))
);

create unique index if not exists account_deletion_requests_one_open_per_user_idx
on public.account_deletion_requests (user_id)
where status in ('pending', 'processing');

drop trigger if exists set_account_deletion_requests_updated_at
on public.account_deletion_requests;

create trigger set_account_deletion_requests_updated_at
  before update on public.account_deletion_requests
  for each row execute procedure public.set_updated_at();

alter table public.account_deletion_requests enable row level security;

drop policy if exists "account deletion requests own read"
on public.account_deletion_requests;
create policy "account deletion requests own read"
on public.account_deletion_requests
for select
using (auth.uid() = user_id);

drop policy if exists "account deletion requests own insert"
on public.account_deletion_requests;
create policy "account deletion requests own insert"
on public.account_deletion_requests
for insert
with check (
  auth.uid() = user_id
  and status = 'pending'
);
