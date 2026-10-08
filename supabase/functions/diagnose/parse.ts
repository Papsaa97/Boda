// Odpověď modelu na 1–3 kandidáty (FR-V2). Cokoli jiného se zahodí.

export const MAX_CANDIDATES = 3;
const FIELD_MAX = 400;

export interface Candidate {
  label: string;
  reason?: string;
  check?: string;
  care?: string;
}

export interface Diagnosis {
  unclear: boolean;
  candidates: Candidate[];
}

function text(value: unknown, max = FIELD_MAX): string | undefined {
  if (typeof value !== "string") return undefined;
  const t = value.replace(/\s+/g, " ").trim();
  return t ? t.slice(0, max) : undefined;
}

/** Vytáhne první JSON objekt z textu (model občas přidá ```json). */
function firstObject(raw: string): unknown {
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");
  if (start < 0 || end <= start) return null;
  try {
    return JSON.parse(raw.slice(start, end + 1));
  } catch {
    return null;
  }
}

export function parseDiagnosis(raw: string): Diagnosis {
  const obj = firstObject(raw);
  if (!obj || typeof obj !== "object") return { unclear: true, candidates: [] };
  const o = obj as Record<string, unknown>;
  const candidates: Candidate[] = [];
  if (Array.isArray(o.candidates)) {
    for (const c of o.candidates) {
      if (!c || typeof c !== "object") continue;
      const r = c as Record<string, unknown>;
      const label = text(r.label, 120);
      if (!label) continue;
      candidates.push({ label, reason: text(r.reason), check: text(r.check), care: text(r.care) });
      if (candidates.length === MAX_CANDIDATES) break;
    }
  }
  return { unclear: candidates.length === 0, candidates };
}
