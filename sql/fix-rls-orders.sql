-- Run this in Supabase SQL Editor if you get "new row violates row-level security policy"
-- This resets RLS policies on public.orders so anon can insert.

-- Drop all existing policies on orders (names may vary)
drop policy if exists "Allow anonymous insert" on public.orders;
drop policy if exists "Allow authenticated read" on public.orders;
drop policy if exists "Allow authenticated delete" on public.orders;
drop policy if exists "orders_insert_anon" on public.orders;
drop policy if exists "orders_select_authenticated" on public.orders;
drop policy if exists "orders_delete_authenticated" on public.orders;

-- Recreate: anon can INSERT (form submission)
create policy "orders_insert_anon"
  on public.orders for insert to anon with check (true);

-- Authenticated users (admin) can SELECT
create policy "orders_select_authenticated"
  on public.orders for select to authenticated using (true);

-- Authenticated users can DELETE (optional)
create policy "orders_delete_authenticated"
  on public.orders for delete to authenticated using (true);
