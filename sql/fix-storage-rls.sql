-- =============================================================================
-- Fix: "new row violates row-level security policy" when uploading images
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor → New query).
--
-- This adds RLS policies on storage.objects so that:
--   1. Anonymous users (the form) can UPLOAD (INSERT) to bucket "order-images"
--   2. Anyone can READ (SELECT) from "order-images" so image URLs work
--
-- Before running: Create the bucket "order-images" in Storage (Dashboard → Storage
-- → New bucket, name: order-images, Public: ON).
-- =============================================================================

-- 1) Allow anon to INSERT (upload) into bucket order-images
drop policy if exists "Allow anon upload" on storage.objects;
create policy "Allow anon upload"
on storage.objects
for insert
to anon
with check (bucket_id = 'order-images');

-- 2) Allow read so image URLs work (anon = visitors; authenticated = admin dashboard)
drop policy if exists "Allow public read order-images" on storage.objects;
create policy "Allow public read order-images"
on storage.objects
for select
to anon
using (bucket_id = 'order-images');

-- Allow authenticated (admin) to read as well
drop policy if exists "Allow authenticated read order-images" on storage.objects;
create policy "Allow authenticated read order-images"
on storage.objects
for select
to authenticated
using (bucket_id = 'order-images');
