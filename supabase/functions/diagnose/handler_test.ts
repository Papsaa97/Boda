import { assertEquals } from "jsr:@std/assert@1";
import type { LlmProvider, LlmRequest } from "../_shared/llm/types.ts";
import { type DiagnoseDeps, handleDiagnose } from "./handler.ts";
import { decodeImage, hasJpegMetadata, isJpeg } from "./image.ts";
import { parseDiagnosis } from "./parse.ts";

const NOW = new Date("2026-10-08T08:00:00Z");

/** Minimální JPEG: SOI, APP0 (JFIF), SOS, data, EOI. */
const CLEAN = new Uint8Array([
  0xff,
  0xd8,
  0xff,
  0xe0,
  0x00,
  0x04,
  0x4a,
  0x46,
  0xff,
  0xda,
  0x00,
  0x02,
  0x11,
  0x22,
  0xff,
  0xd9,
]);
/** Totéž s APP1 (EXIF) před obrazovými daty. */
const WITH_EXIF = new Uint8Array([
  0xff,
  0xd8,
  0xff,
  0xe1,
  0x00,
  0x06,
  0x45,
  0x78,
  0x69,
  0x66,
  0xff,
  0xda,
  0x00,
  0x02,
  0x11,
  0xff,
  0xd9,
]);

function b64(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes));
}

function provider(text: string, seen: LlmRequest[] = []): LlmProvider {
  return {
    name: "fake",
    complete(request) {
      seen.push(request);
      return Promise.resolve({ text, inputTokens: 1000, outputTokens: 200, stopReason: "end" });
    },
  };
}

const ANSWER = JSON.stringify({
  unclear: false,
  candidates: [
    { label: "Plíseň bramborová", reason: "hnědé skvrny", check: "spodní strana listů", care: "odstranit listy" },
    { label: "Spála", reason: "okraje" },
    { label: "Sucho" },
    { label: "Čtvrtá" },
  ],
});

function deps(opts: Partial<DiagnoseDeps> & { calls?: string[] } = {}): DiagnoseDeps {
  return {
    authenticate: () => Promise.resolve({ userId: "u1" }),
    getEntitlement: () => Promise.resolve({ plan: "premium", valid_until: null }),
    hasPhotoConsent: () => Promise.resolve(true),
    reserve: (_u, _p, limit) => {
      opts.calls?.push("reserve");
      return Promise.resolve({ allowed: true, used: 1 + 0 * limit });
    },
    settle: (_u, _p, _c, refund) => {
      opts.calls?.push(refund ? "refund" : "settle");
      return Promise.resolve(1);
    },
    provider: provider(ANSWER),
    pricing: { inputUsdPerMTok: null, outputUsdPerMTok: null },
    env: () => undefined,
    now: () => NOW,
    log: () => {},
    ...opts,
  };
}

function post(body: unknown): Request {
  return new Request("http://localhost/diagnose", {
    method: "POST",
    body: JSON.stringify(body),
    headers: { Authorization: "Bearer t" },
  });
}

Deno.test("image checks: JPEG and metadata", () => {
  assertEquals(isJpeg(CLEAN), true);
  assertEquals(isJpeg(new Uint8Array([0x89, 0x50, 0x4e, 0x47, 0, 0])), false);
  assertEquals(hasJpegMetadata(CLEAN), false);
  assertEquals(hasJpegMetadata(WITH_EXIF), true);
  assertEquals(decodeImage("not base64!"), null);
  assertEquals(decodeImage(b64(CLEAN)), CLEAN);
});

Deno.test("parse keeps at most three candidates and drops junk", () => {
  const d = parseDiagnosis("```json\n" + ANSWER + "\n```");
  assertEquals(d.candidates.length, 3);
  assertEquals(d.candidates[0].label, "Plíseň bramborová");
  assertEquals(d.unclear, false);
  assertEquals(parseDiagnosis("nevím").unclear, true);
  assertEquals(parseDiagnosis('{"candidates":[{"label":""}]}').candidates, []);
});

Deno.test("returns candidates and sends the image to the model", async () => {
  const seen: LlmRequest[] = [];
  const calls: string[] = [];
  const res = await handleDiagnose(
    post({ image: b64(CLEAN), zoneType: "vegetable", note: "  rajčata\n " }),
    deps({ provider: provider(ANSWER, seen), calls }),
  );
  assertEquals(res.status, 200);
  const body = await res.json();
  assertEquals(body.candidates.length, 3);
  assertEquals(body.usage, { used: 1, limit: 300, plan: "premium" });
  assertEquals(seen[0].messages[0].images?.[0].mediaType, "image/jpeg");
  assertEquals(seen[0].messages[0].text.includes("zeleninový záhon"), true);
  assertEquals(seen[0].messages[0].text.includes("rajčata"), true);
  assertEquals(calls, ["reserve", "settle"]);
});

Deno.test("refuses without account, Premium, consent or a clean JPEG", async () => {
  const body = { image: b64(CLEAN) };
  assertEquals((await handleDiagnose(post(body), deps({ authenticate: () => Promise.resolve(null) }))).status, 401);
  assertEquals(
    (await handleDiagnose(post(body), deps({ getEntitlement: () => Promise.resolve({ plan: "free" }) }))).status,
    402,
  );
  assertEquals((await handleDiagnose(post(body), deps({ hasPhotoConsent: () => Promise.resolve(false) }))).status, 403);
  assertEquals((await handleDiagnose(post(body), deps({ provider: null }))).status, 503);
  assertEquals((await handleDiagnose(post({ image: "eA==" }), deps())).status, 400);
  const exif = await handleDiagnose(post({ image: b64(WITH_EXIF) }), deps());
  assertEquals(exif.status, 400);
  assertEquals((await exif.json()).error, "metadata_present");
});

Deno.test("limit and upstream failure", async () => {
  const limited = await handleDiagnose(
    post({ image: b64(CLEAN) }),
    deps({ reserve: () => Promise.resolve({ allowed: false, used: 300 }) }),
  );
  assertEquals(limited.status, 429);
  const calls: string[] = [];
  const failing: LlmProvider = { name: "fake", complete: () => Promise.reject(new Error("boom")) };
  const res = await handleDiagnose(post({ image: b64(CLEAN) }), deps({ provider: failing, calls }));
  assertEquals(res.status, 502);
  assertEquals(calls, ["reserve", "refund"]);
});
