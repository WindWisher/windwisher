create or replace function public.is_storage_owner(path text, user_id uuid)
returns boolean
language sql
stable
as $$
  select split_part(path, '/', 1) = user_id::text
$$;

create or replace function public.toggle_session_like(target_session_id uuid)
returns table (
  session_id uuid,
  is_liked boolean,
  likes_count bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  liked_now boolean;
begin
  if current_user_id is null then
    raise exception 'not-authenticated';
  end if;

  if exists (
    select 1
    from public.session_likes
    where session_likes.session_id = target_session_id
      and session_likes.user_id = current_user_id
  ) then
    delete from public.session_likes
    where session_likes.session_id = target_session_id
      and session_likes.user_id = current_user_id;
    liked_now := false;
  else
    insert into public.session_likes (session_id, user_id)
    values (target_session_id, current_user_id)
    on conflict do nothing;
    liked_now := true;
  end if;

  return query
  select
    target_session_id,
    liked_now,
    count(*)::bigint
  from public.session_likes
  where public.session_likes.session_id = target_session_id
  group by target_session_id;
end;
$$;

create or replace function public.follow_user(target_user_id uuid)
returns void
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
  if current_user_id = target_user_id then
    raise exception 'cannot-follow-self';
  end if;

  insert into public.user_follows (follower_user_id, followed_user_id)
  values (current_user_id, target_user_id)
  on conflict do nothing;
end;
$$;

create or replace function public.unfollow_user(target_user_id uuid)
returns void
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

  delete from public.user_follows
  where follower_user_id = current_user_id
    and followed_user_id = target_user_id;
end;
$$;

create or replace function public.add_session_comment(
  target_session_id uuid,
  comment_text text
)
returns public.session_comments
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  author_handle text;
  inserted_comment public.session_comments;
begin
  if current_user_id is null then
    raise exception 'not-authenticated';
  end if;

  select handle
  into author_handle
  from public.profiles
  where id = current_user_id;

  insert into public.session_comments (
    session_id,
    user_id,
    author_username,
    text
  )
  values (
    target_session_id,
    current_user_id,
    coalesce(author_handle, 'user'),
    trim(comment_text)
  )
  returning * into inserted_comment;

  return inserted_comment;
end;
$$;

create or replace function public.upsert_profile(
  new_display_name text default null,
  new_handle text default null,
  new_public_tagline text default null,
  new_bio text default null,
  new_level text default null,
  new_base_spot text default null,
  new_avatar_path text default null,
  new_banner_path text default null
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  updated_profile public.profiles;
begin
  if current_user_id is null then
    raise exception 'not-authenticated';
  end if;

  update public.profiles
  set
    display_name = coalesce(new_display_name, display_name),
    handle = coalesce(new_handle, handle),
    public_tagline = coalesce(new_public_tagline, public_tagline),
    bio = coalesce(new_bio, bio),
    level = coalesce(new_level, level),
    base_spot = coalesce(new_base_spot, base_spot),
    avatar_path = coalesce(new_avatar_path, avatar_path),
    banner_path = coalesce(new_banner_path, banner_path)
  where id = current_user_id
  returning * into updated_profile;

  return updated_profile;
end;
$$;

grant execute on function public.toggle_session_like(uuid) to authenticated;
grant execute on function public.follow_user(uuid) to authenticated;
grant execute on function public.unfollow_user(uuid) to authenticated;
grant execute on function public.add_session_comment(uuid, text) to authenticated;
grant execute on function public.upsert_profile(text, text, text, text, text, text, text, text) to authenticated;

create policy "public read profile avatars"
on storage.objects
for select
using (bucket_id = 'profile-avatars');

create policy "public read profile banners"
on storage.objects
for select
using (bucket_id = 'profile-banners');

create policy "public read session media"
on storage.objects
for select
using (bucket_id = 'session-media');

create policy "owner write profile avatars"
on storage.objects
for all
using (
  bucket_id = 'profile-avatars'
  and public.is_storage_owner(name, auth.uid())
)
with check (
  bucket_id = 'profile-avatars'
  and public.is_storage_owner(name, auth.uid())
);

create policy "owner write profile banners"
on storage.objects
for all
using (
  bucket_id = 'profile-banners'
  and public.is_storage_owner(name, auth.uid())
)
with check (
  bucket_id = 'profile-banners'
  and public.is_storage_owner(name, auth.uid())
);

create policy "owner write session media"
on storage.objects
for all
using (
  bucket_id = 'session-media'
  and public.is_storage_owner(name, auth.uid())
)
with check (
  bucket_id = 'session-media'
  and public.is_storage_owner(name, auth.uid())
);
