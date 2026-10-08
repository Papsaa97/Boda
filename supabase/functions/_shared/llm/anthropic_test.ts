import { assertEquals, assertRejects } from "jsr:@std/assert@1";
import { buildAnthropicBody, createAnthropicProvider, parseAnthropicResponse } from "./anthropic.ts";
import { createLlmProvider } from "./index.ts";
import { LlmUpstreamError } from "./types.ts";

const MODEL = "model-from-env";

function jsonResponse(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}

Deno.test("buildAnthropicBody uses the configured model", () => {
  assertEquals(
    buildAnthropicBody(MODEL, { system: "S", messages: [{ role: "user", text: "Q" }], maxTokens: 500 }),
    { model: MODEL, max_tokens: 500, system: "S", messages: [{ role: "user", content: "Q" }] },
  );
});

Deno.test("parseAnthropicResponse joins text blocks and ignores others", () => {
  assertEquals(
    parseAnthropicResponse({
      content: [{ type: "thinking" }, { type: "text", text: '{"answer":' }, { type: "text", text: '"x"}' }],
      stop_reason: "end_turn",
      usage: { input_tokens: 10, output_tokens: 5 },
    }),
    { text: '{"answer":"x"}', inputTokens: 10, outputTokens: 5, stopReason: "end" },
  );
  assertEquals(parseAnthropicResponse({ content: [], stop_reason: "refusal" }).stopReason, "refusal");
  assertEquals(parseAnthropicResponse({ content: [], stop_reason: "max_tokens" }).stopReason, "max_tokens");
});

Deno.test("provider sends the documented headers and parses the reply", async () => {
  let seen: { url: string; init: RequestInit } | undefined;
  const provider = createAnthropicProvider({
    apiKey: "test-key",
    model: MODEL,
    fetchFn: (url, init) => {
      seen = { url: String(url), init: init! };
      return Promise.resolve(jsonResponse(200, {
        content: [{ type: "text", text: "Ahoj" }],
        stop_reason: "end_turn",
        usage: { input_tokens: 3, output_tokens: 1 },
      }));
    },
  });
  const result = await provider.complete({ system: "S", messages: [{ role: "user", text: "Q" }], maxTokens: 50 });
  assertEquals(result, { text: "Ahoj", inputTokens: 3, outputTokens: 1, stopReason: "end" });
  assertEquals(seen!.url, "https://api.anthropic.com/v1/messages");
  const headers = seen!.init.headers as Record<string, string>;
  assertEquals(headers["x-api-key"], "test-key");
  assertEquals(headers["anthropic-version"], "2023-06-01");
  assertEquals(JSON.parse(String(seen!.init.body)).model, MODEL);
});

Deno.test("provider retries once on overload, then fails with LlmUpstreamError", async () => {
  let calls = 0;
  const provider = createAnthropicProvider({
    apiKey: "k",
    model: MODEL,
    sleep: () => Promise.resolve(),
    fetchFn: () => {
      calls++;
      return Promise.resolve(jsonResponse(529, { type: "error", error: { type: "overloaded_error" } }));
    },
  });
  const err = await assertRejects(
    () => provider.complete({ system: "S", messages: [{ role: "user", text: "Q" }], maxTokens: 50 }),
    LlmUpstreamError,
  );
  assertEquals(calls, 2);
  assertEquals((err as LlmUpstreamError).status, 529);
});

Deno.test("provider does not retry a 400", async () => {
  let calls = 0;
  const provider = createAnthropicProvider({
    apiKey: "k",
    model: MODEL,
    sleep: () => Promise.resolve(),
    fetchFn: () => {
      calls++;
      return Promise.resolve(jsonResponse(400, { type: "error", error: { type: "invalid_request_error" } }));
    },
  });
  await assertRejects(
    () => provider.complete({ system: "S", messages: [{ role: "user", text: "Q" }], maxTokens: 50 }),
    LlmUpstreamError,
  );
  assertEquals(calls, 1);
});

Deno.test("provider recovers after a network error", async () => {
  let calls = 0;
  const provider = createAnthropicProvider({
    apiKey: "k",
    model: MODEL,
    sleep: () => Promise.resolve(),
    fetchFn: () => {
      calls++;
      if (calls === 1) return Promise.reject(new TypeError("connection reset"));
      return Promise.resolve(jsonResponse(200, { content: [{ type: "text", text: "ok" }], stop_reason: "end_turn" }));
    },
  });
  const result = await provider.complete({ system: "S", messages: [{ role: "user", text: "Q" }], maxTokens: 50 });
  assertEquals(result.text, "ok");
});

Deno.test("createLlmProvider needs key and model; unknown provider is not configured", () => {
  const env = (vars: Record<string, string>) => (name: string) => vars[name];
  assertEquals(createLlmProvider(env({})), null);
  assertEquals(createLlmProvider(env({ LLM_API_KEY: "k" })), null);
  assertEquals(createLlmProvider(env({ LLM_MODEL: MODEL })), null);
  assertEquals(createLlmProvider(env({ LLM_API_KEY: "k", LLM_MODEL: MODEL, LLM_PROVIDER: "nope" })), null);
  assertEquals(createLlmProvider(env({ LLM_API_KEY: "k", LLM_MODEL: MODEL }))?.name, "anthropic");
  assertEquals(
    createLlmProvider(env({ LLM_API_KEY: "k", LLM_MODEL: MODEL, LLM_PROVIDER: " Anthropic " }))?.name,
    "anthropic",
  );
});
