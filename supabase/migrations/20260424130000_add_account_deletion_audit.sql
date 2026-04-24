create table if not exists public.account_deletion_audit (
  id uuid primary key default gen_random_uuid(),
  request_id uuid,
  user_id uuid not null,
  status text not null,
  scheduled_execute_after timestamptz,
  confirmed_at timestamptz,
  processed_at timestamptz not null default now(),
  error_message text,
  constraint account_deletion_audit_status_check
    check (status in ('deleted', 'delete_failed', 'skipped_invalid_row'))
);

create index if not exists account_deletion_audit_user_id_idx
on public.account_deletion_audit (user_id, processed_at desc);

create index if not exists account_deletion_audit_request_id_idx
on public.account_deletion_audit (request_id);

alter table public.account_deletion_audit enable row level security;
