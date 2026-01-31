-- Layali Dreams: orders table and RLS
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor → New query)

-- Table: form submissions (orders)
create table if not exists public.orders (
  id uuid default gen_random_uuid() primary key,
  created_at timestamptz default now() not null,
  customer_name text not null,
  customer_phone text not null,
  customer_address text,
  notes text,
  variant_option text,
  variant_price numeric,
  delivery_price numeric default 7,
  total_price numeric,
  hero_image_url text,
  subhero_image_url text,
  image_urls jsonb default '[]'
);

comment on table public.orders is 'Order form submissions from product page';

-- RLS: enable and set policies
alter table public.orders enable row level security;

-- Remove any existing policies to avoid conflicts
drop policy if exists "Allow anonymous insert" on public.orders;
drop policy if exists "Allow authenticated read" on public.orders;
drop policy if exists "Allow authenticated delete" on public.orders;
drop policy if exists "orders_insert_anon" on public.orders;
drop policy if exists "orders_select_authenticated" on public.orders;
drop policy if exists "orders_delete_authenticated" on public.orders;

-- Allow anyone using the anon key (form submission) to INSERT
create policy "orders_insert_anon"
  on public.orders
  for insert
  to anon
  with check (true);

-- Allow only logged-in users (admin) to SELECT
create policy "orders_select_authenticated"
  on public.orders
  for select
  to authenticated
  using (true);

-- Allow only logged-in users to DELETE (optional)
create policy "orders_delete_authenticated"
  on public.orders
  for delete
  to authenticated
  using (true);

-- Index for dashboard listing (newest first)
create index if not exists orders_created_at_idx on public.orders (created_at desc);

-- Optional: function so form can submit even if RLS blocks anon insert (run submit-order-function.sql)
