# Yogorise Blog — Supabase Setup

You got 4 files:

- `index.html` — your site, now loading published blog posts live from Supabase
- `admin.html` — password-protected page to write/edit/publish/delete posts
- `supabase-schema.sql` — run once to create the database table
- `supabase-config.js` — where you put your Supabase project keys (shared by the other two)

Keep all four files in the same folder — `index.html` and `admin.html` both load `supabase-config.js`.

## 1. Create a Supabase project
Go to [supabase.com](https://supabase.com) → New project (free tier is fine).

## 2. Run the schema
In your project: **SQL Editor → New query** → paste the entire contents of `supabase-schema.sql` → **Run**.
This creates the `blog_posts` table, locks it down with Row Level Security (public can only read *published* posts; only logged-in users can write), and seeds it with the 4 sample articles already on your site.

## 3. Get your API keys
**Project Settings → API**, copy:
- **Project URL**
- **anon public** key

Paste both into `supabase-config.js`:

```js
const SUPABASE_URL = 'https://xxxxxxxx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOi...';
```

The anon key is safe to expose in frontend code — it can only do what the RLS policies allow.

## 4. Create your admin login
**Authentication → Users → Add user** — create yourself an email + password.
Leave **"Enable email signups"** off in Auth settings, since `admin.html` only has a login form (no signup form) on purpose — only accounts you create manually can get in.

## 5. Use it
- Open `admin.html`, log in, write a post, check **Published**, save.
- Open `index.html` — it appears in the blog section automatically.
- Check **Featured** on one post to put it in the big hero slot; otherwise the newest published post is used.

## Notes
- The **Content** field takes HTML (e.g. `<p>...</p><h3>...</h3>`) — it's inserted directly into the article modal, same as the site's original hardcoded articles.
- Drafts (unpublished) never appear on the public site, only in the admin list.
- To host this for real, upload all 4 files to any static host (Netlify, Vercel, Cloudflare Pages, GitHub Pages) — no backend/server needed, Supabase handles the database directly from the browser.
