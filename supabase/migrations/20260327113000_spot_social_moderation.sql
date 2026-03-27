grant update, delete on public.spot_social_replies to authenticated;

drop policy if exists "spot_social_posts own update" on public.spot_social_posts;
create policy "spot_social_posts own or moderator update"
  on public.spot_social_posts
  for update
  to authenticated
  using (
    auth.uid() = author_user_id
    or public.has_role_at_least('moderator')
  )
  with check (
    auth.uid() = author_user_id
    or public.has_role_at_least('moderator')
  );

drop policy if exists "spot_social_posts own delete" on public.spot_social_posts;
create policy "spot_social_posts own or moderator delete"
  on public.spot_social_posts
  for delete
  to authenticated
  using (
    auth.uid() = author_user_id
    or public.has_role_at_least('moderator')
  );

drop policy if exists "spot_social_replies own update" on public.spot_social_replies;
create policy "spot_social_replies own or moderator update"
  on public.spot_social_replies
  for update
  to authenticated
  using (
    auth.uid() = author_user_id
    or public.has_role_at_least('moderator')
  )
  with check (
    auth.uid() = author_user_id
    or public.has_role_at_least('moderator')
  );

drop policy if exists "spot_social_replies own delete" on public.spot_social_replies;
create policy "spot_social_replies own or moderator delete"
  on public.spot_social_replies
  for delete
  to authenticated
  using (
    auth.uid() = author_user_id
    or public.has_role_at_least('moderator')
  );
