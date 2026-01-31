# Deploy on Vercel — config.js from env vars

The site needs **config.js** (Supabase URL + anon key) in the browser. That file is not in the repo (it’s in `.gitignore`). On Vercel we generate it at **build time** from environment variables.

## 1. Env vars in Vercel

In your Vercel project:

1. **Settings → Environment Variables**
2. Add these **exact** names (for Production and Preview if you use both):

| Name                | Value                                      |
|---------------------|--------------------------------------------|
| `SUPABASE_URL`      | `https://fywdsylhbtiqcxwdxnan.supabase.co` |
| `SUPABASE_ANON_KEY` | your Supabase anon key (starts with `eyJ...`) |

3. Save.

## 2. Build command

The repo is set up so that:

- **Build Command:** `npm run build` (runs `node generate-config.js`)
- **generate-config.js** reads `process.env.SUPABASE_URL` and `process.env.SUPABASE_ANON_KEY` and writes **config.js** in the project root.

So you don’t need to set the Build Command in the Vercel UI unless you override it. The default from the repo is enough if Vercel runs `npm run build`.

If your project has no Build Command set:

- In Vercel: **Settings → General → Build & Development Settings**
- Set **Build Command** to: `npm run build`
- Leave **Output Directory** empty (or `.` for root).

## 3. Redeploy

After adding or changing the env vars:

- **Deployments** → open the latest deployment → **⋯** → **Redeploy** (or push a new commit).

Redeploy is required so the build runs again and generates **config.js** with the current env vars.

## 4. Check

After deploy, open:

- `https://your-site.vercel.app/config.js`

You should see something like:

```js
window.SUPABASE_URL = "https://fywdsylhbtiqcxwdxnan.supabase.co";
window.SUPABASE_ANON_KEY = "eyJ...";
```

If that loads, the admin login and form should work.
