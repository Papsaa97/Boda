// Klienti Supabase pro Edge Functions. Klíče jen z Deno.env (Supabase je
// do funkcí vkládá sám); servisní klíč nikdy neopouští backend.

import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";
import { bearerToken } from "./http.ts";

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing environment variable ${name}`);
  return value;
}

/** Klient se servisní rolí (obchází RLS). Jen pro backendové operace. */
export function createServiceClient(): SupabaseClient {
  return createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_SERVICE_ROLE_KEY"), {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

export interface AuthUser {
  userId: string;
}

/**
 * Ověří přihlášeného uživatele podle JWT z hlavičky Authorization
 * (dotazem na Supabase Auth). Vrací null, když token chybí nebo neplatí.
 */
export async function authenticateRequest(req: Request): Promise<AuthUser | null> {
  const token = bearerToken(req);
  if (!token) return null;
  const client = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { headers: { Authorization: `Bearer ${token}` } },
  });
  const { data, error } = await client.auth.getUser(token);
  if (error || !data?.user?.id) return null;
  // Anonymní relace (pokud by se někdy zapnuly) nemají k backendu přístup.
  if ((data.user as { is_anonymous?: boolean }).is_anonymous) return null;
  return { userId: data.user.id };
}
