insert into public.user_roles (user_id, role)
select p.id, 'pro'::public.app_role
from public.profiles p
on conflict (user_id, role) do nothing;
