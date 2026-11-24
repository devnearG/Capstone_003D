import { createClient } from '@supabase/supabase-js';
import { SUPABASE_AUTH_ENABLED, SUPABASE_PUBLISHABLE_KEY, SUPABASE_URL } from '@/config';

export const supabase = SUPABASE_AUTH_ENABLED
  ? createClient(SUPABASE_URL!, SUPABASE_PUBLISHABLE_KEY!, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
      },
    })
  : null;
