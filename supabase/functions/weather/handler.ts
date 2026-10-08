// HTTP logika funkce weather (FR-W1). Závislosti zvenku kvůli testům.

import { json, preflight } from "../_shared/http.ts";
import { type EntitlementRow, resolvePlan } from "../_shared/plan.ts";
import { buildUrl, normalize, type ProviderConfig } from "./provider.ts";

export interface WeatherDeps {
  authenticate(req: Request): Promise<{ userId: string } | null>;
  getEntitlement(userId: string): Promise<EntitlementRow | null>;
  config: ProviderConfig | null;
  fetch(url: string): Promise<Response>;
  now(): Date;
  log(entry: Record<string, unknown>): void;
}

function coord(v: unknown, min: number, max: number): number | null {
  return typeof v === "number" && Number.isFinite(v) && v >= min && v <= max ? v : null;
}

export async function handleWeather(req: Request, deps: WeatherDeps): Promise<Response> {
  const pre = preflight(req);
  if (pre) return pre;
  if (req.method !== "POST") return json(405, { error: "method_not_allowed" });

  const user = await deps.authenticate(req).catch(() => null);
  if (!user) return json(401, { error: "unauthorized" });

  // Počasí a zálivka jsou v Premium (spec 11.2).
  const plan = resolvePlan(await deps.getEntitlement(user.userId), deps.now());
  if (plan !== "premium") return json(402, { error: "premium_required" });

  if (!deps.config) return json(503, { error: "not_configured" });

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json(400, { error: "invalid_json" });
  }
  const lat = coord(body?.lat, -90, 90);
  const lng = coord(body?.lng, -180, 180);
  if (lat === null || lng === null) return json(400, { error: "invalid_location" });

  let upstream: Response;
  try {
    upstream = await deps.fetch(buildUrl(deps.config, lat, lng));
  } catch (e) {
    deps.log({ event: "weather_upstream_error", error: (e as Error)?.message ?? "unknown" });
    return json(502, { error: "upstream" });
  }
  if (!upstream.ok) {
    deps.log({ event: "weather_upstream_status", status: upstream.status });
    return json(502, { error: "upstream" });
  }
  const payload = normalize(await upstream.json().catch(() => null));
  if (!payload) return json(502, { error: "upstream" });
  return json(200, { fetchedAt: deps.now().toISOString(), ...payload });
}
