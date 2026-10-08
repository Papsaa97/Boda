# ENVIRONMENT

| Nástroj | Verze |
| --- | --- |
| Flutter | 3.47.6 (stable) |
| Dart | 3.13.5 |

Ověřeno: `flutter analyze` bez nálezů, `flutter test` zelený, `flutter build web` projde.

## Platformy
* **Android / iOS** – plná funkčnost včetně fotek. iOS má v `Info.plist` popisky oprávnění pro fotoaparát a galerii.
* **Web** – deník, zóny a dashboard fungují (Hive ukládá do IndexedDB), fotky jsou vypnuté.

## CI
GitHub Actions (`.github/workflows/ci.yml`) na každý push a PR spustí `flutter analyze` a `flutter test`.

## Nastavení vývojového prostředí

1. Nainstalovat Flutter ve verzi z tabulky výše (doporučeno přes [FVM](https://fvm.app/), aby šlo snadno přepínat verze: `fvm use 3.47.6`).
2. Android: Android Studio (SDK, emulátor) nebo fyzický telefon s ladicím režimem. Ověřit `flutter doctor`.
3. iOS: vyžaduje Mac s Xcode a pro vydání Apple Developer Program (99 USD/rok). Do MVP 1.0 není potřeba, iOS build lze později řešit i přes cloudové CI (např. Codemagic).
4. V kořeni repa: `flutter pub get`, pak `flutter run`.
5. Po změně Hive modelů nebo mockovaných tříd: `dart run build_runner build --delete-conflicting-outputs`.

**Referenční zařízení pro výkon (NFR-4):** Android střední třídy se 4 GB RAM; konkrétní model doplnit, až bude k dispozici.

## Identifikátory aplikace

| Platforma | Současná hodnota | Plán |
| --- | --- | --- |
| Dart balíček | `zahradnik_boda_mvp01` | `zahradnik_boda` (MVP 0.2) |
| Android `applicationId` | `cz.zahradnikboda.app` (DECLOG D35) | změnit jde jen **před prvním nahráním na Google Play**, potom už ne |
| iOS bundle ID | `cz.zahradnikboda.app` (DECLOG D35) | |

## Prostředí backendu (od MVP 1.0)

Zatím žádný backend není. Backend bude **Supabase** (DECLOG D24):

* Dva projekty v regionu EU (Frankfurt, `eu-central-1`): `zahradnik-boda-dev` (bezplatný tarif stačí, při neaktivitě se uspí) a `zahradnik-boda-prod` (placený tarif Pro, aby se neuspal; zapnutý strop útrat). Aktuální ceník ověřit při zakládání.
* Lokální vývoj přes [Supabase CLI](https://supabase.com/docs/guides/local-development) (`supabase start`, potřebuje Docker). Schéma jako SQL migrace v `supabase/migrations/`, Edge Functions v `supabase/functions/`, testy RLS v `supabase/tests/` (`supabase test db`, běží i v CI).
* Přepínání prostředí přes Flutter flavors (`dev`, `prod`); URL projektu a veřejný (publishable) klíč se předávají přes `--dart-define-from-file` a nejsou tajné, protože přístup hlídá RLS.
* **Tajné** jsou servisní klíč Supabase (service role), API klíče LLM, RevenueCat a FCM: patří **jen** do secrets Edge Functions (`supabase secrets set`), nikdy do aplikace ani do gitu.
* Další účty, které 1.0 potřebuje (zakládá Papi): Sentry (EU), PostHog (EU), RevenueCat, Google Cloud OAuth klient pro přihlášení Googlem, Apple Developer Program, poskytovatel LLM.
