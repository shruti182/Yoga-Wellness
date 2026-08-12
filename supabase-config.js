// ============================================================
// Supabase connection — fill these in with your project's values
// Find them in: Supabase Dashboard → Project Settings → API
// ============================================================
const SUPABASE_URL = 'https://zvnrwpnubluyzdxdwjan.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_Fr_-RSSQNaJnryLA_SuWyg_4qmsvNbX';

// Shared client used by index.html (public reads) and admin.html (login + writes).
// This uses the "anon" key, which is safe to expose in frontend code —
// it's restricted by the Row Level Security policies set up in supabase-schema.sql.
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
