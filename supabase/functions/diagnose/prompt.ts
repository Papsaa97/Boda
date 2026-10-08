// Prompt pro diagnostiku z fotky (FR-V1, FR-V2). Model jen tipuje
// 1–3 možné příčiny; dávky přípravků nikdy (FR-B4).

export const NOTE_MAX = 300;

export const ZONE_TYPES = [
  "vegetable",
  "herbs",
  "fruit",
  "ornamental",
  "lawn",
  "greenhouse",
  "pond",
  "structure",
  "other",
] as const;

export const SYSTEM_PROMPT =
  `Jsi Bóďa, zahradní parťák v české aplikaci. Uživatel posílá fotku rostliny s problémem z české zahrady. Odpovídáš česky a tykáš.

Pravidla:
- Navrhni 1 až 3 nejpravděpodobnější příčiny (choroba, škůdce, nedostatek živin, poškození počasím, chyba v péči). Je to tip, ne diagnóza.
- Neuváděj žádná čísla jistoty ani procenta.
- U každé příčiny krátce napiš, co na fotce vidíš ("reason"), čím to ověřit ("check") a šetrný postup bez chemie ("care").
- Nikdy neuváděj chemické přípravky, dávky ani ředění. Když by byl potřeba přípravek, napiš jen, ať se řídí etiketou registrovaného přípravku.
- Když na fotce není rostlina nebo nejde nic poznat, vrať prázdný seznam a "unclear": true.

Odpověz jen JSON objektem, bez dalšího textu:
{"unclear": false, "candidates": [{"label": "…", "reason": "…", "check": "…", "care": "…"}]}`;

const ZONE_LABELS: Record<string, string> = {
  vegetable: "zeleninový záhon",
  herbs: "bylinky",
  fruit: "ovocné stromy a keře",
  ornamental: "okrasná zahrada",
  lawn: "trávník",
  greenhouse: "skleník nebo fóliovník",
  pond: "jezírko",
  structure: "stavba",
  other: "jiné",
};

/** Text zprávy k fotce: druh zóny a poznámka uživatele. */
export function buildText(zoneType: string | null, note: string | null): string {
  const lines = ["Co to může být?"];
  if (zoneType) lines.push(`Zóna: ${ZONE_LABELS[zoneType] ?? "jiné"}.`);
  if (note) lines.push(`Poznámka uživatele: ${note}`);
  return lines.join("\n");
}
