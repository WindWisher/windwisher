create or replace function public.is_profile_handle_available(
  candidate_handle text
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  with normalized_candidate as (
    select lower(regexp_replace(trim(coalesce(candidate_handle, '')), '^@+', '')) as handle
  )
  select not exists (
    select 1
    from public.profiles p
    cross join normalized_candidate c
    where c.handle <> ''
      and lower(regexp_replace(trim(p.handle), '^@+', '')) = c.handle
      and p.id <> auth.uid()
    limit 1
  );
$$;

grant execute on function public.is_profile_handle_available(text)
to authenticated;
