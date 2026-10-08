// HTTP logika webhooku RevenueCat (bez síťových závislostí, testovatelná).

import { json, readJson, timingSafeEqual } from "../_shared/http.ts";
import { type EntitlementChange, mapRevenueCatEvent, type RevenueCatEvent } from "./mapping.ts";

export interface WebhookDeps {
  /** Tajemství z env REVENUECAT_WEBHOOK_SECRET (undefined = nenastaveno). */
  secret: string | undefined;
  /** Zapíše nárok (RPC apply_entitlement_event); vrací výsledek z databáze. */
  apply(change: Extract<EntitlementChange, { kind: "apply" }>): Promise<string>;
  log(entry: Record<string, unknown>): void;
}

export async function handleRevenueCatWebhook(req: Request, deps: WebhookDeps): Promise<Response> {
  if (req.method !== "POST") return json(405, { error: "method_not_allowed" });
  if (!deps.secret) return json(503, { error: "not_configured" });

  const header = req.headers.get("Authorization") ?? "";
  if (!timingSafeEqual(header.trim(), `Bearer ${deps.secret}`)) {
    return json(401, { error: "unauthorized" });
  }

  const body = await readJson(req);
  if (!body || typeof body !== "object") return json(400, { error: "bad_request" });
  const event = (body as { event?: RevenueCatEvent }).event;

  const change = mapRevenueCatEvent(event);
  if (change.kind === "ignore") {
    deps.log({ event: "revenuecat_ignored", type: event?.type ?? null, reason: change.reason });
    // 200, aby RevenueCat událost neposílal znovu.
    return json(200, { ok: true, ignored: change.reason });
  }

  const result = await deps.apply(change);
  deps.log({
    event: "revenuecat_applied",
    type: event?.type ?? null,
    userId: change.userId,
    plan: change.plan,
    validUntil: change.validUntil,
    source: change.source,
    environment: event?.environment ?? null,
    result,
  });
  return json(200, { ok: true, result });
}
