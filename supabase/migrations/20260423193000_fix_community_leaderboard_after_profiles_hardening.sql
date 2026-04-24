create or replace view public.community_leaderboard as
with session_aggregates as (
  select
    s.user_id,
    coalesce(round(avg(s.big_air_score)), 0)::integer as big_air_score,
    coalesce(sum(s.big_air_score), 0)::integer as activity_score,
    coalesce(max(s.highest_jump_m), 0)::numeric(10,2) as highest_jump_meters
  from public.sessions s
  where s.is_public = true
  group by s.user_id
),
spot_rankings as (
  select
    s.user_id,
    s.spot_name,
    row_number() over (
      partition by s.user_id
      order by count(*) desc, max(s.ended_at) desc, s.spot_name asc
    ) as spot_rank
  from public.sessions s
  where s.is_public = true
    and nullif(trim(s.spot_name), '') is not null
  group by s.user_id, s.spot_name
)
select
  p.id as user_id,
  p.handle as username,
  coalesce(a.big_air_score, 0)::integer as big_air_score,
  coalesce(a.activity_score, 0)::integer as activity_score,
  coalesce(a.highest_jump_meters, 0)::numeric(10,2) as highest_jump_meters,
  coalesce(sr.spot_name, '')::text as main_spot,
  0 as avatar_color_value
from public.public_profiles p
left join session_aggregates a
  on a.user_id = p.id
left join spot_rankings sr
  on sr.user_id = p.id
 and sr.spot_rank = 1;

grant select on public.community_leaderboard to anon;
grant select on public.community_leaderboard to authenticated;
