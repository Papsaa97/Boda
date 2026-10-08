// Whitelist kontextu pro Bóďu (spec 5.2 FR-B1, kap. 9 minimalizace).
// Do modelu jde jen to, co je tady vyjmenované; vše ostatní se zahodí.
// Jména osob a e-maily se nepředávají (garden.name se zahazuje, e-mailové
// adresy ve volném textu se nahrazují).

export interface BodaGarden {
  municipality?: string;
  region?: string;
  locationLat?: number;
  locationLng?: number;
  altitudeM?: number;
  lastFrostDate?: string;
}

export interface BodaZone {
  id?: string;
  name?: string;
  type?: string;
  areaM2?: number;
  soilTexture?: string;
  ph?: number;
  phMeasuredAt?: string;
  sunExposure?: string;
  irrigation?: string;
  covered?: boolean;
}

export interface BodaActivity {
  zoneId?: string;
  type?: string;
  title?: string;
  occurredAt?: string;
  notes?: string;
  harvestQty?: number;
  harvestUnit?: string;
}

export interface BodaTask {
  title?: string;
  zoneId?: string;
  due?: string;
}

export interface BodaInventoryItem {
  id?: string;
  name?: string;
  category?: string;
  unit?: string;
  stockQty?: number;
  lowStockThreshold?: number;
  details?: Record<string, string | number | boolean>;
}

export interface BodaCalculation {
  label: string;
  result: string;
  source: string;
}

export interface BodaContext {
  garden: BodaGarden | null;
  zones: BodaZone[];
  recentActivities: BodaActivity[];
  openTasks: BodaTask[];
  inventory: BodaInventoryItem[];
  calculations: BodaCalculation[];
}

export const LIMITS = {
  zones: 50,
  recentActivities: 30,
  openTasks: 30,
  inventory: 100,
  calculations: 20,
  shortText: 120,
  longText: 600,
} as const;

/** Klíče `details` položky skladu, které smí do modelu (údaje z etikety). */
export const INVENTORY_DETAIL_KEYS = [
  // osiva
  "species",
  "variety",
  "bestBefore",
  // hnojiva
  "n",
  "p",
  "k",
  "form",
  // přípravky na ochranu rostlin (údaje z etikety / registru ÚKZÚZ)
  "activeSubstance",
  "authorizationNo",
  "phiDays",
  "nonProfessional",
  "labelDose",
  "labelCrops",
  "labelNotes",
  // nářadí
  "condition",
] as const;

const EMAIL_RE = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/gi;
// telefonní čísla: aspoň 9 číslic, volitelně oddělených mezerou
const PHONE_RE = /\+?\d(?: ?\d){8,}/g;

/** Vyčistí volný text: ořízne, zkrátí, nahradí e-maily a telefonní čísla. */
export function cleanText(value: unknown, max: number): string | undefined {
  if (typeof value !== "string") return undefined;
  const text = value
    .replace(EMAIL_RE, "[e-mail]")
    .replace(PHONE_RE, "[telefon]")
    .replace(/\s+/g, " ")
    .trim();
  if (!text) return undefined;
  return text.length > max ? `${text.slice(0, max - 1)}…` : text;
}

function num(value: unknown, min = -1e9, max = 1e9): number | undefined {
  return typeof value === "number" && Number.isFinite(value) && value >= min && value <= max
    ? value
    : undefined;
}

function bool(value: unknown): boolean | undefined {
  return typeof value === "boolean" ? value : undefined;
}

const ID_RE = /^[0-9a-fA-F-]{8,64}$/;
function id(value: unknown): string | undefined {
  return typeof value === "string" && ID_RE.test(value) ? value : undefined;
}

const DATE_RE = /^\d{4}-\d{2}-\d{2}/;
function date(value: unknown): string | undefined {
  return typeof value === "string" && DATE_RE.test(value) ? value.slice(0, 25) : undefined;
}

function key(value: unknown): string | undefined {
  return typeof value === "string" && /^[A-Za-z]{1,32}$/.test(value) ? value : undefined;
}

function round2(value: number | undefined): number | undefined {
  return value === undefined ? undefined : Math.round(value * 100) / 100;
}

/** Odstraní klíče s hodnotou undefined (kompaktnější JSON pro model). */
function compact<T extends object>(obj: T): T {
  return Object.fromEntries(
    Object.entries(obj).filter(([, v]) => v !== undefined),
  ) as T;
}

