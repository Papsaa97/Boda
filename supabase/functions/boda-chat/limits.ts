// Limity dotazů na Bóďu (spec 11.2): Free 10 za kalendářní měsíc,
// Premium fair-use 300. Období se počítá v čase Europe/Prague.

export type Plan = "free" | "premium";

export const DEFAULT_LIMITS: Record<Plan, number> = { free: 10, premium: 300 };

export const PERIOD_TIME_ZONE = "Europe/Prague";

export interface EntitlementRow {
  plan?: string | null;
  valid_until?: string | null;
}

/** Platný tarif podle řádku entitlements (premium s prošlou platností = free). */
export function resolvePlan(row: EntitlementRow | null | undefined, now: Date): Plan {
  if (row?.plan !== "premium") return "free";
  if (!row.valid_until) return "premium";
  const until = new Date(row.valid_until);
  return !Number.isNaN(until.getTime()) && until.getTime() > now.getTime() ? "premium" : "free";
}

/** Limit pro tarif; lze přepsat proměnnými BODA_LIMIT_FREE / BODA_LIMIT_PREMIUM. */
export function limitFor(plan: Plan, env: (name: string) => string | undefined = () => undefined): number {
  const override = env(plan === "free" ? "BODA_LIMIT_FREE" : "BODA_LIMIT_PREMIUM");
  const parsed = override !== undefined ? Number.parseInt(override, 10) : Number.NaN;
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : DEFAULT_LIMITS[plan];
}

function partsIn(now: Date, timeZone: string): Record<string, string> {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(now);
  return Object.fromEntries(parts.map((p) => [p.type, p.value]));
}

/** Období 'YYYY-MM' (kalendářní měsíc v Europe/Prague). */
export function periodFor(now: Date, timeZone = PERIOD_TIME_ZONE): string {
  const p = partsIn(now, timeZone);
  return `${p.year}-${p.month}`;
}

/** Dnešní datum 'YYYY-MM-DD' v Europe/Prague. */
export function todayFor(now: Date, timeZone = PERIOD_TIME_ZONE): string {
  const p = partsIn(now, timeZone);
  return `${p.year}-${p.month}-${p.day}`;
}

export interface UsageDecision {
  allowed: boolean;
  usage: { used: number; limit: number; plan: Plan };
}

/**
 * Rozhodnutí o limitu z výsledku atomické rezervace v databázi
 * (assistant_usage_reserve): allowed + počet po rezervaci.
 */
export function decide(plan: Plan, limit: number, reserved: { allowed: boolean; used: number }): UsageDecision {
  const used = Math.max(0, Math.trunc(Number(reserved.used) || 0));
  return { allowed: reserved.allowed === true && used <= limit, usage: { used, limit, plan } };
}

export interface Pricing {
  inputUsdPerMTok: number | null;
  outputUsdPerMTok: number | null;
}

/** Ceník z env LLM_PRICE_INPUT_USD_PER_MTOK / LLM_PRICE_OUTPUT_USD_PER_MTOK. */
export function pricingFromEnv(env: (name: string) => string | undefined): Pricing {
  const read = (name: string) => {
    const v = env(name);
    const n = v !== undefined ? Number(v) : Number.NaN;
    return Number.isFinite(n) && n >= 0 ? n : null;
  };
  return {
    inputUsdPerMTok: read("LLM_PRICE_INPUT_USD_PER_MTOK"),
    outputUsdPerMTok: read("LLM_PRICE_OUTPUT_USD_PER_MTOK"),
  };
}

/** Náklad dotazu v USD; null, když ceník není nastavený. */
export function costUsd(pricing: Pricing, inputTokens: number, outputTokens: number): number | null {
  if (pricing.inputUsdPerMTok === null || pricing.outputUsdPerMTok === null) return null;
  const cost = (inputTokens * pricing.inputUsdPerMTok + outputTokens * pricing.outputUsdPerMTok) / 1_000_000;
  return Math.round(cost * 1e6) / 1e6;
}
