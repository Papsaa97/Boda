// Malé rozhraní pro poskytovatele jazykového modelu. Další poskytovatel
// = nový adaptér implementující LlmProvider + větev v createLlmProvider.

export type LlmRole = "user" | "assistant";

export interface LlmMessage {
  role: LlmRole;
  text: string;
}

export interface LlmRequest {
  /** Systémový prompt (pravidla). */
  system: string;
  /** Konverzace; první zpráva je od uživatele, role se střídají. */
  messages: LlmMessage[];
  /** Strop výstupních tokenů. */
  maxTokens: number;
}

export interface LlmResult {
  /** Text odpovědi (u odmítnutí modelem prázdný). */
  text: string;
  inputTokens: number;
  outputTokens: number;
  /** Důvod ukončení podle poskytovatele, normalizovaný. */
  stopReason: "end" | "max_tokens" | "refusal" | "other";
}

export interface LlmProvider {
  /** Jméno poskytovatele do logu (ne model). */
  readonly name: string;
  complete(request: LlmRequest): Promise<LlmResult>;
}

/** Chyba volání poskytovatele (síť, 4xx/5xx, neplatná odpověď). */
export class LlmUpstreamError extends Error {
  constructor(message: string, readonly status?: number) {
    super(message);
    this.name = "LlmUpstreamError";
  }
}

export type FetchFn = (input: string | URL | Request, init?: RequestInit) => Promise<Response>;
