// Edge Function boda-chat: dotaz na asistenta Bóďu (spec 5.2).
// POST, vyžaduje přihlášení. Kontrakt viz supabase/README.md.

import { json } from "../_shared/http.ts";
import { createLlmProvider } from "../_shared/llm/index.ts";
import { authenticateRequest, createServiceClient } from "../_shared/supabase.ts";
import { handleBodaChat } from "./handler.ts";
import { pricingFromEnv } from "./limits.ts";

const env = (name: string) => Deno.env.get(name);

/** Výchozí strop výstupních tokenů (odpověď + případné uvažování modelu). */
const DEFAULT_MAX_TOKENS = 8000;

Deno.serve(async (req) => {
  try {
    const service = createServiceClient();
    const maxTokens = Number.parseInt(env("LLM_MAX_TOKENS") ?? "", 10);

    return await handleBodaChat(req, {
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
      async reserve(userId, period, limit) {
        const { data, error } = await service.rpc("assistant_usage_reserve", {
          p_user_id: userId,
          p_period: period,
          p_limit: limit,
        });
        if (error) throw error;
        const row = Array.isArray(data) ? data[0] : data;
        return { allowed: row?.allowed === true, used: Number(row?.used ?? 0) };
      },
      async settle(userId, period, cost, refund) {
        const { data, error } = await service.rpc("assistant_usage_settle", {
          p_user_id: userId,
          p_period: period,
          p_cost_usd: cost,
          p_refund: refund,
        });
        if (error) throw error;
        return typeof data === "number" ? data : null;
      },
      provider: createLlmProvider(env),
      pricing: pricingFromEnv(env),
      maxTokens: Number.isFinite(maxTokens) && maxTokens > 0 ? maxTokens : DEFAULT_MAX_TOKENS,
      env,
      now: () => new Date(),
      log: (entry) => console.log(JSON.stringify(entry)),
    });
  } catch (e) {
    console.error(JSON.stringify({ event: "boda_chat_error", error: (e as Error)?.message ?? "unknown" }));
    return json(500, { error: "internal" });
  }
});
