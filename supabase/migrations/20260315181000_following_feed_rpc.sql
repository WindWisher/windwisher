create or replace function public.get_following_feed(
  limit_count integer default 100,
  offset_count integer default 0
)
returns table (
  id uuid,
  username text,
  title text,
  spot text,
  ended_at timestamptz,
  big_air_score integer,
  highest_jump_meters numeric,
  distance_km numeric,
  duration_seconds integer,
  equipment_label text,
  likes_count integer,
  has_session_photo boolean,
  user_id uuid
)
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'not-authenticated';
  end if;

  return query
  select
    s.id,
    p.handle as username,
    s.title,
    coalesce(s.spot_name, p.base_spot, '') as spot,
    s.ended_at,
    s.big_air_score,
    s.highest_jump_m as highest_jump_meters,
    s.distance_km,
    s.duration_seconds,
    coalesce(s.gear_setup_name, '') as equipment_label,
    coalesce(l.likes_count, 0)::integer as likes_count,
    s.has_session_photo,
    s.user_id
  from public.sessions s
  join public.profiles p on p.id = s.user_id
  join public.user_follows f on f.followed_user_id = s.user_id
  left join (
    select session_id, count(*) as likes_count
    from public.session_likes
    group by session_id
  ) l on l.session_id = s.id
  where f.follower_user_id = current_user_id
    and s.is_public = true
  order by s.ended_at desc
  limit greatest(limit_count, 0)
  offset greatest(offset_count, 0);
end;
$$;

grant execute on function public.get_following_feed(integer, integer) to authenticated;
