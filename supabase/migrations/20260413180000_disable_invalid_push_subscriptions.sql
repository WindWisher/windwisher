create or replace function public.disable_backend_push_subscription(
  target_user_id uuid,
  target_device_token text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.user_push_subscriptions
  set
    enabled = false,
    updated_at = timezone('utc', now())
  where user_id = target_user_id
    and device_token = target_device_token;
end;
$$;

grant execute on function public.disable_backend_push_subscription(uuid, text)
  to anon, authenticated;
