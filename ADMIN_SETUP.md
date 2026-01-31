# لوحة التحكم والإشعارات — إعداد Supabase

## 1. إنشاء مشروع Supabase

1. ادخل إلى [supabase.com](https://supabase.com) وأنشئ مشروعاً جديداً.
2. من **Project Settings → API** انسخ:
   - **Project URL** → ستضعه في `config.js` كـ `SUPABASE_URL`
   - **anon public** key → ستضعه في `config.js` كـ `SUPABASE_ANON_KEY`
   - **service_role** key → للوظائف (Edge Functions) فقط، لا تضعها في الواجهة الأمامية.

## 2. تشغيل SQL لإنشاء الجدول

1. في Supabase: **SQL Editor → New query**
2. انسخ محتوى الملف `sql/schema.sql` والصقه في المحرر ثم نفّذ (Run).
3. نفّذ أيضاً محتوى الملف **`sql/submit-order-function.sql`** — هذا ينشئ الدالة `submit_order` التي تسمح للنموذج بإرسال الطلبات حتى لو كانت سياسات RLS تمنع الإدراج المباشر.
4. إذا ظهر خطأ "new row violates row-level security policy"، نفّذ أيضاً **`sql/fix-rls-orders.sql`** ثم أعد تشغيل **`sql/submit-order-function.sql`**.

## 3. إنشاء مستخدم أدمن (تسجيل الدخول للوحة التحكم)

1. في Supabase: **Authentication → Users → Add user → Create new user**
2. أدخل بريداً إلكترونياً وكلمة مرور (مثلاً: `admin@layalidreams.tn` وكلمة سر قوية).
3. احفظه؛ ستستخدمه لتسجيل الدخول في `/admin` (صفحة تسجيل الدخول).

## 4. ملف config.js (للموقع ولوحة التحكم)

1. انسخ الملف `config.example.js` إلى `config.js` في جذر المشروع.
2. عدّل القيم:
   - `SUPABASE_URL`: عنوان مشروعك من Supabase (Project URL).
   - `SUPABASE_ANON_KEY`: المفتاح العام anon من Supabase.
3. **لا ترفع `config.js` إلى Git** (موجود في `.gitignore`).

## 5. الإشعارات بالبريد (إرسال بريد عند كل طلب جديد)

**لتفاصيل خطوة بخطوة (نشر الدالة + Resend + Webhook)** راجع الملف **`EMAIL_NOTIFICATION_SETUP.md`**.

يتم إرسال بريد إلى **layalidreams.tn@gmail.com** عند كل طلب جديد عبر:

- **Resend** ([resend.com](https://resend.com)) لإرسال البريد.
- **Edge Function** في Supabase اسمها `send-order-email`.

### 5.1 إعداد Resend

1. أنشئ حساباً في [resend.com](https://resend.com).
2. من لوحة Resend أنشئ **API Key**.
3. (اختياري) أضف نطاقك للبريد المرسل منه، أو استخدم البريد الافتراضي للتجربة.

### 5.2 نشر الدالة (Edge Function) في Supabase

من مجلد المشروع (حيث يوجد مجلد `supabase`):

```bash
npx supabase login
npx supabase link --project-ref YOUR_PROJECT_REF
npx supabase functions deploy send-order-email
```

ثم ضبط المتغيرات السرية للدالة:

```bash
npx supabase secrets set RESEND_API_KEY=re_xxxxxxxxxxxx
npx supabase secrets set NOTIFY_EMAIL=layalidreams.tn@gmail.com
```

(استبدل `re_xxxxxxxxxxxx` بمفتاحك من Resend.)

### 5.3 (اختياري) Webhook بدل استدعاء الدالة من الواجهة

بدلاً من استدعاء الدالة من صفحة النموذج بعد الإدراج، يمكن تشغيلها تلقائياً عند إدراج سطر في `orders`:

1. في Supabase: **Database → Webhooks → Create a new hook**
2. الجدول: `public.orders`
3. الأحداث: **Insert**
4. عنوان الـ URL:  
   `https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-order-email`
5. أضف Header:  
   `Authorization: Bearer YOUR_SERVICE_ROLE_KEY`

بهذا يتم استدعاء الدالة عند كل طلب جديد وإرسال البريد إلى layalidreams.tn@gmail.com.

## 6. لوحة التحكم (Admin)

- **تسجيل الدخول:** افتح `/admin` أو `admin/index.html` وأدخل البريد وكلمة المرور التي أنشأتها في الخطوة 3.
- **عرض الطلبات:** بعد تسجيل الدخول يتم توجيهك إلى `admin/dashboard.html` حيث تظهر كل الطلبات من جدول `orders`.

## 7. ملف .env (للحماية والمتغيرات المحلية)

الملف `.env` **لا يُستخدم من المتصفح**؛ يُستخدم فقط إذا كان لديك سيرفر أو بناء (مثلاً Node).  
للـ Edge Functions تستخدم `supabase secrets` كما في الخطوة 5.2.

إذا أردت حفظ مراجعك محلياً (للتطوير فقط):

1. انسخ `.env.example` إلى `.env`.
2. املأ القيم ولا ترفع `.env` إلى Git.

---

**ملخص الملفات:**

| الملف | الغرض |
|--------|--------|
| `sql/schema.sql` | إنشاء جدول `orders` و RLS |
| `config.example.js` | نموذج لـ `config.js` (URL + anon key) |
| `.env.example` | نموذج لمتغيرات البيئة (اختياري) |
| `admin/index.html` | صفحة تسجيل الدخول |
| `admin/dashboard.html` | عرض الطلبات |
| `supabase/functions/send-order-email/index.ts` | دالة إرسال البريد عند طلب جديد |
