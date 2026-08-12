-- ============================================================
-- Yogorise Blog — Supabase schema
-- Run this once in your Supabase project's SQL Editor
-- (Dashboard → SQL Editor → New query → paste → Run)
-- ============================================================

-- 1. Table
create table if not exists blog_posts (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  slug          text not null unique,
  category      text not null default 'Yoga Practice',
  read_time     text not null default '5 min read',
  cover_image   text,
  excerpt       text not null,
  content_html  text not null,          -- rich HTML body, rendered in the article modal
  published     boolean not null default false,
  featured      boolean not null default false, -- shows in the big "Today's Featured Article" slot
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- keep updated_at fresh on every edit
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_blog_posts_updated_at on blog_posts;
create trigger trg_blog_posts_updated_at
  before update on blog_posts
  for each row execute function set_updated_at();

-- helpful index for the public feed (newest published first)
create index if not exists idx_blog_posts_published
  on blog_posts (published, created_at desc);

-- 2. Row Level Security
alter table blog_posts enable row level security;

-- Anyone (anon key, i.e. your public website) can read PUBLISHED posts only.
drop policy if exists "public can read published posts" on blog_posts;
create policy "public can read published posts"
  on blog_posts for select
  to anon
  using (published = true);

-- Logged-in users (i.e. you, via the admin page) can read everything,
-- including drafts.
drop policy if exists "authenticated can read all posts" on blog_posts;
create policy "authenticated can read all posts"
  on blog_posts for select
  to authenticated
  using (true);

-- Only logged-in users can create, edit, or delete posts.
drop policy if exists "authenticated can insert posts" on blog_posts;
create policy "authenticated can insert posts"
  on blog_posts for insert
  to authenticated
  with check (true);

drop policy if exists "authenticated can update posts" on blog_posts;
create policy "authenticated can update posts"
  on blog_posts for update
  to authenticated
  using (true)
  with check (true);

drop policy if exists "authenticated can delete posts" on blog_posts;
create policy "authenticated can delete posts"
  on blog_posts for delete
  to authenticated
  using (true);

-- 3. (Optional) seed with the 4 sample posts already on the site,
-- so the blog section isn't empty on first load. Safe to delete.
insert into blog_posts (title, slug, category, read_time, cover_image, excerpt, content_html, published, featured)
values
(
  '10 Minutes of Morning Yoga to Start Your Day with Calm',
  '10-minutes-morning-yoga-calm',
  'Yoga Practice', '5 min read',
  'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=1000&q=85',
  'A gentle sequence of movement, breath, and mindfulness designed to help you wake up your body and create a calmer beginning to your day.',
  '<p class="mb-4">Begin your morning with a gentle practice that brings movement and breath together. Ten mindful minutes can be enough to create a calmer transition into the day.</p><h3 class="font-display text-xl mb-2">A simple sequence</h3><p class="mb-4">Start with a comfortable seated breath, move through gentle neck and shoulder movements, then practice Cat–Cow, Child''s Pose, a soft standing stretch, and a few slow breaths before finishing.</p><p>Move without forcing the body. Let the breath set the pace, and finish by choosing one intention for your day.</p>',
  true, true
),
(
  '5 Yoga Poses for Beginners to Practice at Home',
  '5-yoga-poses-beginners-home',
  'Beginner Yoga', '4 min read',
  'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=800&q=80',
  'A simple introduction to foundational poses and how to build a consistent home practice.',
  '<p class="mb-4">If you are new to yoga, begin with poses that help you understand alignment and breath without making the practice complicated.</p><h3 class="font-display text-xl mb-2">Five foundations</h3><p class="mb-4">Try Mountain Pose, Child''s Pose, Cat–Cow, Downward-Facing Dog, and a comfortable seated forward fold. Stay within a range that feels steady and comfortable.</p><p>Consistency matters more than intensity. A few minutes practiced regularly can help you become familiar with your body and your breath.</p>',
  true, false
),
(
  'How to Build a 10-Minute Daily Meditation Habit',
  'build-10-minute-daily-meditation-habit',
  'Mindfulness', '4 min read',
  'https://images.unsplash.com/photo-1508672019048-805c876b67e2?auto=format&fit=crop&w=800&q=80',
  'Small, sustainable steps for making mindfulness a natural part of your everyday routine.',
  '<p class="mb-4">Meditation becomes easier when the goal is simply to show up. Choose the same time each day and start with ten minutes—or less if that feels more sustainable.</p><h3 class="font-display text-xl mb-2">Make it simple</h3><p class="mb-4">Sit comfortably, soften your gaze or close your eyes, and notice the natural rhythm of your breathing. When your attention wanders, gently return to the breath.</p><p>There is no need to make the mind completely silent. The practice is noticing, returning, and beginning again.</p>',
  true, false
),
(
  'Pranayama for Beginners: Start with Your Breath',
  'pranayama-for-beginners',
  'Pranayama', '3 min read',
  'https://images.unsplash.com/photo-1474418397713-7ede21d49118?auto=format&fit=crop&w=800&q=80',
  'Understand the basics of conscious breathing and discover a gentle way to begin.',
  '<p class="mb-4">Pranayama introduces conscious attention to breathing. For beginners, the safest place to start is with relaxed, natural breathing rather than forceful techniques.</p><h3 class="font-display text-xl mb-2">A gentle beginning</h3><p class="mb-4">Sit comfortably and observe your breath for a few rounds. Then gradually make each inhale and exhale smooth and unhurried, without straining or holding the breath.</p><p>If a breathing practice causes discomfort, stop and return to normal breathing. When learning advanced techniques, seek guidance from a qualified teacher.</p>',
  true, false
)
on conflict (slug) do nothing;

-- ============================================================
-- 4. Create your admin login (do this AFTER running the above)
-- ============================================================
-- Go to Supabase Dashboard → Authentication → Users → Add user
-- Create yourself an email + password. That's what you'll log
-- into admin.html with. Do NOT use "Enable public sign-ups" —
-- the admin page only has a login form, not a signup form, on
-- purpose, so only accounts you create in the dashboard can in.
