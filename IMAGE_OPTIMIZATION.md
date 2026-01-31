# Image optimization for fast loading

The site is set up for fast loading: smaller logo, lazy loading, and smaller display sizes. To make images load **even faster**, compress the actual files.

## 1. Logo (NOBG.png)

- **Desktop:** displayed at 72px height (max-width 160px).
- **Mobile:** 56px height (max-width 140px).
- **Tip:** Export a logo at about **160×72 px** (or 2× for retina: 320×144) and compress it.
- Use [TinyPNG](https://tinypng.com) or [Squoosh](https://squoosh.app) to reduce file size without losing quality.
- Optional: provide **WebP** and use `<picture>` (see below).

## 2. Gallery / product images (imges/*.png)

- Hero/story images are shown at about **260×260 px** (hero) and **350×480 px** (gallery cards).
- Product thumbs are **80×80 px**; main product image is shown at ~600×600 px.
- **Recommendation:** Resize and compress:
  - **Hero/story:** max 520×520 px (2× for retina) is enough.
  - **Gallery:** max 700×960 px (2× for 350×480).
  - **Product thumbs:** 160×160 px is enough (2× for 80×80).
- Use TinyPNG, Squoosh, or `pngquant` to compress PNGs (often 60–80% smaller).

## 3. Optional: WebP for smaller files

WebP is usually 25–35% smaller than PNG at similar quality. You can:

1. Generate WebP versions (e.g. `NOBG.webp`, `imges/1.webp`) with [Squoosh](https://squoosh.app) or `cwebp`.
2. Use `<picture>` so modern browsers get WebP and others get PNG:

```html
<picture>
  <source srcset="NOBG.webp" type="image/webp" />
  <img src="NOBG.png" alt="Layali — ليالي" class="logo" width="160" height="72" decoding="async" />
</picture>
```

## 4. What’s already done in the project

- **Logo:** Smaller display size (72px / 56px), `width`/`height` to avoid layout shift, `decoding="async"`.
- **Hero and gallery images:** `loading="lazy"`, `decoding="async"`, and smaller CSS sizes (e.g. hero ~260–380px, gallery 350×480).
- **Product page:** Main image `fetchpriority="high"`, thumbs `loading="lazy"` and small display size.

Compressing the actual PNG files (and optionally adding WebP) will give you the biggest gain in load time.
