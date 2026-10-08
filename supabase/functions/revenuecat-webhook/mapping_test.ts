import { assertEquals } from "jsr:@std/assert@1";
import { mapRevenueCatEvent, mapStore, resolveUserId } from "./mapping.ts";

const USER = "a0000000-0000-4000-8000-000000000001";
const EXP = Date.UTC(2027, 9, 8, 12, 0, 0);
const AT = Date.UTC(2026, 9, 8, 12, 0, 0);

function event(type: string, extra: Record<string, unknown> = {}) {
  return {
    id: `evt-${type}`,
    type,
    app_user_id: USER,
    expiration_at_ms: EXP,
    event_timestamp_ms: AT,
    store: "PLAY_STORE",
    environment: "PRODUCTION",
    ...extra,
  };
}

Deno.test("purchase-like events grant premium until expiration", () => {
  for (
    const type of [
      "INITIAL_PURCHASE",
      "RENEWAL",
      "PRODUCT_CHANGE",
      "UNCANCELLATION",
      "NON_RENEWING_PURCHASE",
      "SUBSCRIPTION_EXTENDED",
    ]
  ) {
    assertEquals(mapRevenueCatEvent(event(type)), {
      kind: "apply",
      userId: USER,
      plan: "premium",
      validUntil: "2027-10-08T12:00:00.000Z",
      source: "play",
      eventId: `evt-${type}`,
      eventAt: "2026-10-08T12:00:00.000Z",
    }, type);
  }
});

Deno.test("CANCELLATION keeps premium until valid_until", () => {
  const change = mapRevenueCatEvent(event("CANCELLATION", { store: "APP_STORE" }));
  assertEquals(change.kind === "apply" && [change.plan, change.validUntil, change.source], [
    "premium",
    "2027-10-08T12:00:00.000Z",
    "appstore",
  ]);
});

Deno.test("EXPIRATION switches to free", () => {
  const change = mapRevenueCatEvent(event("EXPIRATION"));
  assertEquals(change.kind === "apply" && change.plan, "free");
});

Deno.test("lifetime purchase without expiration has no valid_until", () => {
  const change = mapRevenueCatEvent(event("NON_RENEWING_PURCHASE", { expiration_at_ms: null, store: "PROMOTIONAL" }));
  assertEquals(change.kind === "apply" && [change.plan, change.validUntil, change.source], ["premium", null, "promo"]);
});

Deno.test("other events are ignored", () => {
  for (const type of ["TEST", "BILLING_ISSUE", "SUBSCRIPTION_PAUSED", "TRANSFER"]) {
    assertEquals(mapRevenueCatEvent(event(type)), { kind: "ignore", reason: `unhandled_type:${type}` });
  }
  assertEquals(mapRevenueCatEvent(undefined), { kind: "ignore", reason: "missing_event" });
  assertEquals(mapRevenueCatEvent({}), { kind: "ignore", reason: "missing_type" });
});

Deno.test("anonymous RevenueCat ids are ignored, aliases are used", () => {
  assertEquals(
    mapRevenueCatEvent(event("RENEWAL", { app_user_id: "$RCAnonymousID:abc", original_app_user_id: "x", aliases: [] })),
    { kind: "ignore", reason: "no_supabase_user_id" },
  );
  assertEquals(
    resolveUserId({ app_user_id: "$RCAnonymousID:abc", aliases: ["$RCAnonymousID:abc", USER.toUpperCase()] }),
    USER,
  );
});

Deno.test("store mapping", () => {
  assertEquals(mapStore("PLAY_STORE"), "play");
  assertEquals(mapStore("APP_STORE"), "appstore");
  assertEquals(mapStore("MAC_APP_STORE"), "appstore");
  assertEquals(mapStore("PROMOTIONAL"), "promo");
  assertEquals(mapStore("STRIPE"), null);
  assertEquals(mapStore(undefined), null);
});
