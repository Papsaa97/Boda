// Výběr poskytovatele LLM podle konfigurace:
//   LLM_PROVIDER  (výchozí "anthropic")
//   LLM_API_KEY   (povinné)
//   LLM_MODEL     (povinné; název modelu je jen v konfiguraci, ne v kódu)
//   LLM_BASE_URL  (volitelné, např. proxy nebo regionální endpoint)

import { createAnthropicProvider } from "./anthropic.ts";
import type { FetchFn, LlmProvider } from "./types.ts";

export * from "./types.ts";

export type EnvGetter = (name: string) => string | undefined;

/** Vrátí poskytovatele, nebo null, když chybí klíč/model či je neznámý. */
export function createLlmProvider(env: EnvGetter, fetchFn?: FetchFn): LlmProvider | null {
  const provider = (env("LLM_PROVIDER") ?? "anthropic").trim().toLowerCase() || "anthropic";
  const apiKey = env("LLM_API_KEY")?.trim();
  const model = env("LLM_MODEL")?.trim();
  if (!apiKey || !model) return null;
  const baseUrl = env("LLM_BASE_URL")?.trim() || undefined;

  switch (provider) {
    case "anthropic":
      return createAnthropicProvider({ apiKey, model, baseUrl, fetchFn });
    default:
      return null;
  }
}
