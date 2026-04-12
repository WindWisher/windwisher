drop policy if exists "profiles are publicly readable" on public.profiles;

create policy "profiles owner read"
on public.profiles
for select
using (auth.uid() = id);

create or replace view public.public_profiles as
select
  id,
  display_name,
  handle,
  public_tagline,
  avatar_path,
  banner_path,
  total_sessions,
  water_hours,
  jumps,
  top_jump_m
from public.profiles;

grant select on public.public_profiles to anon;
grant select on public.public_profiles to authenticated;
