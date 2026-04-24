drop index if exists account_deletion_requests_one_open_per_user_idx;

create unique index if not exists account_deletion_requests_one_scheduled_per_user_idx
on public.account_deletion_requests (user_id)
where status = 'scheduled';

drop policy if exists "account deletion requests own cancel"
on public.account_deletion_requests;
create policy "account deletion requests own cancel"
on public.account_deletion_requests
for update
using (
  auth.uid() = user_id
  and status = 'scheduled'
)
with check (
  auth.uid() = user_id
  and status = 'cancelled'
);
