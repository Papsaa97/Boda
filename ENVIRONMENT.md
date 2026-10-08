# ENVIRONMENT

| Nástroj | Verze |
| --- | --- |
| Flutter | 3.47.6 (stable) |
| Dart | 3.13.5 |

Ověřeno: `flutter analyze` bez nálezů, `flutter test` zelený, `flutter build web` projde.

## Platformy
* **Android / iOS** – plná funkčnost včetně fotek. iOS má v `Info.plist` popisky oprávnění pro fotoaparát a galerii.
* **Web** – deník, zóny, úkoly a dashboard fungují (Drift přes SQLite ve WebAssembly: `web/sqlite3.wasm` a `web/drift_worker.js`, data v OPFS nebo IndexedDB). Fotky, záloha a připomínky jsou vypnuté.
* **Android** – připomínky potřebují `POST_NOTIFICATIONS` (Android 13+, aplikace se zeptá až při prvním úkolu s připomínkou) a core library desugaring v `android/app/build.gradle.kts`.

## CI
GitHub Actions (`.github/workflows/ci.yml`) na každý push a PR spustí `flutter analyze` a `flutter test`.

## Nastavení vývojového prostředí

1. Nainstalovat Flutter ve verzi z tabulky výše (doporučeno přes [FVM](https://fvm.app/), aby šlo snadno přepínat verze: `fvm use 3.47.6`).
2. Android: Android Studio (SDK, emulátor) nebo fyzický telefon s ladicím režimem. Ověřit `flutter doctor`.
3. iOS: vyžaduje Mac s Xcode a pro vydání Apple Developer Program (99 USD/rok). Do MVP 1.0 není potřeba, iOS build lze později řešit i přes cloudové CI (např. Codemagic).
4. V kořeni repa: `flutter pub get`, pak `flutter run`.
5. Po změně tabulek Drift: `dart run build_runner build --delete-conflicting-outputs` a `dart run drift_dev make-migrations` (snímek schématu do `drift_schemas/`). Po změně textů v `lib/l10n/app_cs.arb`: `flutter gen-l10n`.

## Podpis vydání (Android)

Release build se podepíše klíčem z `android/key.properties`, pokud soubor existuje; jinak se použije ladicí klíč (stačí pro testovací APK z CI). Soubor i klíč **nikdy nepatří do gitu** (jsou v `.gitignore`):

```
storeFile=/cesta/k/upload-keystore.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

Klíč vytvoří Papi (`keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`) a uloží si ho bezpečně mimo repozitář; ztracený upload klíč jde v Google Play resetovat jen přes podporu.

**Referenční zařízení pro výkon (NFR-4):** Android střední třídy se 4 GB RAM; konkrétní model doplnit, až bude k dispozici.

## Identifikátory aplikace

| Platforma | Současná hodnota | Plán |
| --- | --- | --- |
| Dart balíček | `zahradnik_boda` (od MVP 0.2, DECLOG D49) | |
| Android `applicationId` | `cz.zahradnikboda.app` (DECLOG D35) | změnit jde jen **před prvním nahráním na Google Play**, potom už ne |
| iOS bundle ID | `cz.zahradnikboda.app` (DECLOG D35) | |

## Prostředí backendu (od MVP 1.0)

Backend je **Supabase** (DECLOG D24); kód serveru je v `supabase/`, projekty `dev` a `prod` zakládá Papi (návod v [supabase/README.md](supabase/README.md)):

* Dva projekty v regionu EU (Frankfurt, `eu-central-1`): `zahradnik-boda-dev` (bezplatný tarif stačí, při neaktivitě se uspí) a `zahradnik-boda-prod` (placený tarif Pro, aby se neuspal; zapnutý strop útrat). Aktuální ceník ověřit při zakládání.
* Lokální vývoj přes [Supabase CLI](https://supabase.com/docs/guides/local-development) (`supabase start`, potřebuje Docker). Schéma jako SQL migrace v `supabase/migrations/`, Edge Functions v `supabase/functions/`, testy RLS v `supabase/tests/` (`supabase test db`, běží i v CI).
* Aplikace se k backendu připojí jen s `--dart-define=SUPABASE_URL=…` a `--dart-define=SUPABASE_PUBLISHABLE_KEY=…` (nebo `--dart-define-from-file=env/dev.json`, DECLOG D71). Obě hodnoty nejsou tajné, přístup hlídá RLS. Bez nich běží aplikace jen v telefonu; tak ji staví i CI. Flavors `dev`/`prod` přijdou s nahráním do obchodů.
* **Tajné** jsou servisní klíč Supabase (service role), API klíče LLM, RevenueCat a FCM: patří **jen** do secrets Edge Functions (`supabase secrets set`), nikdy do aplikace ani do gitu.
* Další účty, které 1.0 potřebuje (zakládá Papi): Sentry (EU), PostHog (EU), RevenueCat, Google Cloud OAuth klient pro přihlášení Googlem, Apple Developer Program, poskytovatel LLM.

## Co je potřeba k vydání 1.0 (zakládá Papi)

| Krok | Proč | Kde v kódu se napojí |
| --- | --- | --- |
| Projekty Supabase `dev` a `prod`, migrace, funkce, secrets `LLM_*` | účet, synchronizace, Bóďa | `--dart-define` `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`; návod v `supabase/README.md` |
| Šablona e-mailu s `{{ .Token }}`, vlastní SMTP | přihlášení kódem | dashboard Supabase |
| Stránka se zásadami ochrany soukromí | GDPR, obchody | `--dart-define=PRIVACY_POLICY_URL=…` |
| RevenueCat + produkty v Google Play a App Store | Premium (sezóna 2028) | `RevenueCatPurchaseService` (DECLOG D73) |
| Sentry a PostHog (EU) | pády, měření H1–H4 | `crashReporterProvider`, `analyticsSinkProvider` (DECLOG D75) |
| Podpisový klíč Androidu, účet Google Play | vydání na Androidu | `android/key.properties` (mimo git) |
| Apple Developer Program, Mac s Xcode | build a vydání pro iOS | `ios/` (bundle `cz.zahradnikboda.app`), `pod install` na Macu |
| ≥ 10 testerů, test na skutečných telefonech | ověření před vydáním | – |
