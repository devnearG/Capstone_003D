/** Runtime configuration. All values are build-time env (Vite `import.meta.env`). */
export const API_URL: string =
  (import.meta.env.VITE_API_URL as string | undefined)?.replace(/\/$/, '') ??
  'http://localhost:8000/api/v1';

export const IS_DEV: boolean = import.meta.env.DEV;

export const SUPABASE_URL: string | undefined =
  (import.meta.env.VITE_SUPABASE_URL as string | undefined)?.replace(/\/$/, '');

export const SUPABASE_PUBLISHABLE_KEY: string | undefined =
  import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY as string | undefined;

export const SUPABASE_AUTH_ENABLED: boolean =
  !!SUPABASE_URL &&
  !!SUPABASE_PUBLISHABLE_KEY &&
  !SUPABASE_PUBLISHABLE_KEY.includes('xxx');
