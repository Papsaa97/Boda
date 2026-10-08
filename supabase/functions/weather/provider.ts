// Poskytovatel počasí (FR-W1). Formát odpovědi je Open-Meteo (denní
// srážky a teploty); placený tarif pro komerční aplikaci má stejné API
// na vlastní adrese s parametrem apikey. Adresa i klíč jsou v secrets
// (WEATHER_API_URL, WEATHER_API_KEY), nikdy v aplikaci.

export interface ProviderConfig {
  url: string;
  apiKey?: string;
}

/** Konfigurace z prostředí; null, když adresa chybí (počasí vypnuté). */
export function providerConfig(env: (name: string) => string | undefined): ProviderConfig | null {
  const url = env("WEATHER_API_URL")?.trim();
  if (!url) return null;
  const apiKey = env("WEATHER_API_KEY")?.trim();
  return { url, apiKey: apiKey ? apiKey : undefined };
}

/** Souřadnice na 2 desetinná místa (~1 km): přesnější poloha se neposílá. */
export function roundCoord(v: number): number {
  return Math.round(v * 100) / 100;
}

export function buildUrl(config: ProviderConfig, lat: number, lng: number): string {
  const u = new URL(config.url);
  u.searchParams.set("latitude", roundCoord(lat).toFixed(2));
  u.searchParams.set("longitude", roundCoord(lng).toFixed(2));
  u.searchParams.set("daily", "precipitation_sum,temperature_2m_min,temperature_2m_max");
  u.searchParams.set("past_days", "7");
  u.searchParams.set("forecast_days", "7");
  u.searchParams.set("timezone", "Europe/Prague");
  if (config.apiKey) u.searchParams.set("apikey", config.apiKey);
  return u.toString();
}

export interface DailyWeather {
  date: string;
  precipMm: number;
  tMinC: number | null;
  tMaxC: number | null;
}

export interface WeatherPayload {
  elevationM: number | null;
  days: DailyWeather[];
}

function num(v: unknown): number | null {
  return typeof v === "number" && Number.isFinite(v) ? v : null;
}

/** Odpověď poskytovatele ve tvaru pro aplikaci; null, když nedává smysl. */
export function normalize(body: unknown): WeatherPayload | null {
  if (!body || typeof body !== "object") return null;
  const b = body as Record<string, unknown>;
  const daily = b.daily as Record<string, unknown> | undefined;
  const time = daily?.time;
  if (!Array.isArray(time)) return null;
  const precip = Array.isArray(daily?.precipitation_sum) ? daily.precipitation_sum : [];
  const tMin = Array.isArray(daily?.temperature_2m_min) ? daily.temperature_2m_min : [];
  const tMax = Array.isArray(daily?.temperature_2m_max) ? daily.temperature_2m_max : [];
  const days: DailyWeather[] = [];
  time.forEach((t, i) => {
    if (typeof t !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(t)) return;
    days.push({
      date: t,
      // Chybějící srážky (výpadek stanice) = 0, ať zálivka nedostane falešný déšť.
      precipMm: Math.max(0, num(precip[i]) ?? 0),
      tMinC: num(tMin[i]),
      tMaxC: num(tMax[i]),
    });
  });
  if (days.length === 0) return null;
  const elevation = num(b.elevation);
  return { elevationM: elevation === null ? null : Math.round(elevation), days };
}
