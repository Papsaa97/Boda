// Převod události RevenueCat na nárok v tabulce entitlements (čistá funkce).
// app_user_id v RevenueCat = id uživatele v Supabase (auth.users.id).

export type EntitlementSource = "play" | "appstore" | "promo";

export interface RevenueCatEvent {
  id?: string;
  type?: string;
  app_user_id?: string;
  original_app_user_id?: string;
  aliases?: string[];
  expiration_at_ms?: number | null;
  event_timestamp_ms?: number | null;
  store?: string;
  environment?: string;
}

export type EntitlementChange =
  | {
    kind: "apply";
    userId: string;
    plan: "free" | "premium";
    validUntil: string | null;
    source: EntitlementSource | null;
    eventId: string | null;
    eventAt: string | null;
  }
  | { kind: "ignore"; reason: string };

/** Události, které (obnoví) Premium do expiration_at_ms (null = bez konce). */
export const PREMIUM_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "PRODUCT_CHANGE",
  "UNCANCELLATION",
  "NON_RENEWING_PURCHASE",
  "SUBSCRIPTION_EXTENDED",
  // Zrušené předplatné platí do konce zaplaceného období (valid_until).
  "CANCELLATION",
]);

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function mapStore(store: string | undefined): EntitlementSource | null {
  switch (store) {
    case "PLAY_STORE":
      return "play";
    case "APP_STORE":
    case "MAC_APP_STORE":
      return "appstore";
    case "PROMOTIONAL":
      return "promo";
    default:
      return null;
  }
}

/** Id uživatele Supabase: app_user_id, jinak original_app_user_id nebo alias, který je UUID. */
export function resolveUserId(event: RevenueCatEvent): string | null {
  const candidates = [event.app_user_id, event.original_app_user_id, ...(event.aliases ?? [])];
  for (const c of candidates) {
    if (typeof c === "string" && UUID_RE.test(c)) return c.toLowerCase();
  }
  return null;
}

function msToIso(ms: unknown): string | null {
  if (typeof ms !== "number" || !Number.isFinite(ms) || ms <= 0) return null;
  return new Date(ms).toISOString();
}

export function mapRevenueCatEvent(event: RevenueCatEvent | null | undefined): EntitlementChange {
  if (!event || typeof event !== "object") return { kind: "ignore", reason: "missing_event" };
  const type = typeof event.type === "string" ? event.type : "";
  if (!type) return { kind: "ignore", reason: "missing_type" };

  const isPremium = PREMIUM_EVENTS.has(type);
  if (!isPremium && type !== "EXPIRATION") {
    // TEST, BILLING_ISSUE, SUBSCRIPTION_PAUSED, TRANSFER, … stav nemění.
    return { kind: "ignore", reason: `unhandled_type:${type}` };
  }

  const userId = resolveUserId(event);
  if (!userId) return { kind: "ignore", reason: "no_supabase_user_id" };

  return {
    kind: "apply",
    userId,
    plan: isPremium ? "premium" : "free",
    validUntil: msToIso(event.expiration_at_ms),
    source: mapStore(event.store),
    eventId: typeof event.id === "string" && event.id ? event.id : null,
    eventAt: msToIso(event.event_timestamp_ms),
  };
}
