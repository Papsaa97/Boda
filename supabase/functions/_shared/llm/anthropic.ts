// Adaptér pro Anthropic Messages API (čisté HTTP, bez SDK).
// Model se bere jen z konfigurace (env LLM_MODEL), v kódu žádný není.

import {
  type FetchFn,
  type LlmProvider,
  type LlmRequest,
  type LlmResult,
  LlmUpstreamError,
} from "./types.ts";

export interface AnthropicOptions {
  apiKey: string;
  model: string;
  baseUrl?: string;
  timeoutMs?: number;
  /** Počet opakování při 429/5xx/529 (výchozí 1). */
  retries?: number;
  fetchFn?: FetchFn;
  sleep?: (ms: number) => Promise<void>;
}

const API_VERSION = "2023-06-01";
const RETRYABLE = new Set([408, 409, 429, 500, 502, 503, 504, 529]);

interface AnthropicResponseBody {
  content?: Array<{ type?: string; text?: string }>;
  stop_reason?: string | null;
  usage?: { input_tokens?: number; output_tokens?: number };
}

/** Sestaví tělo požadavku na POST /v1/messages. */
export function buildAnthropicBody(model: string, request: LlmRequest): Record<string, unknown> {
  return {
    model,
    max_tokens: request.maxTokens,
    system: request.system,
    messages: request.messages.map((m) => ({
      role: m.role,
      content: m.images?.length
        ? [
          ...m.images.map((img) => ({
            type: "image",
            source: { type: "base64", media_type: img.mediaType, data: img.data },
          })),
          { type: "text", text: m.text },
        ]
        : m.text,
    })),
  };
}

/** Převede odpověď Messages API na LlmResult. */
export function parseAnthropicResponse(body: AnthropicResponseBody): LlmResult {
  if (!body || !Array.isArray(body.content)) {
    throw new LlmUpstreamError("Malformed response: missing content");
  }
  const text = body.content
    .filter((block) => block?.type === "text" && typeof block.text === "string")
    .map((block) => block.text as string)
    .join("");
  const reason = body.stop_reason ?? null;
  const stopReason: LlmResult["stopReason"] = reason === "end_turn" || reason === "stop_sequence"
    ? "end"
    : reason === "max_tokens"
    ? "max_tokens"
    : reason === "refusal"
    ? "refusal"
    : "other";
  return {
    text,
    inputTokens: Number(body.usage?.input_tokens ?? 0) || 0,
    outputTokens: Number(body.usage?.output_tokens ?? 0) || 0,
    stopReason,
  };
}

export function createAnthropicProvider(options: AnthropicOptions): LlmProvider {
  const fetchFn: FetchFn = options.fetchFn ?? fetch;
  const baseUrl = (options.baseUrl ?? "https://api.anthropic.com").replace(/\/+$/, "");
  const timeoutMs = options.timeoutMs ?? 120_000;
  const retries = options.retries ?? 1;
  const sleep = options.sleep ?? ((ms: number) => new Promise((r) => setTimeout(r, ms)));

  return {
    name: "anthropic",
    async complete(request: LlmRequest): Promise<LlmResult> {
      const body = JSON.stringify(buildAnthropicBody(options.model, request));
      let lastError: LlmUpstreamError | undefined;
      for (let attempt = 0; attempt <= retries; attempt++) {
        if (attempt > 0) await sleep(1000 * attempt);
        let response: Response;
        // Vlastní časovač (ne AbortSignal.timeout), aby se po odpovědi zrušil.
        const controller = new AbortController();
        const timer = setTimeout(() => controller.abort(), timeoutMs);
        try {
          response = await fetchFn(`${baseUrl}/v1/messages`, {
            method: "POST",
            headers: {
              "content-type": "application/json",
              "x-api-key": options.apiKey,
              "anthropic-version": API_VERSION,
            },
            body,
            signal: controller.signal,
          });
        } catch (e) {
          clearTimeout(timer);
          lastError = new LlmUpstreamError(`Network error: ${(e as Error)?.name ?? "unknown"}`);
          continue;
        }
        try {
          return await readResponse(response);
        } catch (e) {
          if (e instanceof RetryableError) {
            lastError = e.inner;
            continue;
          }
          throw e;
        } finally {
          clearTimeout(timer);
        }
      }
      throw lastError ?? new LlmUpstreamError("Unknown error");
    },
  };
}

class RetryableError extends Error {
  constructor(readonly inner: LlmUpstreamError) {
    super(inner.message);
  }
}

async function readResponse(response: Response): Promise<LlmResult> {
  if (!response.ok) {
    // Tělo chyby se neloguje celé (může obsahovat části promptu); zpráva
    // poskytovatele jen zkrácená, aby šlo poznat např. chybějící kredit.
    let errorType = "";
    let errorMessage = "";
    try {
      const err = await response.json();
      errorType = String(err?.error?.type ?? "");
      errorMessage = String(err?.error?.message ?? "").slice(0, 160);
    } catch { /* ignore */ }
    const error = new LlmUpstreamError(
      `HTTP ${response.status}${errorType ? ` ${errorType}` : ""}${errorMessage ? `: ${errorMessage}` : ""}`,
      response.status,
    );
    if (RETRYABLE.has(response.status)) throw new RetryableError(error);
    throw error;
  }
  let parsed: AnthropicResponseBody;
  try {
    parsed = await response.json();
  } catch {
    throw new LlmUpstreamError("Malformed response: not JSON", response.status);
  }
  return parseAnthropicResponse(parsed);
}
