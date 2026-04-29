alter table public.profiles
  add column if not exists accepted_terms_version text,
  add column if not exists accepted_terms_at timestamptz,
  add column if not exists onboarding_welcome_completed_at timestamptz;

create or replace function public.mark_terms_acceptance(
  terms_version text,
  accepted_at_utc timestamptz default timezone('utc', now())
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  generated_handle text;
begin
  if current_user_id is null then
    raise exception 'not-authenticated';
  end if;

  if terms_version is null or length(trim(terms_version)) = 0 then
    raise exception 'invalid-terms-version';
  end if;

  generated_handle := 'ww_' || left(replace(current_user_id::text, '-', ''), 16);

  insert into public.profiles (
    id,
    display_name,
    handle,
    accepted_terms_version,
    accepted_terms_at
  )
  values (
    current_user_id,
    '',
    generated_handle,
    terms_version,
    coalesce(accepted_at_utc, timezone('utc', now()))
  )
  on conflict (id) do update
  set
    accepted_terms_version = excluded.accepted_terms_version,
    accepted_terms_at = excluded.accepted_terms_at,
    updated_at = timezone('utc', now());
end;
$$;

create or replace function public.mark_onboarding_welcome_completed(
  completed_at_utc timestamptz default timezone('utc', now())
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  generated_handle text;
begin
  if current_user_id is null then
    raise exception 'not-authenticated';
  end if;

  generated_handle := 'ww_' || left(replace(current_user_id::text, '-', ''), 16);

  insert into public.profiles (
    id,
    display_name,
    handle,
    onboarding_welcome_completed_at
  )
  values (
    current_user_id,
    '',
    generated_handle,
    coalesce(completed_at_utc, timezone('utc', now()))
  )
  on conflict (id) do update
  set
    onboarding_welcome_completed_at = excluded.onboarding_welcome_completed_at,
    updated_at = timezone('utc', now());
end;
$$;

grant execute on function public.mark_terms_acceptance(text, timestamptz)
to authenticated;

grant execute on function public.mark_onboarding_welcome_completed(timestamptz)
to authenticated;
