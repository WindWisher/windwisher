alter table public.user_push_subscriptions
  add column if not exists spot_alarms_enabled boolean not null default true,
  add column if not exists direct_messages_enabled boolean not null default true,
  add column if not exists spot_chat_mentions_enabled boolean not null default true;

create or replace function public.get_backend_push_subscriptions()
returns table (
  user_id uuid,
  device_token text,
  platform text,
  provider text,
  enabled boolean
)
language sql
security definer
set search_path = public
as $$
  select
    user_id,
    device_token,
    platform,
    provider,
    enabled
  from public.user_push_subscriptions
  where enabled = true
    and spot_alarms_enabled = true;
$$;

create or replace function public.get_backend_direct_message_push_targets(
  target_message_id uuid
)
returns table (
  message_id uuid,
  thread_id uuid,
  recipient_user_id uuid,
  device_token text,
  platform text,
  provider text,
  sender_user_id uuid,
  sender_display_name text,
  sender_handle text,
  message_body text,
  attachment_type text
)
language sql
security definer
set search_path = public
as $$
  select
    dm.id as message_id,
    dm.thread_id,
    recipient.user_id as recipient_user_id,
    push.device_token,
    push.platform,
    push.provider,
    sender.id as sender_user_id,
    coalesce(nullif(sender.display_name, ''), nullif(sender.handle, ''), 'Rider') as sender_display_name,
    coalesce(sender.handle, '') as sender_handle,
    dm.body as message_body,
    coalesce(dm.attachment_type, 'text') as attachment_type
  from public.direct_messages dm
  join public.profiles sender
    on sender.id = dm.sender_user_id
  join public.direct_thread_participants recipient
    on recipient.thread_id = dm.thread_id
   and recipient.user_id <> dm.sender_user_id
  join public.user_push_subscriptions push
    on push.user_id = recipient.user_id
   and push.enabled = true
   and push.direct_messages_enabled = true
  left join public.direct_thread_user_states recipient_state
    on recipient_state.thread_id = dm.thread_id
   and recipient_state.user_id = recipient.user_id
  where dm.id = target_message_id
    and dm.sender_user_id = auth.uid()
    and coalesce(recipient_state.is_muted, false) = false
    and coalesce(recipient_state.is_blocked, false) = false
    and coalesce(recipient_state.is_deleted, false) = false;
$$;

grant execute on function public.get_backend_push_subscriptions()
  to anon, authenticated;
grant execute on function public.get_backend_direct_message_push_targets(uuid)
  to authenticated;
