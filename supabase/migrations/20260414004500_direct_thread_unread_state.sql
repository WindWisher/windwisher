alter table public.direct_thread_user_states
  add column if not exists last_read_message_created_at timestamptz;
