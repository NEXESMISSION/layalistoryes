-- Add hero/subhero image URL columns to existing orders table.
-- Run this in Supabase SQL Editor if you already created orders without these columns.

alter table public.orders
  add column if not exists hero_image_url text,
  add column if not exists subhero_image_url text;

comment on column public.orders.hero_image_url is 'URL of main/cover image (hero) provided by customer';
comment on column public.orders.subhero_image_url is 'URL of secondary image (subhero) provided by customer';
