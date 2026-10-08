import { assert, assertEquals } from "jsr:@std/assert@1";
import { cleanText, LIMITS, sanitizeContext, zoneIds } from "./context.ts";

const ZONE_ID = "c0000000-0000-4000-8000-000000000001";

Deno.test("sanitizeContext drops unknown fields, names and e-mails", () => {
  const ctx = sanitizeContext({
    garden: {
      name: "Zahrada Jana Nováka",
      ownerEmail: "jan@example.com",
      municipality: "Beroun",
      locationLat: 49.96421,
      locationLng: 14.07211,
      altitudeM: 230,
    },
    user: { email: "jan@example.com", displayName: "Jan Novák" },
    zones: [{
      id: ZONE_ID,
      name: "Zelenina JV",
      type: "vegetable",
      areaM2: 20,
      soilTexture: "loamy",
      ph: 6.6,
      sunExposure: "fullSun",
      secret: "x",
    }],
    recentActivities: [{
      zoneId: ZONE_ID,
      type: "watering",
      title: "Zálivka",
      notes: "Volal jsem sousedovi na 777 123 456, psal jan@example.com",
      occurredAt: "2026-10-01T10:00:00+02:00",
      authorName: "Jan",
    }],
    openTasks: [{ title: "Okopat", zoneId: ZONE_ID, due: "2026-10-10", assignee: "Jan" }],
    inventory: [{
      name: "Postřik X",
      category: "plantProtection",
      unit: "ml",
      stockQty: 250,
      details: {
        activeSubstance: "abc",
        authorizationNo: "1234-5",
        phiDays: 7,
        nonProfessional: true,
        labelDose: "20 ml / 5 l vody",
        supplierEmail: "shop@example.com",
      },
    }],
    calculations: [{ label: "Kompost na zónu", result: "40 kg", source: "2 kg/m² podle tabulky", extra: 1 }],
    somethingElse: { a: 1 },
  });

  assertEquals(ctx.garden, { municipality: "Beroun", locationLat: 49.96, locationLng: 14.07, altitudeM: 230 });
  assertEquals(Object.keys(ctx).sort(), [
    "calculations",
    "garden",
    "inventory",
    "openTasks",
    "recentActivities",
    "zones",
  ]);
  assertEquals(ctx.zones[0], {
    id: ZONE_ID,
    name: "Zelenina JV",
    type: "vegetable",
    areaM2: 20,
    soilTexture: "loamy",
    ph: 6.6,
    sunExposure: "fullSun",
  });
  assertEquals(ctx.recentActivities[0].notes, "Volal jsem sousedovi na [telefon], psal [e-mail]");
  assert(!("authorName" in ctx.recentActivities[0]));
  assertEquals(ctx.openTasks[0], { title: "Okopat", zoneId: ZONE_ID, due: "2026-10-10" });
  assertEquals(ctx.inventory[0].details, {
    activeSubstance: "abc",
    authorizationNo: "1234-5",
    phiDays: 7,
    nonProfessional: true,
    labelDose: "20 ml / 5 l vody",
  });
  assertEquals(ctx.calculations, [{ label: "Kompost na zónu", result: "40 kg", source: "2 kg/m² podle tabulky" }]);

  const serialized = JSON.stringify(ctx);
  assert(!serialized.includes("Novák"));
  assert(!serialized.includes("@example.com"));
});

Deno.test("sanitizeContext tolerates garbage input", () => {
  for (const raw of [undefined, null, 42, "x", [], { zones: "nope", calculations: [1, null, "a"] }]) {
    const ctx = sanitizeContext(raw);
    assertEquals(ctx.garden, null);
    assertEquals(ctx.zones, []);
    assertEquals(ctx.calculations, []);
  }
});

Deno.test("sanitizeContext drops calculations without a source", () => {
  const ctx = sanitizeContext({ calculations: [{ label: "Dávka", result: "1,2 kg" }] });
  assertEquals(ctx.calculations, []);
});

Deno.test("sanitizeContext caps list sizes and text lengths", () => {
  const zones = Array.from({ length: 80 }, (_, i) => ({ name: `Zóna ${i}`, type: "other" }));
  const ctx = sanitizeContext({ zones, recentActivities: [{ title: "x".repeat(5000) }] });
  assertEquals(ctx.zones.length, LIMITS.zones);
  assertEquals(ctx.recentActivities[0].title!.length, LIMITS.shortText);
});

Deno.test("sanitizeContext rejects invalid ids and enum-like values", () => {
  const ctx = sanitizeContext({ zones: [{ id: "'; drop table", name: "A", type: "veg etable!" }] });
  assertEquals(ctx.zones[0], { name: "A" });
});

Deno.test("cleanText keeps small numbers and dates", () => {
  assertEquals(cleanText("Výsev 2026-03-15, 1 200 g, 20 m²", 100), "Výsev 2026-03-15, 1 200 g, 20 m²");
});

Deno.test("zoneIds collects ids", () => {
  const ctx = sanitizeContext({ zones: [{ id: ZONE_ID, name: "A" }, { name: "B" }] });
  assertEquals([...zoneIds(ctx)], [ZONE_ID]);
});
