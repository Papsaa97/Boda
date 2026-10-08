// HTTP logika funkce boda-chat. Závislosti (ověření uživatele, databáze,
// poskytovatel LLM) se předávají zvenku, takže se dá testovat bez sítě.

import { json, preflight, readJson } from "../_shared/http.ts";
import type { LlmProvider } from "../_shared/llm/types.ts";
import { type BodaContext, cleanText, sanitizeContext, zoneIds } from "./context.ts";
import {
  costUsd,
  decide,
  type EntitlementRow,
  limitFor,
  periodFor,
  type Pricing,
  resolvePlan,
  todayFor,
} from "./limits.ts";
import { FALLBACK_ANSWER, parseModelOutput } from "./parse.ts";
import {
  buildMessages,
  HISTORY_LIMIT,
  HISTORY_TEXT_MAX,
  type HistoryEntry,
  QUESTION_MAX,
  SYSTEM_PROMPT,
} from "./prompt.ts";

export interface BodaDeps {
  authenticate(req: Request): Promise<{ userId: string } | null>;
  getEntitlement(userId: string): Promise<EntitlementRow | null>;
  reserve(userId: string, period: string, limit: number): Promise<{ allowed: boolean; used: number }>;
  settle(userId: string, period: string, costUsd: number, refund: boolean): Promise<number | null>;
  provider: LlmProvider | null;
  pricing: Pricing;
  maxTokens: number;
  env(name: string): string | undefined;
  now(): Date;
  log(entry: Record<string, unknown>): void;
}

export interface BodaRequest {
  question: string;
  context: BodaContext;
  history: HistoryEntry[];
}

/** Ověří a vyčistí tělo požadavku; při chybě vrátí null. */
export function parseRequest(body: unknown): BodaRequest | null {
  if (!body || typeof body !== "object" || Array.isArray(body)) return null;
  const b = body as Record<string, unknown>;
  if (typeof b.question !== "string") return null;
  const question = b.question.trim();
  if (!question || question.length > QUESTION_MAX) return null;

  const history: HistoryEntry[] = [];
  if (Array.isArray(b.history)) {
    for (const h of b.history.slice(-HISTORY_LIMIT)) {
      if (!h || typeof h !== "object") continue;
      const role = (h as Record<string, unknown>).role;
      const text = cleanText((h as Record<string, unknown>).text, HISTORY_TEXT_MAX);
      if ((role === "user" || role === "assistant") && text) history.push({ role, text });
    }
  } else if (b.history !== undefined && b.history !== null) {
    return null;
  }

  return { question, context: sanitizeContext(b.context), history };
}

export async function handleBodaChat(req: Request, deps: BodaDeps): Promise<Response> {
  const pre = preflight(req);
  if (pre) return pre;
  if (req.method !== "POST") return json(405, { error: "method_not_allowed" });

  const user = await deps.authenticate(req).catch(() => null);
  if (!user) return json(401, { error: "unauthorized" });

  if (!deps.provider) return json(503, { error: "not_configured" });

  const parsed = parseRequest(await readJson(req));
  if (!parsed) return json(400, { error: "bad_request" });

  const now = deps.now();
  const period = periodFor(now);
  const plan = resolvePlan(await deps.getEntitlement(user.userId), now);
  const limit = limitFor(plan, deps.env);
  const decision = decide(plan, limit, await deps.reserve(user.userId, period, limit));
  if (!decision.allowed) {
    return json(429, { error: "limit_reached", usage: decision.usage });
  }

  const started = Date.now();
  const messages = buildMessages(parsed.question, parsed.context, parsed.history, todayFor(now));
  let result;
  try {
    result = await deps.provider.complete({ system: SYSTEM_PROMPT, messages, maxTokens: deps.maxTokens });
  } catch (e) {
    // Dotaz se nezapočítá, když poskytovatel selže.
    const used = await deps.settle(user.userId, period, 0, true).catch(() => null);
    deps.log({
      event: "boda_chat_upstream_error",
      provider: deps.provider.name,
      error: (e as Error)?.message ?? "unknown",
      status: (e as { status?: number })?.status ?? null,
      period,
      ms: Date.now() - started,
      usedAfterRefund: used,
    });
    return json(502, { error: "upstream" });
  }

  const answer = result.stopReason === "refusal"
    ? { answer: FALLBACK_ANSWER, actions: [] }
    : parseModelOutput(result.text, zoneIds(parsed.context));
  const cost = costUsd(deps.pricing, result.inputTokens, result.outputTokens);
  await deps.settle(user.userId, period, cost ?? 0, false).catch(() => null);

  deps.log({
    event: "boda_chat",
    userId: user.userId,
    provider: deps.provider.name,
    period,
    plan,
    used: decision.usage.used,
    limit,
    inputTokens: result.inputTokens,
    outputTokens: result.outputTokens,
    costUsd: cost,
    stopReason: result.stopReason,
    actions: answer.actions.length,
    ms: Date.now() - started,
  });

  return json(200, { answer: answer.answer, actions: answer.actions, usage: decision.usage });
}
