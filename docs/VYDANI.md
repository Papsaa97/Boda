# Vydání 1.0: co je hotové a co zbývá udělat ručně

Kód aplikace je hotový pro všechny fáze roadmapy (MVP 0.1 až V3) a připravený k vydání: identita `cz.zahradnikboda.app`, ikona, úvodní obrazovka, podepisování release buildu, napojení Sentry/PostHog/RevenueCat přes klíče, zásady soukromí a texty do obchodů. Tenhle seznam je **jediné místo**, kde jsou kroky, které potřebují účty a ruce Papiho. Postupně se odškrtává.

Kde co je: klíče jdou do `env/prod.json` (vzor `env.example.json`, složka `env/` není v gitu), tajné klíče serveru do Supabase secrets, podpisový klíč mimo repozitář.

## A. Backend pro ostrý provoz

- [ ] **Projekt Supabase `prod`** (Pro tarif, cca 25 USD/měsíc, Frankfurt, zapnutý strop útrat). Postup stejný jako u dev (`supabase/README.md`, DECLOG D93): migrace 0000 až 1000, pět Edge Functions s `--no-verify-jwt` (D94), secrets `LLM_PROVIDER`, `LLM_MODEL`, `LLM_API_KEY`, `WEATHER_API_URL`, `WEATHER_API_KEY`, `REVENUECAT_WEBHOOK_SECRET`.
- [ ] **Vlastní doména a SMTP pro přihlašovací kódy** (Free tarif Supabase posílá jen pár e-mailů za hodinu a jen testerům): doména (např. `zahradnikboda.cz`, cca 300 Kč/rok) + Resend (zdarma do 3 000 e-mailů měsíčně); v Supabase Auth → SMTP settings; šablona „Magic link“ s `{{ .Token }}` (D71). Na stejnou doménu dát zásady soukromí.
- [ ] **Poskytovatel počasí s licencí pro komerční použití** (bezplatné Open-Meteo je jen pro nekomerční; placený tarif Open-Meteo od cca 29 EUR/měsíc) → secrets `WEATHER_API_URL`, `WEATHER_API_KEY` (D85).
- [ ] **Limit útraty u poskytovatele LLM** (Anthropic Console → Limits) a kontrola, že klíč patří do workspace (D93).
- [ ] CAPTCHA u přihlášení e-mailem (Supabase Auth → Bot and Abuse Protection, Turnstile zdarma), až bude aplikace veřejná.

## B. Zásady soukromí a účty

- [ ] Doplnit `[…]` v `docs/ZASADY_SOUKROMI.md` (správce, kontakt, poskytovatel LLM a jeho umístění, poskytovatel e-mailů) a zveřejnit na `https://zahradnikboda.cz/soukromi` (nebo změnit `PRIVACY_POLICY_URL` v `env/prod.json`).
- [ ] **Sentry** (EU region, Free tarif stačí) → `SENTRY_DSN`.
- [ ] **PostHog** (EU cloud, Free tarif stačí) → `POSTHOG_API_KEY`; `POSTHOG_HOST` nechat `https://eu.i.posthog.com`.
- [ ] **RevenueCat** (zdarma do 2 500 USD měsíčního obratu): projekt, aplikace Android + iOS, produkty `premium_yearly` (449 Kč) a `premium_monthly` (69 Kč) v Google Play Console a App Store Connect, offering `default` s balíčky `$rc_annual` a `$rc_monthly`, 7denní zkušební období, entitlement `premium`; webhook na Edge Function `revenuecat-webhook` s tajemstvím `REVENUECAT_WEBHOOK_SECRET` → `REVENUECAT_ANDROID_KEY`, `REVENUECAT_IOS_KEY`. Platby se podle plánu spouštějí až na sezónu 2028, do té doby stačí nechat klíče prázdné: nabídka Premium se ukáže, koupit nejde.

## C. Android (Google Play)

