# Supabase – backend Zahradníka Bódi

Serverová část od MVP 1.0 (spec kap. 7.1, 7.4, 8.1, 9; DECLOG D24–D32).
Aplikace bez účtu backend nepotřebuje; ten se používá až pro zálohu,
synchronizaci, Bóďu a platby.

| Složka | Co v ní je |
| --- | --- |
| `config.toml` | nastavení pro lokální vývoj (`supabase start`, `supabase test db`); žádná tajemství |
| `migrations/` | schéma databáze, pravidla RLS, bucket `photos`, funkce pro backend |
| `tests/` | testy pravidel a triggerů (pgTAP), běží v CI |
| `functions/` | Edge Functions `boda-chat`, `revenuecat-webhook`, `delete-account` (+ sdílený kód v `_shared/`) |

## 1. Co potřebuješ v počítači

- [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started) a Docker Desktop (jen pro lokální běh),
- [Deno 2](https://docs.deno.com/runtime/getting_started/installation/) (jen pro testy funkcí).

Lokálně: `supabase start` (celý Supabase v Dockeru), `supabase test db` (testy
databáze), v `supabase/functions` pak `deno test --allow-env`.

## 2. Založení projektů `dev` a `prod`

1. Na [supabase.com/dashboard](https://supabase.com/dashboard) → **New project**.
2. Název `zahradnik-boda-dev` (a později `zahradnik-boda-prod`), region
   **Central EU (Frankfurt)**, silné heslo databáze → ulož do správce hesel.
3. `prod` musí být na placeném tarifu **Pro** (bezplatný projekt se při
   neaktivitě uspí). `dev` může být Free.
4. **Settings → Legal Documents**: podepsat DPA (zpracovatelská smlouva, GDPR).

## 3. Propojení a nahrání schématu

V kořeni repozitáře (ID projektu najdeš v URL dashboardu nebo v
**Project Settings → General → Project ID**):

```bash
supabase login
supabase link --project-ref <ID-projektu-dev>
supabase db push            # nahraje všechny migrace ze supabase/migrations
```

Pro `prod` totéž s jeho ID. Vždy nejdřív `dev`, ověřit, pak `prod`.
Migrace se nikdy needitují zpětně; změna = nový soubor v `migrations/`.

## 4. Tajné klíče (secrets) pro Edge Functions

`SUPABASE_URL`, `SUPABASE_ANON_KEY` a `SUPABASE_SERVICE_ROLE_KEY` vkládá
Supabase sám. Ty nastavuješ jen tyto (hodnoty nikdy do gitu ani do chatu):

| Název | Povinné | Význam |
| --- | --- | --- |
| `LLM_API_KEY` | ano | API klíč poskytovatele jazykového modelu |
| `LLM_MODEL` | ano | přesný název modelu (je jen tady, v kódu žádný není) |
| `LLM_PROVIDER` | ne | poskytovatel, výchozí `anthropic` |
| `REVENUECAT_WEBHOOK_SECRET` | ano | tajný token webhooku plateb (vygeneruj `openssl rand -hex 32`) |
| `LLM_MAX_TOKENS` | ne | strop výstupních tokenů na dotaz (výchozí 8000) |
| `LLM_PRICE_INPUT_USD_PER_MTOK`, `LLM_PRICE_OUTPUT_USD_PER_MTOK` | ne | ceník modelu v USD za milion tokenů; bez něj se náklad na dotaz nezapisuje |
| `BODA_LIMIT_FREE`, `BODA_LIMIT_PREMIUM` | ne | změna měsíčních limitů dotazů (výchozí 10 a 300) |
| `LLM_BASE_URL` | ne | jiná adresa API poskytovatele (proxy, regionální endpoint) |
| `WEATHER_API_URL` | pro počasí | adresa denní předpovědi ve tvaru Open-Meteo (`…/v1/forecast`) u poskytovatele s licencí pro komerční aplikaci |
| `WEATHER_API_KEY` | ne | klíč placeného tarifu poskytovatele počasí (posílá se jako `apikey`) |

Nejbezpečněji přes soubor, ať klíče nezůstanou v historii příkazů:

```bash
# supabase/.env.dev (soubor NENÍ v gitu), řádky NAZEV=hodnota pro názvy výše
supabase secrets set --env-file supabase/.env.dev
supabase secrets list       # ukáže jen názvy, ne hodnoty
```

Bez `LLM_API_KEY`/`LLM_MODEL` Bóďa odpovídá `503 not_configured`, zbytek funguje.
Bez `WEATHER_API_URL` odpovídá `503` i funkce `weather`; aplikace pak počasí
neukáže, kalendář prací funguje dál.

## 5. Nasazení funkcí

```bash
supabase functions deploy boda-chat
supabase functions deploy weather
supabase functions deploy diagnose
supabase functions deploy delete-account
supabase functions deploy revenuecat-webhook --no-verify-jwt
```

Webhook má vlastní ověření tokenem, proto `--no-verify-jwt`.
Logy: dashboard → **Edge Functions → (funkce) → Logs**. U každého dotazu na
Bóďu je řádek `boda_chat` s počtem tokenů a cenou.

## 6. Přihlášení (Authentication)

Dashboard → **Authentication**:

- **URL Configuration**: do *Redirect URLs* přidat `cz.zahradnikboda.app://login-callback`.
- **Sign In / Providers → Email**: zapnout. Přihlášení bez hesla jednorázovým kódem:
  v **Emails → Templates → Magic Link** dát do textu kód `{{ .Token }}` (6 číslic) místo odkazu.
  **Bez toho se do aplikace nejde přihlásit**: aplikace čeká na kód, ne na odkaz (DECLOG D71).
  Vlastní SMTP (**Emails → SMTP Settings**) je pro produkci nutný, vestavěný posílá jen pár e-mailů za hodinu.
- **Google**: v Google Cloud Console vytvořit OAuth klienty *Web*, *Android* (balíček
  `cz.zahradnikboda.app` + SHA-1 podpisového klíče) a *iOS*. V Supabase u Google zadat
  Client ID a Secret webového klienta a do *Authorized Client IDs* přidat i Android a iOS ID
  (nativní přihlášení přes `signInWithIdToken`).
- **Apple**: v Apple Developer zapnout *Sign in with Apple* pro `cz.zahradnikboda.app`;
  v Supabase u Apple přidat `cz.zahradnikboda.app` do *Client IDs*.
- **Attack Protection**: zapnout CAPTCHA (hCaptcha nebo Turnstile) – spec kap. 9.
- Anonymní přihlášení nechat **vypnuté** (host pracuje jen v telefonu).

## 7. RevenueCat (platby)

RevenueCat → projekt → **Integrations → Webhooks → Add**:

- URL: `https://<ID-projektu>.supabase.co/functions/v1/revenuecat-webhook`
- Authorization header value: `Bearer <hodnota REVENUECAT_WEBHOOK_SECRET>`
- Prostředí: pro `dev` sandbox i produkce, pro `prod` jen produkce.

Aplikace po přihlášení volá `Purchases.logIn(<id uživatele ze Supabase>)`,
takže `app_user_id` = `auth.users.id`. Nákup, obnova, změna produktu, prodloužení
a obnovení zrušeného předplatného nastaví Premium do konce předplaceného období;
zrušení (`CANCELLATION`) nechá Premium do konce zaplaceného období; `EXPIRATION` vrátí Free.
Ověření: v RevenueCat tlačítko *Send test event* → odpověď 200.

## 8. Stropy útrat (spec kap. 9)

- **Supabase**: Organization → **Billing → Spend Cap** nechat **zapnutý**.
- **Poskytovatel LLM**: v jeho konzoli nastavit měsíční limit útraty
  (a upozornění e-mailem při 50 % a 80 %). Bóďa navíc hlídá limity na uživatele
  (Free 10 dotazů měsíčně, Premium 300).
- U poskytovatele LLM ověřit smlouvu o zpracování (DPA), zpracování v EU a
  že data (i fotky pro diagnostiku) nejdou na trénink.

## Rozhraní funkcí (pro aplikaci)

Všechny odpovídají JSONem. Volání z aplikace přes `supabase.functions.invoke(...)`
(posílá hlavičku `Authorization: Bearer <JWT>` sama).

**`POST /functions/v1/boda-chat`** – přihlášený uživatel.
Požadavek: `{"question": "...", "context": {"garden": {...}, "zones": [...], "recentActivities": [...], "openTasks": [...], "inventory": [...], "calculations": [{"label", "result", "source"}]}, "history": [{"role": "user"|"assistant", "text": "..."}]}`.
Odpověď 200: `{"answer": "...", "actions": [...], "usage": {"used", "limit", "plan"}}`.
Chyby: 400 `bad_request`, 401 `unauthorized`, 405, 429 `limit_reached` (+ `usage`),
502 `upstream`, 503 `not_configured`, 500 `internal`.
Do modelu jdou jen povolená pole kontextu (viz `functions/boda-chat/context.ts`),
název zahrady, jména a e-maily ne.

**`POST /functions/v1/diagnose`** – přihlášený uživatel s Premium a souhlasem
`consents.photoUpload` v profilu.
Požadavek: `{"image": "<JPEG v base64, max 3 MB, bez EXIF>", "zoneType": "vegetable"|…, "note": "..."}`.
Odpověď 200: `{"unclear": false, "candidates": [{"label", "reason", "check", "care"}], "usage": {"used", "limit", "plan"}}`
(nejvýš 3 kandidáti, bez chemie a dávek). Čerpá ze stejného limitu jako Bóďa.
Chyby: 400 `bad_request` / `bad_image` / `metadata_present`, 401, 402 `premium_required`,
403 `consent_required`, 405, 429 `limit_reached`, 502 `upstream` (dotaz se vrátí),
503 `not_configured`. Fotka se nikde neukládá.

**Sdílení zahrady** – RPC (ne funkce): `create_garden_invite(p_garden_id)` →
`{code, expires_at}` (jen vlastník s Premium; chyby `not_owner`, `premium_required`),
`accept_garden_invite(p_code)` → id zahrady (chyba `invalid_invite`),
`garden_member_list(p_garden_id)` → členové s rolí, jménem a e-mailem (jen pro členy).
Odebrání člena je `delete` z `garden_members` (vlastník kohokoli kromě sebe, člen sebe).

**`POST /functions/v1/delete-account`** – přihlášený uživatel; smaže jeho účet.
Zahrady s dalšími členy předá (nejdéle přítomný editor, jinak jiný člen), ostatní
smaže i s fotkami. Odpověď 200 `{"deleted": true}`.

**`POST /functions/v1/revenuecat-webhook`** – jen RevenueCat (Bearer token).
Odpověď 200 `{"ok": true, "result": "applied"|"duplicate"|"stale"|"unknown_user"}`
nebo `{"ok": true, "ignored": "..."}`.

## Synchronizace (pro aplikaci)

- Odesílání: jedno volání `rpc('sync_push', {p_changes})` se všemi změněnými řádky
  (`{"gardens": [...], "zones": [...], ..., "deleted": [{"table", "key", "at"}]}`)
  v jedné transakci s odloženou kontrolou cizích klíčů (úkoly a záznamy na sebe
  odkazují oběma směry). Uvnitř je `upsert` podle `id` (u `activity_materials` a
  `task_materials` podle dvojice klíčů); starší zápis (menší `updated_at` než na
  serveru) server tiše zahodí. `deleted` řádek měkce smaže (zahradu ne).
  Funkce běží s právy volajícího, takže RLS platí beze změny (test `06_sync_push`).
- Stahování po tabulkách: `garden_id = X and server_updated_at > poslední order by server_updated_at limit N`.
  Kvůli souběžným transakcím doporučeno stahovat s malým překryvem (např. o 1 minutu zpět)
  a duplicity ignorovat – upsert je idempotentní.
- Mazání je jen měkké (`deleted_at`); fyzicky maže jen backend při smazání zahrady/účtu.
- Fotky: soubory do bucketu `photos` jako `<gardenId>/<photoId>.jpg` a
  `<gardenId>/<photoId>_thumb.jpg`; stejné cesty musí být v `photos.storage_path` a `thumb_path`.
