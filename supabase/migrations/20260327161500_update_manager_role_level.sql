create or replace function public.role_level(target_role public.app_role)
returns integer
language sql
immutable
as $$
  select case target_role
    when 'user' then 10
    when 'pro' then 20
    when 'vip' then 30
    when 'manager' then 70
    when 'moderator' then 50
    when 'admin' then 100
    when 'super_admin' then 1000
  end
$$;
