update public.profiles
set avatar_path = replace(
  avatar_path,
  'https://tefbkhwaxlsfxvnleutb.supabase.co',
  'https://uayzvkjqiiupbeevxrtc.supabase.co'
)
where avatar_path like '%tefbkhwaxlsfxvnleutb.supabase.co%';

update public.profiles
set banner_path = replace(
  banner_path,
  'https://tefbkhwaxlsfxvnleutb.supabase.co',
  'https://uayzvkjqiiupbeevxrtc.supabase.co'
)
where banner_path like '%tefbkhwaxlsfxvnleutb.supabase.co%';

update public.sessions
set session_photo_path = replace(
  session_photo_path,
  'https://tefbkhwaxlsfxvnleutb.supabase.co',
  'https://uayzvkjqiiupbeevxrtc.supabase.co'
)
where session_photo_path like '%tefbkhwaxlsfxvnleutb.supabase.co%';

update public.direct_messages
set public_url = replace(
  public_url,
  'https://tefbkhwaxlsfxvnleutb.supabase.co',
  'https://uayzvkjqiiupbeevxrtc.supabase.co'
)
where public_url like '%tefbkhwaxlsfxvnleutb.supabase.co%';

update public.spot_social_attachments
set public_url = replace(
  public_url,
  'https://tefbkhwaxlsfxvnleutb.supabase.co',
  'https://uayzvkjqiiupbeevxrtc.supabase.co'
)
where public_url like '%tefbkhwaxlsfxvnleutb.supabase.co%';
