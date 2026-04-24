update public.account_deletion_requests
set status = 'cancelled'
where status not in ('scheduled', 'cancelled', 'completed');

alter table public.account_deletion_requests
  drop constraint if exists account_deletion_requests_status_check;

alter table public.account_deletion_requests
  add constraint account_deletion_requests_status_check
  check (status in ('scheduled', 'cancelled', 'completed'));

drop policy if exists "account deletion requests own cancel"
on public.account_deletion_requests;

create policy "account deletion requests own cancel"
on public.account_deletion_requests
for update
using (
  auth.uid() = user_id
  and status = 'scheduled'
  and coalesce(execute_after, now()) > now()
)
with check (
  auth.uid() = user_id
  and status = 'cancelled'
);
