// Edge Function revenuecat-webhook: RevenueCat → tabulka entitlements.
// Ověřuje hlavičku `Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>`
// (v RevenueCat: Integrations → Webhooks → Authorization header).

import { json } from "../_shared/http.ts";
import { createServiceClient } from "../_shared/supabase.ts";
import { handleRevenueCatWebhook } from "./handler.ts";

Deno.serve(async (req) => {
  try {
    return await handleRevenueCatWebhook(req, {
      secret: Deno.env.get("REVENUECAT_WEBHOOK_SECRET") || undefined,
      async apply(change) {
        const { data, error } = await createServiceClient().rpc("apply_entitlement_event", {
          p_user_id: change.userId,
          p_plan: change.plan,
          p_valid_until: change.validUntil,
          p_source: change.source,
          p_event_id: change.eventId,
          p_event_at: change.eventAt,
        });
        if (error) throw error;
        return String(data);
      },
      log: (entry) => console.log(JSON.stringify(entry)),
    });
  } catch (e) {
    // 500 => RevenueCat událost později pošle znovu (zápis je idempotentní).
    console.error(JSON.stringify({ event: "revenuecat_error", error: (e as Error)?.message ?? "unknown" }));
    return json(500, { error: "internal" });
  }
});
