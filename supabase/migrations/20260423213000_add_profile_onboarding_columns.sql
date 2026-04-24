alter table public.profiles
  add column if not exists accepted_terms_version text,
  add column if not exists accepted_terms_at timestamptz,
  add column if not exists onboarding_welcome_completed_at timestamptz;
