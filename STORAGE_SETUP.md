# Create the bucket for all images imported by users

All images that users upload in the form (صور الشخصيات — for creating characters in their story) are stored in one Supabase Storage bucket. Follow these steps to create it and allow uploads.

---

## 1. Create the bucket

1. Open your project in **Supabase Dashboard**: [supabase.com/dashboard](https://supabase.com/dashboard).
2. In the left sidebar click **Storage**.
3. Click **New bucket**.
4. Set:
   - **Name:** `order-images`  
     (must be exactly this — the form uploads to this bucket)
   - **Public bucket:** **ON**  
     (so you can open image URLs in the admin dashboard and in emails)
5. Click **Create bucket**.

---

## 2. Allow users to upload (anon policy)

The form runs in the browser without login, so the bucket must allow **anonymous (anon)** uploads.

### Option A — Using the Dashboard

1. In **Storage**, click the bucket **order-images**.
2. Open the **Policies** tab (or **New policy**).
3. Click **New policy** → **For full customization** (or similar).
4. Set:
   - **Policy name:** `Allow anon upload`
   - **Allowed operation:** **INSERT** (upload)
   - **Target roles:** `anon`
   - **WITH CHECK expression:** `true`
5. Save the policy.

### Option B — Using SQL (recommended: fixes "new row violates row-level security policy")

1. In Supabase go to **SQL Editor** → **New query**.
2. Open the file **`sql/fix-storage-rls.sql`** in your project, copy its full contents, paste into the SQL Editor, and run it.

   That script adds:
   - **INSERT** policy for `anon` on bucket `order-images` (so the form can upload).
   - **SELECT** policy for `public` on bucket `order-images` (so image URLs load and don’t return 400).

3. If you prefer to run only the upload policy:

```sql
create policy "Allow anon upload"
on storage.objects for insert to anon
with check (bucket_id = 'order-images');
```

---

## 3. Result

- Every image a user selects in **صور الشخصيات** is uploaded to the bucket **order-images**.
- Each file is stored with a unique path (timestamp + index + random string).
- The public URLs of these files are saved in the order (in `orders.image_urls`) so you can see them in the admin dashboard and use them to create the characters in the story.

---

## 4. Database (if not done yet)

1. Run **`sql/add-image-urls-column.sql`** (adds `image_urls` column if missing).
2. Run **`sql/submit-order-with-images.sql`** (or **`sql/fix-other-database.sql`**) so `submit_order` accepts `p_image_urls`.

New orders will store all uploaded image URLs in `orders.image_urls`.
