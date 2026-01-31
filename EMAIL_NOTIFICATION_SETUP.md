# إعداد إشعار البريد عند كل طلب جديد

لتستلم بريداً على **layalidreams.tn@gmail.com** عند كل طلب ناجح، اتبع الخطوات التالية بالترتيب.

---

## الخطوة 1: إنشاء مفتاح Resend

1. ادخل إلى [resend.com](https://resend.com) وسجّل دخولك (أو أنشئ حساباً).
2. من القائمة: **API Keys → Create API Key**.
3. اختر اسم المفتاح (مثلاً "Layali") ثم انسخ المفتاح (يبدأ بـ `re_`).
4. احفظه؛ ستضعه في الخطوة 3.

---

## الخطوة 2: نشر الدالة (Edge Function) في Supabase

من **مجلد المشروع** (حيث يوجد مجلد `supabase`) في الطرفية:

```bash
npx supabase login
npx supabase link --project-ref fywdsylhbtiqcxwdxnan
npx supabase functions deploy send-order-email
```

إذا ظهر خطأ أن المشروع مربوط مسبقاً، استخدم:

```bash
npx supabase link --project-ref fywdsylhbtiqcxwdxnan
npx supabase functions deploy send-order-email
```

---

## الخطوة 3: ضبط أسرار الدالة (Secrets)

في نفس الطرفية:

```bash
npx supabase secrets set RESEND_API_KEY=re_XXXXXXXX
npx supabase secrets set NOTIFY_EMAIL=layalidreams.tn@gmail.com
```

استبدل `re_XXXXXXXX` بمفتاح Resend الذي نسخته في الخطوة 1.

---

## الخطوة 4: إنشاء Webhook في قاعدة البيانات (مهم)

هذا يجعل Supabase **يستدعي الدالة تلقائياً** عند كل إدراج في جدول `orders` (بعد نجاح الطلب)، فلا تحتاج المتصفح لاستدعاء الدالة (وتجنب مشاكل CORS).

1. ادخل إلى [Supabase Dashboard](https://supabase.com/dashboard) وافتح مشروعك.
2. من القائمة اليسرى: **Database → Webhooks**.
3. اضغط **Create a new hook**.
4. املأ الحقول:
   - **Name:** `send-order-email` (أو أي اسم).
   - **Table:** `orders`.
   - **Events:** فعّل **Insert** فقط.
   - **Type:** HTTP Request.
   - **Method:** POST.
   - **URL:**  
     `https://fywdsylhbtiqcxwdxnan.supabase.co/functions/v1/send-order-email`
   - **HTTP Headers:** اضغط **Add header**:
     - **Name:** `Authorization`
     - **Value:** `Bearer YOUR_SERVICE_ROLE_KEY`
     
     استبدل `YOUR_SERVICE_ROLE_KEY` بالمفتاح من **Project Settings → API → service_role (secret)**.
5. احفظ الـ Webhook.

بعد ذلك، عند كل طلب جديد يُدرج في `orders`، Supabase يرسل طلب POST إلى الدالة مع السطر الجديد، والدالة ترسل البريد إلى layalidreams.tn@gmail.com.

---

## التحقق

1. أرسل طلباً تجريبياً من صفحة المنتج.
2. تأكد أن الطلب يظهر في لوحة التحكم (جدول الطلبات).
3. تحقق من صندوق الوارد (والسخام) لـ **layalidreams.tn@gmail.com** — يجب أن يصل بريد بعنوان مثل: **طلب جديد — [الاسم] (ليالي)**.

إذا لم يصل البريد:

- راجع **Edge Function logs** في Supabase: **Edge Functions → send-order-email → Logs**.
- تأكد أن `RESEND_API_KEY` و `NOTIFY_EMAIL` مضبوطان (الخطوة 3).
- تأكد أن الـ Webhook مضبوط على جدول `orders` وحدث **Insert** والرابط والـ Authorization صحيحان (الخطوة 4).
