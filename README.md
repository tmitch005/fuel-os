# fuel-os

Personal meal planner (static app on GitHub Pages).

## Database (Supabase)

Production is static HTML only — data must live in a hosted database. This repo uses [Supabase](https://supabase.com) (Postgres + auth, free tier).

### 1. Create Supabase project

1. [supabase.com](https://supabase.com) → New project
2. **Authentication** → **Providers** → enable **Email**
3. **SQL Editor** → paste and run [`supabase/schema.sql`](supabase/schema.sql)

### 2. Add API keys locally

```bash
cp config.example.js config.js
```

In Supabase: **Project Settings** → **API** → copy **Project URL** and **anon public** key into `config.js`.

`config.js` is gitignored; never commit service role keys.

### 3. Auth redirect URLs (required for sign-in)

In Supabase: **Authentication** → **URL configuration**, add:

- **Site URL:** `https://tmitch005.github.io/fuel-os/meal-planner.html`
- **Redirect URLs:** same URL, plus `http://localhost:8080/meal-planner.html` for local dev

### 4. Use cloud sync

Open **Settings** → enter email → **Email sign-in link**. After you click the link in your inbox, changes sync to `user_states` in Supabase (also cached in the browser).

`config.public.js` holds the anon key for GitHub Pages. Optional `config.js` (gitignored) can override it locally.

### Production URLs

- App: https://tmitch005.github.io/fuel-os/
- Repo deploys `main` via GitHub Pages automatically
