alter table public.user_kites add column if not exists price_eur text not null default '';
alter table public.user_bars add column if not exists price_eur text not null default '';
alter table public.user_boards add column if not exists price_eur text not null default '';
alter table public.user_harnesses add column if not exists price_eur text not null default '';
alter table public.user_wetsuits add column if not exists price_eur text not null default '';
alter table public.user_helmets add column if not exists price_eur text not null default '';
alter table public.user_vests add column if not exists price_eur text not null default '';
