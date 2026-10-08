import { assertEquals } from "jsr:@std/assert@1";
import { handleWeather, type WeatherDeps } from "./handler.ts";
import { buildUrl, normalize, providerConfig } from "./provider.ts";

const NOW = new Date("2026-10-08T08:00:00Z");

const SAMPLE = {
  elevation: 287.4,
  daily: {
    time: ["2026-10-07", "2026-10-08", "2026-10-09"],
    precipitation_sum: [3.2, null, 6.1],
    temperature_2m_min: [4.1, 1.0, -1.5],
    temperature_2m_max: [12, 10.5, 8],
  },
};

function deps(opts: Partial<WeatherDeps> & { urls?: string[] } = {}): WeatherDeps {
  return {
    authenticate: () => Promise.resolve({ userId: "u1" }),
    getEntitlement: () => Promise.resolve({ plan: "premium", valid_until: null }),
    config: { url: "https://weather.example/v1/forecast", apiKey: "k" },
    fetch: (url) => {
      opts.urls?.push(url);
      return Promise.resolve(new Response(JSON.stringify(SAMPLE), { status: 200 }));
    },
    now: () => NOW,
    log: () => {},
    ...opts,
  };
}

function post(body: unknown): Request {
  return new Request("http://localhost/weather", {
    method: "POST",
    body: JSON.stringify(body),
    headers: { Authorization: "Bearer t" },
  });
}

Deno.test("returns normalized weather for a rounded location", async () => {
  const urls: string[] = [];
  const res = await handleWeather(post({ lat: 50.087654, lng: 14.421234 }), deps({ urls }));
  assertEquals(res.status, 200);
  const body = await res.json();
  assertEquals(body.elevationM, 287);
  assertEquals(body.days[1], { date: "2026-10-08", precipMm: 0, tMinC: 1, tMaxC: 10.5 });
  assertEquals(body.fetchedAt, NOW.toISOString());
  const url = new URL(urls[0]);
  assertEquals(url.searchParams.get("latitude"), "50.09");
  assertEquals(url.searchParams.get("longitude"), "14.42");
  assertEquals(url.searchParams.get("past_days"), "7");
  assertEquals(url.searchParams.get("apikey"), "k");
});

Deno.test("requires sign-in, premium and configuration", async () => {
  assertEquals(
    (await handleWeather(post({ lat: 50, lng: 14 }), deps({ authenticate: () => Promise.resolve(null) }))).status,
    401,
  );
  assertEquals(
    (await handleWeather(post({ lat: 50, lng: 14 }), deps({ getEntitlement: () => Promise.resolve(null) }))).status,
    402,
  );
  assertEquals(
    (await handleWeather(
      post({ lat: 50, lng: 14 }),
      deps({ getEntitlement: () => Promise.resolve({ plan: "premium", valid_until: "2026-01-01T00:00:00Z" }) }),
    )).status,
    402,
  );
  assertEquals((await handleWeather(post({ lat: 50, lng: 14 }), deps({ config: null }))).status, 503);
});

Deno.test("rejects bad input and upstream failures", async () => {
  assertEquals((await handleWeather(post({ lat: 120, lng: 14 }), deps())).status, 400);
  assertEquals((await handleWeather(post({ lat: "50", lng: 14 }), deps())).status, 400);
  assertEquals(
    (await handleWeather(
      new Request("http://localhost/weather", { method: "GET" }),
      deps(),
    )).status,
    405,
  );
  assertEquals(
    (await handleWeather(
      post({ lat: 50, lng: 14 }),
      deps({ fetch: () => Promise.resolve(new Response("nope", { status: 500 })) }),
    )).status,
    502,
  );
  assertEquals(
    (await handleWeather(post({ lat: 50, lng: 14 }), deps({ fetch: () => Promise.reject(new Error("dns")) }))).status,
    502,
  );
  assertEquals(
    (await handleWeather(
      post({ lat: 50, lng: 14 }),
      deps({ fetch: () => Promise.resolve(new Response(JSON.stringify({ daily: {} }), { status: 200 })) }),
    )).status,
    502,
  );
});

Deno.test("provider config and normalization", () => {
  assertEquals(providerConfig(() => undefined), null);
  assertEquals(providerConfig((n) => (n === "WEATHER_API_URL" ? " https://x/forecast " : undefined)), {
    url: "https://x/forecast",
    apiKey: undefined,
  });
  assertEquals(new URL(buildUrl({ url: "https://x/forecast" }, 49.999, 14.0)).searchParams.has("apikey"), false);
  assertEquals(normalize({ daily: { time: ["bad"] } }), null);
  assertEquals(normalize(null), null);
});
