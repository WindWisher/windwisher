drop view if exists public.community_leaderboard;

create or replace view public.community_leaderboard as
select
  p.id as user_id,
  p.handle as username,
  coalesce(round(avg(s.big_air_score)), 0)::integer as big_air_score,
  coalesce(sum(s.big_air_score), 0)::integer as activity_score,
  coalesce(max(s.highest_jump_m), 0)::numeric(10,2) as highest_jump_meters,
  nullif(p.base_spot, '') as main_spot,
  0 as avatar_color_value
from public.profiles p
left join public.sessions s
  on s.user_id = p.id
 and s.is_public = true
group by p.id, p.handle, p.base_spot;
