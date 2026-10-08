// Tarif uživatele podle řádku entitlements (spec 11.2); sdílí ho
// boda-chat (limity dotazů) a weather (počasí je v Premium).

export type Plan = "free" | "premium";

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
