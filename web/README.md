# OffRoad landing page

Static site, no build step and no third-party requests (fonts are self-hosted).

```bash
python3 -m http.server 4173 --directory landing_page   # preview at http://localhost:4173
```

## Before launch

Edit `CONFIG` at the top of `main.js`:

- `appStoreUrl`, `playStoreUrl`: until set, the store buttons read "Coming soon".
- `contactEmail`: the footer Contact link is hidden until set.

Also set absolute URLs for `og:image` in `index.html` once you know the domain (social previews need an absolute URL).

## Deploy

Upload the folder as-is to any static host (Vercel, Netlify, Cloudflare Pages, GitHub Pages, S3). For Vercel: `vercel deploy landing_page`.

## Updating content

- Screenshots in `assets/screens/` come from `store_assets/raw/iphone` (resized to 660 px WebP).
- The models table mirrors `lib/features/ai/model/ai_model.dart`; update it when the catalogue changes.
