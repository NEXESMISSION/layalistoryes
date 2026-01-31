-- =============================================================================
-- Layali Dreams: Images in form (hero + subhero) + submit_order function
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor → New query)
-- Use this if you already have the orders table and want to add image fields
-- and/or update the submit_order function to save hero_image_url & subhero_image_url.
-- =============================================================================

-- 1) Add image URL columns to orders (if you created the table before images were added)
alter table public.orders
  add column if not exists hero_image_url text,
  add column if not exists subhero_image_url text;

comment on column public.orders.hero_image_url is 'URL of main/cover image (hero) from the form';
comment on column public.orders.subhero_image_url is 'URL of secondary image (subhero) from the form';

-- 2) submit_order function (includes hero_image_url and subhero_image_url)
create or replace function public.submit_order(
  p_customer_name text,
  p_customer_phone text,
  p_customer_address text default null,
  p_notes text default null,
  p_variant_option text default null,
  p_variant_price numeric default null,
  p_delivery_price numeric default 7,
  p_total_price numeric default null,
  p_hero_image_url text default null,
  p_subhero_image_url text default null
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
    hero_image_url,
    subhero_image_url
  ) values (
    p_customer_name,
    p_customer_phone,
    p_customer_address,
    p_notes,
    p_variant_option,
    p_variant_price,
    p_delivery_price,
    p_total_price,
    p_hero_image_url,
    p_subhero_image_url
  )
  returning id into new_id;
  return new_id;
end;
$$;

grant execute on function public.submit_order(text, text, text, text, text, numeric, numeric, numeric, text, text) to anon;
grant execute on function public.submit_order(text, text, text, text, text, numeric, numeric, numeric, text, text) to authenticated;