- [ ] **Účet vývojáře Google Play** (jednorázově 25 USD). Nové osobní účty musí před vydáním projít uzavřeným testem s ≥ 12 testery po 14 dní.
- [ ] **Podpisový klíč**: na PC v `C:\dev\secrets\`:
  `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
  a soubor `C:\dev\Boda\android\key.properties` (vzor v `ENVIRONMENT.md`, cesta `storeFile=C:/dev/secrets/upload-keystore.jks`). Klíč zálohovat na dvě místa; bez něj nejde vydat aktualizaci.
- [ ] **Build**: v `C:\dev\Boda` spustit
  `C:\dev\flutter-3.47.6\bin\flutter build appbundle --release --dart-define-from-file=env/prod.json`
  → `build\app\outputs\bundle\release\app-release.aab`. (APK pro testery z CI je podepsaný ladicím klíčem a do obchodu nejde.)
- [ ] V Google Play Console: nová aplikace „Zahradník Bóďa“, čeština, bezplatná; texty z `docs/TEXTY_OBCHODU.md`; ikona 512×512 z `assets/brand/icon-1024.png` (zmenšit); 2 až 8 snímků telefonu (min. 320 px, max. 3840 px, poměr do 2:1; `/mnt/project-files/boda-screenshots/` mají 780×1688 a jdou použít); hlavní grafika 1024×500 (vytvořit, např. v Canvě z ikony a názvu); dotazník IARC; Bezpečnost dat podle tabulky v `TEXTY_OBCHODU.md`; odkaz na zásady soukromí; odkaz na smazání účtu (stačí stránka na doméně s postupem „Nastavení → Účet → Smazat účet“ a e-mail).
- [ ] Interní test → uzavřený test (12 testerů, 14 dní) → produkce.

## D. iOS (App Store)

- [ ] **Apple Developer Program** (99 USD/rok) a **Mac s Xcode** (nebo cloudové CI, např. Codemagic; bez Macu iOS vydat nejde).
- [ ] Na Macu: `flutter build ipa --release --dart-define-from-file=env/prod.json` (první spuštění vytvoří `ios/Podfile` a stáhne CocoaPods), v Xcode nastavit Team a automatické podepisování, bundle `cz.zahradnikboda.app`.
- [ ] App Store Connect: aplikace, texty a klíčová slova z `TEXTY_OBCHODU.md`, snímky 6,7" (1290×2796) a 6,5" (1284×2778), ikona se bere z buildu, nutrition label, odkaz na zásady, zdůvodnění oprávnění (fotoaparát, fotky, poloha) je už v `Info.plist`. Účet jde smazat v aplikaci (Apple to vyžaduje).
- [ ] TestFlight pro testery, pak review.

## E. Testování před vydáním

- [ ] Nainstalovat release build na vlastní Android přes USB (`flutter install --release --dart-define-from-file=env/prod.json` nebo APK z CI) a projít: onboarding, záznam s fotkou, úkol s připomínkou, záloha a obnova, přihlášení kódem, synchronizace na druhém zařízení, Bóďa, počasí, diagnostika z fotky, plán, stavba, smazání účtu.
- [ ] Režim letadlo: deník, úkoly, sklad, plán fungují bez signálu.
- [ ] 10 až 30 testerů ze známých (spec 11.3), nejlépe ještě v této sezóně; sledovat H1 (zapisují lidé dál po 4 týdnech?).

## F. Rozhodnutí, která zbývají

- [ ] Jsou návrhy staveb (V3) zdarma, nebo v Premium? Teď zdarma (D90).
- [ ] Push notifikace přes FCM (upozornění na mráz se zavřenou aplikací) ano/ne; zatím jen karta na „Dnes“ (D85).
- [ ] Název poskytovatele LLM a jeho umístění do zásad soukromí (dev používá Anthropic, USA).

## Verze

Číslo verze je v `pubspec.yaml` (`version: 1.0.0+3`): před každým nahráním do obchodu zvýšit číslo za `+` (build), při nových funkcích i verzi před ním. Obchody odmítnou stejné číslo buildu podruhé.
