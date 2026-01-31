-- submit_order with multiple images (image_urls jsonb)
-- Run after adding image_urls column (see add-image-urls-column.sql or schema.sql).
-- First two URLs in the array are also stored as hero_image_url and subhero_image_url for backward compat.

alter table public.orders add column if not exists image_urls jsonb default '[]';
comment on column public.orders.image_urls is 'Array of uploaded image URLs from the form';

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
  hero_url text;
  subhero_url text;
begin
  hero_url := nullif(trim(p_image_urls->>0), '');
  subhero_url := nullif(trim(p_image_urls->>1), '');
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
    subhero_image_url,
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
    hero_url,
    subhero_url,
    coalesce(p_image_urls, '[]'::jsonb)
  )
  returning id into new_id;
  return new_id;
end;
$$;

grant execute on function public.submit_order(text, text, text, text, text, numeric, numeric, numeric, jsonb) to anon;
grant execute on function public.submit_order(text, text, text, text, text, numeric, numeric, numeric, jsonb) to authenticated;
 ad