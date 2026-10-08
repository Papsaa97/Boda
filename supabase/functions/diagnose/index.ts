// Edge Function diagnose: možné příčiny problému z fotky (FR-V1, FR-V2).
// POST {image (JPEG v base64, bez EXIF), zoneType?, note?}, vyžaduje
// přihlášení, Premium a souhlas s odesláním fotek. Kontrakt viz
// supabase/README.md.

import { json } from "../_shared/http.ts";
import { createLlmProvider } from "../_shared/llm/index.ts";
import { authenticateRequest, createServiceClient } from "../_shared/supabase.ts";
import { pricingFromEnv } from "../boda-chat/limits.ts";
import { handleDiagnose } from "./handler.ts";

const env = (name: string) => Deno.env.get(name);

Deno.serve(async (req) => {
  try {
    const service = createServiceClient();
    return await handleDiagnose(req, {
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
      async hasPhotoConsent(userId) {
        const { data, error } = await service
          .from("profiles")
          .select("consents")
          .eq("id", userId)
          .maybeSingle();
        if (error) throw error;
        return data?.consents?.photoUpload?.granted === true;
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
      env,
      now: () => new Date(),
      log: (entry) => console.log(JSON.stringify(entry)),
    });
  } catch (e) {
    console.error(JSON.stringify({ event: "diagnose_error", error: (e as Error)?.message ?? "unknown" }));
    return json(500, { error: "internal" });
  }
});
