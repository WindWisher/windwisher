create table if not exists public.direct_thread_user_states (
  thread_id uuid not null references public.direct_threads(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  is_muted boolean not null default false,
  is_blocked boolean not null default false,
  is_deleted boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (thread_id, user_id)
);

create index if not exists direct_thread_user_states_user_id_idx
on public.direct_thread_user_states (user_id, updated_at desc);

create trigger set_direct_thread_user_states_updated_at
  before update on public.direct_thread_user_states
  for each row execute procedure public.set_updated_at();

alter table public.direct_thread_user_states enable row level security;

create policy "thread states owner full access"
on public.direct_thread_user_states
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
