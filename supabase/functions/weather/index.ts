// Edge Function weather: srážky za 7 dní a předpověď na 7 dní pro polohu
// zahrady (FR-W1). POST {lat, lng}, vyžaduje přihlášení a Premium.

import { json } from "../_shared/http.ts";
import { authenticateRequest, createServiceClient } from "../_shared/supabase.ts";
import { handleWeather } from "./handler.ts";
import { providerConfig } from "./provider.ts";

const env = (name: string) => Deno.env.get(name);

Deno.serve(async (req) => {
  try {
    const service = createServiceClient();
    return await handleWeather(req, {
      authenticate: authenticateRequest,
      async getEntitlement(userId) {
        const { data, error } = await service
          .from("entitlements")
          .select("plan, valid_until")
          .eq("user_id", userId)
          .maybeSingle();
        if (error) throw error;
        return data;
      },
      config: providerConfig(env),
      fetch: (url) => fetch(url, { signal: AbortSignal.timeout(10_000) }),
      now: () => new Date(),
      log: (entry) => console.log(JSON.stringify(entry)),
    });
  } catch (e) {
    console.error(JSON.stringify({ event: "weather_error", error: (e as Error)?.message ?? "unknown" }));
    return json(500, { error: "internal" });
  }
});
