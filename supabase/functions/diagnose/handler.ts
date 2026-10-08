// HTTP logika funkce diagnose (FR-V1, FR-V2). Závislosti se předávají
// zvenku, takže se dá testovat bez sítě.

import { json, preflight, readJson } from "../_shared/http.ts";
import type { LlmProvider } from "../_shared/llm/types.ts";
import { type EntitlementRow, resolvePlan } from "../_shared/plan.ts";
import { costUsd, decide, limitFor, periodFor, type Pricing } from "../boda-chat/limits.ts";
import { decodeImage, hasJpegMetadata, isJpeg } from "./image.ts";
import { parseDiagnosis } from "./parse.ts";
import { buildText, NOTE_MAX, SYSTEM_PROMPT, ZONE_TYPES } from "./prompt.ts";

export interface DiagnoseDeps {
  authenticate(req: Request): Promise<{ userId: string } | null>;
  getEntitlement(userId: string): Promise<EntitlementRow | null>;
  /** Souhlas s odesláním fotek (profiles.consents.photoUpload). */
  hasPhotoConsent(userId: string): Promise<boolean>;
  reserve(userId: string, period: string, limit: number): Promise<{ allowed: boolean; used: number }>;
  settle(userId: string, period: string, costUsd: number, refund: boolean): Promise<number | null>;
  provider: LlmProvider | null;
  pricing: Pricing;
  env(name: string): string | undefined;
  now(): Date;
  log(entry: Record<string, unknown>): void;
}

/** Diagnóza stačí krátká: 3 kandidáti po pár větách. */
const MAX_TOKENS = 1500;

export async function handleDiagnose(req: Request, deps: DiagnoseDeps): Promise<Response> {
  const pre = preflight(req);
  if (pre) return pre;
  if (req.method !== "POST") return json(405, { error: "method_not_allowed" });

  const user = await deps.authenticate(req).catch(() => null);
  if (!user) return json(401, { error: "unauthorized" });

  const now = deps.now();
  const plan = resolvePlan(await deps.getEntitlement(user.userId), now);
  if (plan !== "premium") return json(402, { error: "premium_required" });
  if (!(await deps.hasPhotoConsent(user.userId))) return json(403, { error: "consent_required" });
  if (!deps.provider) return json(503, { error: "not_configured" });

  const body = await readJson(req);
  if (!body || typeof body !== "object" || Array.isArray(body)) return json(400, { error: "bad_request" });
  const b = body as Record<string, unknown>;
  const image = decodeImage(b.image);
  if (!image || !isJpeg(image)) return json(400, { error: "bad_image" });
  // Fotka s EXIF (poloha!) se nepošle dál, ani kdyby ji aplikace
  // omylem neočistila (FR-V1).
  if (hasJpegMetadata(image)) return json(400, { error: "metadata_present" });
  const zoneType = typeof b.zoneType === "string" && (ZONE_TYPES as readonly string[]).includes(b.zoneType)
    ? b.zoneType
    : null;
  const note = typeof b.note === "string" ? b.note.replace(/\s+/g, " ").trim().slice(0, NOTE_MAX) || null : null;

  // Diagnóza se počítá do stejného měsíčního limitu jako dotazy na Bóďu.
  const period = periodFor(now);
  const limit = limitFor(plan, deps.env);
  const decision = decide(plan, limit, await deps.reserve(user.userId, period, limit));
  if (!decision.allowed) return json(429, { error: "limit_reached", usage: decision.usage });

  const started = Date.now();
  let result;
  try {
    result = await deps.provider.complete({
      system: SYSTEM_PROMPT,
      messages: [{
        role: "user",
        text: buildText(zoneType, note),
        images: [{ mediaType: "image/jpeg", data: b.image as string }],
      }],
      maxTokens: MAX_TOKENS,
    });
  } catch (e) {
    const used = await deps.settle(user.userId, period, 0, true).catch(() => null);
    deps.log({
      event: "diagnose_upstream_error",
      provider: deps.provider.name,
      error: (e as Error)?.message ?? "unknown",
      status: (e as { status?: number })?.status ?? null,
      ms: Date.now() - started,
      usedAfterRefund: used,
    });
    return json(502, { error: "upstream" });
  }

  const diagnosis = result.stopReason === "refusal" ? { unclear: true, candidates: [] } : parseDiagnosis(result.text);
  const cost = costUsd(deps.pricing, result.inputTokens, result.outputTokens);
  await deps.settle(user.userId, period, cost ?? 0, false).catch(() => null);
  // Fotka ani text se nelogují (kap. 9), jen čísla.
  deps.log({
    event: "diagnose",
    userId: user.userId,
    provider: deps.provider.name,
    period,
    bytes: image.length,
    candidates: diagnosis.candidates.length,
    inputTokens: result.inputTokens,
    outputTokens: result.outputTokens,
    costUsd: cost,
    stopReason: result.stopReason,
    ms: Date.now() - started,
  });
  return json(200, { ...diagnosis, usage: decision.usage });
}
