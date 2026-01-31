-- =============================================================================
-- submit_order: multiple images in ONE column (image_urls only)
-- Use this if your orders table does NOT have hero_image_url / subhero_image_url.
-- Run in Supabase SQL Editor.
-- =============================================================================

-- Ensure image_urls column exists
alter table public.orders add column if not exists image_urls jsonb default '[]';
comment on column public.orders.image_urls is 'All uploaded image URLs (multiple per order)';

-- submit_order: inserts only image_urls (no hero_image_url, subhero_image_url)
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

grant execute on function public.submit_order(text, text, text, text, text, numeric, numeric, numeric, jsonb) to anon;
grant execute on function public.submit_order(text, text, text, text, text, numeric, numeric, numeric, jsonb) to authenticated;
