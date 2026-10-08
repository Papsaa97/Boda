import { assert, assertEquals, assertStringIncludes } from "jsr:@std/assert@1";
import { sanitizeContext } from "./context.ts";
import { buildMessages, SYSTEM_PROMPT } from "./prompt.ts";

Deno.test("system prompt contains the hard rules (FR-B1–B4, FR-B9)", () => {
  for (
    const phrase of [
      "Čísla nepočítáš",
      "KONTEXT.calculations",
      "zdroj",
      "nechemická řešení",
      "neprofesionální uživatele",
      "ÚKZÚZ",
      "ochrannou lhůtu",
      "osobní ochranné pomůcky",
      "včel",
      "statika",
      "statický výpočet",
      '{"answer": "…", "actions": […]}',
    ]
  ) {
    assertStringIncludes(SYSTEM_PROMPT, phrase);
  }
});

Deno.test("system prompt has no per-request data", () => {
  assert(!SYSTEM_PROMPT.includes("2026-"));
});

Deno.test("buildMessages puts date, context and question in the last user turn", () => {
  const ctx = sanitizeContext({ zones: [{ name: "Záhon" }] });
  const messages = buildMessages("Kdy sázet česnek?", ctx, [], "2026-10-08");
  assertEquals(messages.length, 1);
  assertEquals(messages[0].role, "user");
  assertStringIncludes(messages[0].text, "Dnešní datum: 2026-10-08");
  assertStringIncludes(messages[0].text, '"name":"Záhon"');
  assert(messages[0].text.endsWith("DOTAZ:\nKdy sázet česnek?"));
});

Deno.test("buildMessages normalizes history to alternating roles starting with user", () => {
  const ctx = sanitizeContext({});
  const messages = buildMessages("A teď?", ctx, [
    { role: "assistant", text: "Vítej" },
    { role: "user", text: "Ahoj" },
    { role: "user", text: "Jsi tam?" },
    { role: "assistant", text: "Jsem" },
    { role: "user", text: "Nezodpovězená otázka" },
  ], "2026-10-08");
  assertEquals(messages.map((m) => m.role), ["user", "assistant", "user"]);
  assertEquals(messages[0].text, "Ahoj\n\nJsi tam?");
  assertStringIncludes(messages[2].text, "A teď?");
});
