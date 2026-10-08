// Robustní zpracování odpovědi modelu: očekává JSON {answer, actions},
// ale snese blok kódu, text kolem JSON i useknutou odpověď. Když JSON
// nejde přečíst, vrátí celý text jako odpověď bez akcí.

import { ACTIVITY_TYPES, MAX_ACTIONS, SHOPPING_UNITS } from "./prompt.ts";

export type BodaAction =
  | { type: "task"; title: string; due: string | null; zoneId: string | null }
  | { type: "shopping"; name: string; qty: number | null; unit: string | null }
  | { type: "activity"; title: string; activityType: string; zoneId: string | null };

export interface BodaAnswer {
  answer: string;
  actions: BodaAction[];
}

export const FALLBACK_ANSWER =
  "Promiň, na tohle ti teď neumím dobře odpovědět. Zkus otázku položit jinak nebo konkrétněji.";

const TITLE_MAX = 200;

function str(value: unknown, max = TITLE_MAX): string | null {
  if (typeof value !== "string") return null;
  const t = value.replace(/\s+/g, " ").trim();
  if (!t) return null;
  return t.length > max ? t.slice(0, max) : t;
}

function validDate(value: unknown): string | null {
  if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return null;
  const d = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(d.getTime()) && d.toISOString().slice(0, 10) === value ? value : null;
}

function zone(value: unknown, zoneIds: Set<string>): string | null {
  return typeof value === "string" && zoneIds.has(value) ? value : null;
}

/** Ověří a normalizuje navržené akce; neplatné zahodí. */
export function sanitizeActions(raw: unknown, zoneIds: Set<string>): BodaAction[] {
  if (!Array.isArray(raw)) return [];
  const out: BodaAction[] = [];
  for (const item of raw) {
    if (out.length >= MAX_ACTIONS) break;
    if (!item || typeof item !== "object") continue;
    const a = item as Record<string, unknown>;
    switch (a.type) {
      case "task": {
        const title = str(a.title);
        if (title) out.push({ type: "task", title, due: validDate(a.due), zoneId: zone(a.zoneId, zoneIds) });
        break;
      }
      case "shopping": {
        const name = str(a.name);
        if (!name) break;
        const qty = typeof a.qty === "number" && Number.isFinite(a.qty) && a.qty >= 0 ? a.qty : null;
        const unit = typeof a.unit === "string" && (SHOPPING_UNITS as readonly string[]).includes(a.unit)
          ? a.unit
          : null;
        out.push({ type: "shopping", name, qty, unit });
        break;
      }
      case "activity": {
        const title = str(a.title);
        if (!title) break;
        const activityType = typeof a.activityType === "string" &&
            (ACTIVITY_TYPES as readonly string[]).includes(a.activityType)
          ? a.activityType
          : "other";
        out.push({ type: "activity", title, activityType, zoneId: zone(a.zoneId, zoneIds) });
        break;
      }
    }
  }
  return out;
}

function tryParseObject(text: string): Record<string, unknown> | null {
  try {
    const value = JSON.parse(text);
    return value && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : null;
  } catch {
    return null;
  }
}

/** Najde v textu objekt JSON (celý text, blok ```json, nebo od první { po poslední }). */
function extractObject(text: string): Record<string, unknown> | null {
  const trimmed = text.trim();
  const direct = tryParseObject(trimmed);
  if (direct) return direct;
  const fence = /```(?:json)?\s*([\s\S]*?)```/i.exec(trimmed);
  if (fence) {
    const fenced = tryParseObject(fence[1].trim());
    if (fenced) return fenced;
  }
  const start = trimmed.indexOf("{");
  const end = trimmed.lastIndexOf("}");
  if (start >= 0 && end > start) {
    return tryParseObject(trimmed.slice(start, end + 1));
  }
  return null;
}

/** Z useknutého JSON vytáhne aspoň hodnotu "answer". */
function salvageAnswer(text: string): string | null {
  const m = /"answer"\s*:\s*"((?:[^"\\]|\\.)*)/.exec(text);
  if (!m) return null;
  let raw = m[1];
  // Useknutá escape sekvence na konci by JSON.parse shodila.
  raw = raw.replace(/\\u[0-9a-fA-F]{0,3}$/, "").replace(/\\$/, "");
  try {
    const value = JSON.parse(`"${raw}"`);
    return typeof value === "string" && value.trim() ? value.trim() : null;
  } catch {
    return null;
  }
}

/** Převede text odpovědi modelu na {answer, actions}. */
export function parseModelOutput(text: string, zoneIds: Set<string>): BodaAnswer {
  const trimmed = (text ?? "").trim();
  if (!trimmed) return { answer: FALLBACK_ANSWER, actions: [] };

  const obj = extractObject(trimmed);
  if (obj) {
    const answer = typeof obj.answer === "string" && obj.answer.trim() ? obj.answer.trim() : null;
    if (answer) return { answer, actions: sanitizeActions(obj.actions, zoneIds) };
  }

  if (trimmed.startsWith("{") || trimmed.startsWith("```")) {
    const salvaged = salvageAnswer(trimmed);
    if (salvaged) return { answer: salvaged, actions: [] };
  }

  return { answer: trimmed, actions: [] };
}
