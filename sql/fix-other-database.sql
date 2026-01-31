-- =============================================================================
-- FIX: Run this in the Supabase project where you ran the schema by mistake.
--
-- Steps:
--   1. Open that project in Supabase Dashboard.
--   2. Go to SQL Editor → New query.
--   3. Paste this entire file and click Run.
--
-- This script:
--   - Does NOT drop or recreate the table (your data stays).
--   - Adds image_urls column if it doesn't exist.
--   - Creates submit_order(..., p_image_urls) so the product form works.
--   - Grants execute to anon and authenticated.
--
-- After running: Use this project's SUPABASE_URL and SUPABASE_ANON_KEY in your
-- site (config.js or Vercel env) so the form submits to this database.
-- =============================================================================

-- 1) Ensure image_urls column exists
alter table public.orders add column if not exists image_urls jsonb default '[]';
comment on column public.orders.image_urls is 'Array of uploaded image URLs from the form';

-- 2) submit_order: only image_urls (works even if hero_image_url/subhero_image_url columns don't exist)
create or replace function public.submit_order(
  p_customer_name text,
  p_customer_phone text,
  p_customer_address text default null,
  p_notes text default null,
  p_variant_option text default null,
  p_variant_price numeric default null,
  p_delivery_price numeric default 7,
  p_total_price numeric default null,
  p_image_urls jsonb default '[]'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_id uuid;
begin
  insert into public.orders (
    customer_name,
    customer_phone,
    customer_address,
    notes,
    variant_option,
    variant_price,
    delivery_price,
    total_price,
    image_urls
  ) values (
    p_customer_name,
    p_customer_phone,
    p_customer_address,
    p_notes,
    p_variant_option,
    p_variant_price,
    p_delivery_price,
    p_total_price,
    coalesce(p_image_urls, '[]'::jsonb)
  )
  returning id into new_id;
  return new_id;
end;
$$;

-- 3) Allow form (anon) and admin (authenticated) to call the function
grant execute on function public.submit_order(text, text, text, text, text, numeric, numeric, numeric, jsonb) to anon;
grant execute on function public.submit_order(text, text, text, text, text, numeric, numeric, numeric, jsonb) to authenticated;
