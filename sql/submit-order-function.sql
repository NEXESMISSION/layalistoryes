-- Run this in Supabase SQL Editor to allow form submissions even when RLS blocks anon insert.
-- This creates a function that inserts into orders with SECURITY DEFINER (runs as owner, bypasses RLS).

create or replace function public.submit_order(
  p_customer_name text,
  p_customer_phone text,
  p_customer_address text default null,
  p_notes text default null,
  p_variant_option text default null,
  p_variant_price numeric default null,
  p_delivery_price numeric default 7,
  p_total_price numeric default null
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
    total_price
  ) values (
    p_customer_name,
    p_customer_phone,
    p_customer_address,
    p_notes,
    p_variant_option,
    p_variant_price,
    p_delivery_price,
    p_total_price
  )
  returning id into new_id;
  return new_id;
end;
$$;

-- Allow anon (form) and authenticated to call the function
grant execute on function public.submit_order(text, text, text, text, text, numeric, numeric, numeric) to anon;
grant execute on function public.submit_order(text, text, text, text, text, numeric, numeric, numeric) to authenticated;
