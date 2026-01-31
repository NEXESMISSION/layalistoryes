// Supabase Edge Function: send email to admin when a new order is submitted.
// Trigger: Database Webhook on public.orders INSERT (Supabase Dashboard → Database → Webhooks).
// Or call from client after insert: fetch(SUPABASE_FUNCTION_URL, { method: 'POST', body: JSON.stringify(order) }).
// Requires: RESEND_API_KEY and NOTIFY_EMAIL in Supabase Edge Function secrets.

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const RESEND_API = 'https://api.resend.com/emails';
const NOTIFY_EMAIL = Deno.env.get('NOTIFY_EMAIL') || 'layalidreams.tn@gmail.com';

interface OrderPayload {
  id?: string;
  customer_name: string;
  customer_phone: string;
  customer_address?: string;
  notes?: string;
  variant_option?: string;
  variant_price?: number;
  delivery_price?: number;
  total_price?: number;
  created_at?: string;
}

function buildEmailBody(order: OrderPayload): string {
  return `
طلب جديد — ليالي

الاسم: ${order.customer_name}
الهاتف: ${order.customer_phone}
العنوان: ${order.customer_address || '—'}

نوع المنتج: ${order.variant_option || '—'}
سعر المنتج: ${order.variant_price != null ? order.variant_price + ' TND' : '—'}
التوصيل: ${order.delivery_price != null ? order.delivery_price + ' د.ت' : '—'}
المجموع: ${order.total_price != null ? order.total_price + ' د.ت' : '—'}

ملاحظات:
${order.notes || '—'}

التاريخ: ${order.created_at || new Date().toISOString()}
  `.trim();
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: { 'Access-Control-Allow-Origin': '*' } });
  }
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 });
  }

  const apiKey = Deno.env.get('RESEND_API_KEY');
  if (!apiKey) {
    console.error('RESEND_API_KEY not set');
    return new Response(JSON.stringify({ error: 'Email not configured' }), { status: 500 });
  }

  let order: OrderPayload;
  try {
    const body = await req.json();
    // Supabase Database Webhook sends { type: 'INSERT', table: 'orders', record: { ... } }
    order = body.record || body;
    if (!order) order = body;
  } catch {
    return new Response(JSON.stringify({ error: 'Invalid JSON' }), { status: 400 });
  }

  if (!order || !order.customer_name || !order.customer_phone) {
    return new Response(JSON.stringify({ error: 'Missing customer_name or customer_phone' }), { status: 400 });
  }

  const emailBody = buildEmailBody(order);
  const res = await fetch(RESEND_API, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      from: 'Layali Orders <onboarding@resend.dev>',
      to: [NOTIFY_EMAIL],
      subject: `طلب جديد — ${order.customer_name} (ليالي)`,
      text: emailBody,
    }),
  });

  if (!res.ok) {
    const err = await res.text();
    console.error('Resend error:', err);
    return new Response(JSON.stringify({ error: 'Failed to send email' }), { status: 500 });
  }

  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
  });
});