function list<T>(value: unknown, max: number, map: (item: Record<string, unknown>) => T | null): T[] {
  if (!Array.isArray(value)) return [];
  const out: T[] = [];
  for (const item of value) {
    if (out.length >= max) break;
    if (item && typeof item === "object" && !Array.isArray(item)) {
      const mapped = map(item as Record<string, unknown>);
      if (mapped !== null) out.push(mapped);
    }
  }
  return out;
}

function sanitizeDetails(value: unknown): Record<string, string | number | boolean> | undefined {
  if (!value || typeof value !== "object" || Array.isArray(value)) return undefined;
  const src = value as Record<string, unknown>;
  const out: Record<string, string | number | boolean> = {};
  for (const k of INVENTORY_DETAIL_KEYS) {
    const v = src[k];
    if (typeof v === "string") {
      const t = cleanText(v, LIMITS.longText);
      if (t) out[k] = t;
    } else if (Array.isArray(v)) {
      const t = cleanText(v.filter((x) => typeof x === "string").join(", "), LIMITS.longText);
      if (t) out[k] = t;
    } else if (typeof v === "number" && Number.isFinite(v)) {
      out[k] = v;
    } else if (typeof v === "boolean") {
      out[k] = v;
    }
  }
  return Object.keys(out).length ? out : undefined;
}

/** Ponechá jen povolená pole kontextu. Neznámá pole a typy zahodí. */
export function sanitizeContext(raw: unknown): BodaContext {
  const src = raw && typeof raw === "object" && !Array.isArray(raw) ? raw as Record<string, unknown> : {};

  const g = src.garden && typeof src.garden === "object" && !Array.isArray(src.garden)
    ? src.garden as Record<string, unknown>
    : null;
  const garden = g
    ? compact<BodaGarden>({
      municipality: cleanText(g.municipality, LIMITS.shortText),
      region: cleanText(g.region, LIMITS.shortText),
      locationLat: round2(num(g.locationLat, -90, 90)),
      locationLng: round2(num(g.locationLng, -180, 180)),
      altitudeM: num(g.altitudeM, -500, 9000),
      lastFrostDate: date(g.lastFrostDate),
    })
    : null;

  return {
    garden: garden && Object.keys(garden).length ? garden : null,
    zones: list(src.zones, LIMITS.zones, (z) =>
      compact<BodaZone>({
        id: id(z.id),
        name: cleanText(z.name, LIMITS.shortText),
        type: key(z.type),
        areaM2: num(z.areaM2, 0, 1e7),
        soilTexture: key(z.soilTexture),
        ph: num(z.ph, 0, 14),
        phMeasuredAt: date(z.phMeasuredAt),
        sunExposure: key(z.sunExposure),
        irrigation: key(z.irrigation),
        covered: bool(z.covered),
      })),
    recentActivities: list(src.recentActivities, LIMITS.recentActivities, (a) =>
      compact<BodaActivity>({
        zoneId: id(a.zoneId),
        type: key(a.type),
        title: cleanText(a.title, LIMITS.shortText),
        occurredAt: date(a.occurredAt),
        notes: cleanText(a.notes, LIMITS.longText),
        harvestQty: num(a.harvestQty, 0),
        harvestUnit: cleanText(a.harvestUnit, 20),
      })),
    openTasks: list(src.openTasks, LIMITS.openTasks, (t) =>
      compact<BodaTask>({
        title: cleanText(t.title, LIMITS.shortText),
        zoneId: id(t.zoneId),
        due: date(t.due),
      })),
    inventory: list(src.inventory, LIMITS.inventory, (i) =>
      compact<BodaInventoryItem>({
        id: id(i.id),
        name: cleanText(i.name, LIMITS.shortText),
        category: key(i.category),
        unit: key(i.unit),
        stockQty: num(i.stockQty),
        lowStockThreshold: num(i.lowStockThreshold, 0),
        details: sanitizeDetails(i.details),
      })),
    calculations: list(src.calculations, LIMITS.calculations, (c) => {
      const label = cleanText(c.label, LIMITS.shortText);
      const result = cleanText(c.result, LIMITS.shortText);
      const source = cleanText(c.source, LIMITS.longText);
      return label && result && source ? { label, result, source } : null;
    }),
  };
}

/** Id zón z kontextu (pro kontrolu zoneId v navržených akcích). */
export function zoneIds(context: BodaContext): Set<string> {
  return new Set(context.zones.map((z) => z.id).filter((x): x is string => !!x));
}
