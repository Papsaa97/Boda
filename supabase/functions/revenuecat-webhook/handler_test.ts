import { assertEquals } from "jsr:@std/assert@1";
import { handleRevenueCatWebhook, type WebhookDeps } from "./handler.ts";

const SECRET = "test-secret-not-real";
const USER = "a0000000-0000-4000-8000-000000000001";

function deps(applied: unknown[] = [], opts: { secret?: string } = { secret: SECRET }): WebhookDeps {
  return {
    secret: opts.secret,
    apply: (change) => {
      applied.push(change);
      return Promise.resolve("applied");
    },
    log: () => {},
  };
}

function post(body: unknown, auth = `Bearer ${SECRET}`): Request {
  return new Request("http://localhost/revenuecat-webhook", {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: auth },
    body: typeof body === "string" ? body : JSON.stringify(body),
  });
}

const purchase = {
  api_version: "1.0",
  event: {
    id: "evt-1",
    type: "INITIAL_PURCHASE",
    app_user_id: USER,
    expiration_at_ms: Date.UTC(2027, 0, 1),
    event_timestamp_ms: Date.UTC(2026, 9, 8),
    store: "PLAY_STORE",
  },
};

Deno.test("valid purchase is applied", async () => {
  const applied: unknown[] = [];
  const res = await handleRevenueCatWebhook(post(purchase), deps(applied));
  assertEquals(res.status, 200);
  assertEquals(await res.json(), { ok: true, result: "applied" });
  assertEquals(applied, [{
    kind: "apply",
    userId: USER,
    plan: "premium",
    validUntil: "2027-01-01T00:00:00.000Z",
    source: "play",
    eventId: "evt-1",
    eventAt: "2026-10-08T00:00:00.000Z",
  }]);
});

Deno.test("wrong or missing secret is rejected", async () => {
  const applied: unknown[] = [];
  assertEquals((await handleRevenueCatWebhook(post(purchase, "Bearer nope"), deps(applied))).status, 401);
  assertEquals((await handleRevenueCatWebhook(post(purchase, SECRET), deps(applied))).status, 401);
  assertEquals((await handleRevenueCatWebhook(post(purchase, ""), deps(applied))).status, 401);
  assertEquals(applied.length, 0);
});

Deno.test("503 when the secret is not configured", async () => {
  const res = await handleRevenueCatWebhook(post(purchase), deps([], {}));
  assertEquals(res.status, 503);
  assertEquals(await res.json(), { error: "not_configured" });
});

Deno.test("ignored events return 200", async () => {
  const applied: unknown[] = [];
  const res = await handleRevenueCatWebhook(post({ event: { type: "TEST", app_user_id: USER } }), deps(applied));
  assertEquals(res.status, 200);
  assertEquals(await res.json(), { ok: true, ignored: "unhandled_type:TEST" });
  assertEquals(applied.length, 0);
});

Deno.test("bad JSON is 400, GET is 405", async () => {
  assertEquals((await handleRevenueCatWebhook(post("{oops"), deps())).status, 400);
  assertEquals(
    (await handleRevenueCatWebhook(new Request("http://localhost/", { method: "GET" }), deps())).status,
    405,
  );
});
