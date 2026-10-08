import { assertEquals } from "jsr:@std/assert@1";
import { FALLBACK_ANSWER, parseModelOutput, sanitizeActions } from "./parse.ts";

const ZONE = "c0000000-0000-4000-8000-000000000001";
const zones = new Set([ZONE]);

Deno.test("parses a clean JSON answer with actions", () => {
  const text = JSON.stringify({
    answer: "Nejdřív zkus mšice spláchnout vodou.",
    actions: [
      { type: "task", title: "Zkontrolovat mšice", due: "2026-10-11", zoneId: ZONE },
      { type: "shopping", name: "Draselné mýdlo", qty: 1, unit: "ks" },
      { type: "activity", title: "Ošetření vodou", activityType: "spraying", zoneId: ZONE },
    ],
  });
  assertEquals(parseModelOutput(text, zones), {
    answer: "Nejdřív zkus mšice spláchnout vodou.",
    actions: [
      { type: "task", title: "Zkontrolovat mšice", due: "2026-10-11", zoneId: ZONE },
      { type: "shopping", name: "Draselné mýdlo", qty: 1, unit: "ks" },
      { type: "activity", title: "Ošetření vodou", activityType: "spraying", zoneId: ZONE },
    ],
  });
});

Deno.test("parses JSON inside a code fence and surrounding prose", () => {
  const fenced = 'Tady je odpověď:\n```json\n{"answer": "Ahoj", "actions": []}\n```\nDíky';
  assertEquals(parseModelOutput(fenced, zones), { answer: "Ahoj", actions: [] });
  const prose = 'Jasně! {"answer": "Zalij večer.", "actions": []} Hezký den.';
  assertEquals(parseModelOutput(prose, zones), { answer: "Zalij večer.", actions: [] });
});

Deno.test("falls back to plain text without actions", () => {
  assertEquals(parseModelOutput("Prostě zalij večer.", zones), { answer: "Prostě zalij večer.", actions: [] });
  assertEquals(parseModelOutput("", zones), { answer: FALLBACK_ANSWER, actions: [] });
  assertEquals(parseModelOutput('{"actions": []}', zones).answer, '{"actions": []}');
});

Deno.test("salvages the answer from truncated JSON", () => {
  const truncated = '{"answer": "Rajčata sázej do 50 cm spon\\u00e1 a \\"opory\\" dej hned", "actions": [{"type": "ta';
  assertEquals(parseModelOutput(truncated, zones), {
    answer: 'Rajčata sázej do 50 cm sponá a "opory" dej hned',
    actions: [],
  });
});

Deno.test("sanitizeActions validates fields", () => {
  const actions = sanitizeActions([
    { type: "task", title: "  Úkol  ", due: "2026-02-30", zoneId: "unknown-zone" },
    { type: "task", title: "" },
    { type: "shopping", name: "Kompost", qty: "40", unit: "pytel" },
    { type: "shopping", name: "Opory", qty: -1, unit: "ks" },
    { type: "activity", title: "Výsev", activityType: "dancing", zoneId: ZONE },
    { type: "delete_everything" },
    null,
    "task",
  ], zones);
  assertEquals(actions, [
    { type: "task", title: "Úkol", due: null, zoneId: null },
    { type: "shopping", name: "Kompost", qty: null, unit: null },
    { type: "shopping", name: "Opory", qty: null, unit: "ks" },
    { type: "activity", title: "Výsev", activityType: "other", zoneId: ZONE },
  ]);
});

Deno.test("sanitizeActions caps the number of actions", () => {
  const many = Array.from({ length: 12 }, (_, i) => ({ type: "task", title: `Úkol ${i}` }));
  assertEquals(sanitizeActions(many, zones).length, 5);
  assertEquals(sanitizeActions("nope", zones), []);
});
