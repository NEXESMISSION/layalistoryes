-- Add image_urls column for multiple uploaded images (if table already exists).
-- Run this in Supabase SQL Editor, then run submit-order-with-images.sql.

alter table public.orders add column if not exists image_urls jsonb default '[]';
comment on column public.orders.image_urls is 'Array of uploaded image URLs from the form';
