import { assertEquals } from "jsr:@std/assert@1";
import { costUsd, decide, limitFor, periodFor, pricingFromEnv, resolvePlan, todayFor } from "./limits.ts";

const now = new Date("2026-10-08T12:00:00Z");

Deno.test("resolvePlan", () => {
  assertEquals(resolvePlan(null, now), "free");
  assertEquals(resolvePlan({ plan: "free" }, now), "free");
  assertEquals(resolvePlan({ plan: "premium", valid_until: null }, now), "premium");
  assertEquals(resolvePlan({ plan: "premium", valid_until: "2026-11-01T00:00:00Z" }, now), "premium");
  assertEquals(resolvePlan({ plan: "premium", valid_until: "2026-10-01T00:00:00Z" }, now), "free");
  assertEquals(resolvePlan({ plan: "premium", valid_until: "garbage" }, now), "free");
});

Deno.test("limitFor: 10 free, 300 premium, env override", () => {
  assertEquals(limitFor("free"), 10);
  assertEquals(limitFor("premium"), 300);
  const env = (n: string) => ({ BODA_LIMIT_FREE: "3", BODA_LIMIT_PREMIUM: "abc" } as Record<string, string>)[n];
  assertEquals(limitFor("free", env), 3);
  assertEquals(limitFor("premium", env), 300);
});

Deno.test("periodFor uses the Prague calendar month", () => {
  assertEquals(periodFor(now), "2026-10");
  // 31. 10. 23:30 UTC = 1. 11. 00:30 v Praze (CET).
  assertEquals(periodFor(new Date("2026-10-31T23:30:00Z")), "2026-11");
  assertEquals(periodFor(new Date("2026-12-31T22:59:59Z")), "2026-12");
  assertEquals(periodFor(new Date("2026-12-31T23:00:00Z")), "2027-01");
  assertEquals(todayFor(new Date("2026-10-07T22:30:00Z")), "2026-10-08");
});

Deno.test("decide", () => {
  assertEquals(decide("free", 10, { allowed: true, used: 3 }), {
    allowed: true,
    usage: { used: 3, limit: 10, plan: "free" },
  });
  assertEquals(decide("free", 10, { allowed: false, used: 10 }), {
    allowed: false,
    usage: { used: 10, limit: 10, plan: "free" },
  });
  assertEquals(decide("premium", 300, { allowed: true, used: 301 }).allowed, false);
});

Deno.test("costUsd", () => {
  const env = (n: string) =>
    ({ LLM_PRICE_INPUT_USD_PER_MTOK: "2", LLM_PRICE_OUTPUT_USD_PER_MTOK: "10" } as Record<string, string>)[n];
  const pricing = pricingFromEnv(env);
  assertEquals(costUsd(pricing, 3000, 800), 0.014);
  assertEquals(costUsd(pricingFromEnv(() => undefined), 3000, 800), null);
});
