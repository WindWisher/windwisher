create policy "session comments owner update"
on public.session_comments
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "direct messages sender update"
on public.direct_messages
for update
using (auth.uid() = sender_user_id)
with check (auth.uid() = sender_user_id);

create policy "direct messages sender delete"
on public.direct_messages
for delete
using (auth.uid() = sender_user_id);
