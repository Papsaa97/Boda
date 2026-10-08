# 🪴 Zahradník Bóďa

Mobilní aplikace, která vede **deník a digitální model zahrady** a nad ním nabízí asistenta **Bóďu**: radí, *co, kde, kdy, kolik a čím* udělat právě na tvém záhonu.

> *Vrátit do zahradničení radost a klid místo stresu a nejistoty.*

## Kde je projekt teď

| Fáze | Stav |
| --- | --- |
| **MVP 0.1 – Offline deník** | ✅ implementováno |
| **MVP 0.2 – Spolehlivý deník** (export/import, úkoly, rychlý zápis) | ✅ implementováno, k testerům do konce února 2027 |
| Sezóna 2027 – validace „vydrží lidé zapisovat?“ | ○ |
| MVP 1.0 – Chytrý parťák (účet, synchronizace, Bóďa) | ✅ kód hotový (DECLOG D50, D60, D69, D73–D76); vydání čeká na účty (Supabase, AI, RevenueCat, obchody) a testy na zařízeních |
| MVP 1.1 – 2D plátno | ✅ kód hotový (DECLOG D77–D81); 60 fps s 300 uzly ověřit na telefonu |
| V2 – Počasí, diagnostika, sdílení | ✅ kód hotový: odpis ze skladu, incidenty, počasí, zálivka, kalendář prací, diagnostika z fotek, sdílení v rodině (DECLOG D82–D89); čeká na poskytovatele počasí a klíč k AI |
| V3 – Parametrické návrhy | ○ |

Celá roadmapa s definicí hotovo je ve [specifikaci, kap. 4](docs/SPECIFIKACE.md#4-roadmapa-a-rozsah-fází).

## Dokumentace

| Soubor | Obsah |
| --- | --- |
| [docs/SPECIFIKACE.md](docs/SPECIFIKACE.md) | Produktová a technická specifikace (v2.2) |
| [DECLOG.md](DECLOG.md) | Deník rozhodnutí: co, proč, dopad |
| [NAPADNIK.md](NAPADNIK.md) | Nápady mimo aktuální fázi |
| [COLLAB_WORKFLOW.md](COLLAB_WORKFLOW.md) | Jak spolu pracujeme (role, větve, PR) |
| [CODE_REVIEW_CHECKLIST.md](CODE_REVIEW_CHECKLIST.md) | Co kontrolovat v review |
| [ENVIRONMENT.md](ENVIRONMENT.md) | Verze nástrojů, platformy, nastavení prostředí |

---

## MVP 0.2 – Spolehlivý deník

Jednoduchý, **100% offline deník** bez účtu, 2D plátna a AI. Verze 0.2 přidává
všechno, co je potřeba, aby se na deník dalo spolehnout celou sezónu.

## Funkce
* ✅ **Výběr zón:** při prvním spuštění „Co pěstuješ?“ velkými kartami, bez registrace; jde přeskočit.
* ✅ **Co dnes?** Dashboard s hero kartou, dnešními úkoly, statistikou za 7 dní, sezónním tipem od Bódi a připomínkou zálohy.
* ✅ **Záznam aktivity:** typ činnosti (zálivka, hnojení, sklizeň…), název, datum a čas, zóna, poznámka a až 5 fotek (zmenšené na 1 920 px, JPEG 80). Rychlý zápis do 3 ťuknutí s předvyplněnou poslední zónou.
* ✅ **Deník (Timeline):** záznamy seskupené po dnech, filtr podle zóny a typu, fulltextové hledání bez ohledu na diakritiku.
* ✅ **Úkoly:** termín, opakování (týdně, měsíčně, ročně, jen v některých měsících), připomínka s tichými hodinami 21–8, ranní přehled, odložení, splnění rovnou zapíše záznam do deníku.
* ✅ **Zóny:** typ zóny, přejmenování, archivace (historie zůstane), smazání prázdné zóny.
* ✅ **Záloha:** export do ZIP (data + fotky) a import „nahradit vše“; formát je popsaný v [docs/FORMAT_EXPORTU.md](docs/FORMAT_EXPORTU.md). Připomínka zálohy po 30 dnech.
* ✅ **Nastavení:** světlý, tmavý nebo systémový motiv, tiché hodiny, ranní přehled, statistiky pro testery.
* ✅ **Zahrada (1.0):** vlastnosti zón (výměra, půda, pH, oslunění, závlaha, krytí), sklad osiv, hnojiv, přípravků a nářadí s hlídačem zásob, nákupní seznam.
* ✅ **Úkoly v plném rozsahu (1.0):** odhad doby, nářadí, materiál ze skladu, režim „víkend na chalupě“.
* ✅ **Sklizeň a náklady** u záznamu, **přehled sezóny** v zimě.
* ✅ **Bóďa (1.0):** rozhovor nad daty zahrady, dávky hnojiv spočítané z obalu a výměry zóny, „Z čeho vycházím“, varování u dávek mimo výpočet a u chemie, akce (úkol, nákup, záznam), 👍/👎, dotazy bez připojení počkají. Bez účtu a souhlasu běží v ukázkovém režimu bez AI (DECLOG D64, D72).
* ✅ **Účet a synchronizace (1.0):** přihlášení kódem z e-mailu, synchronizace všech dat i fotek mezi telefony (poslední zápis vyhrává), převzetí zahrady z účtu na druhém telefonu, smazání účtu (DECLOG D69–D71). Zapne se jen v buildu s adresou backendu.
* ✅ **Premium a souhlasy (1.0):** nabídka Premium se srovnáním tarifů (platby se spustí v sezóně 2028), obrazovka souhlasů s AI a analytikou, analytika jen se souhlasem (DECLOG D73–D75).
* ✅ **Plán zahrady (1.1):** obrys a zóny jako mnohoúhelníky s přitahováním k mřížce a úpravou uzlů, výměry v m², kalibrace podle známé délky s kontrolní vzdáleností, podklad (fotka plánku), vrstvy Realita a Návrh se „zrealizováním“, zpět/znovu 20 kroků (DECLOG D77–D81).
* ✅ **Sklad s odpisem (V2):** dokončený úkol odepíše materiál ze skladu (převod g/kg, ml/l), vrácený úkol odpis stornuje, u položky je historie pohybů (DECLOG D82).
* ✅ **Problémy na zahradě (V2):** karta incidentu se zónou, fotkami „před a po“, šetrným a chemickým plánem a kontrolami za 3 a 7 dní (DECLOG D83).
* ✅ **Počasí a zálivka (V2, Premium):** srážky za týden a předpověď pro polohu zahrady, návrh odložit zálivku po dešti (i automaticky), varování před mrazem pro čerstvé výsadby (DECLOG D85, D86). Čeká na poskytovatele počasí.
* ✅ **Kalendář prací (V2, zdarma):** výsevy, sázení a řezy pro ČR posunuté podle nadmořské výšky, s přidáním jako úkol (DECLOG D87).
* ✅ **Diagnostika z fotky (V2, Premium):** u problému „Zkusit poznat z fotky“ vrátí 1–3 možnosti s tím, čím je ověřit, a šetrnou péči; fotka se posílá bez polohy a jen se souhlasem (DECLOG D88).
* ✅ **Sdílení zahrady (V2, Premium):** vlastník pozve rodinu kódem, členové zapisují do jedné zahrady, odebrání a opuštění zahrady (DECLOG D89).
* ✅ **Offline-first:** data i fotky jsou vždy v zařízení (SQLite přes Drift + složka aplikace); účet je volitelný a cloud slouží jako záloha a most mezi telefony. Data z verze 0.1 se při prvním spuštění jednorázově převedou.

Na webu funguje vše kromě fotek, zálohy a připomínek (prohlížeč nemá trvalé úložiště souborů ani plánované notifikace).

## Architektura a Technologie
* **Framework:** Flutter (Android, iOS, Web)
* **Architektura:** Feature-first Clean Architecture (Domain / Data / Presentation)
  * `features/activity` – záznamy deníku
  * `features/zones` – zóny
  * `features/canvas` – plán zahrady: geometrie, historie úprav, plátno
  * `features/incidents` – problémy na zahradě, jejich kontroly a diagnostika z fotky
  * `features/sharing` – sdílení zahrady: členové, pozvánky
  * `features/weather` – počasí, zálivka, mráz a fenologický kalendář
  * `features/tasks` – úkoly, opakování, plán připomínek
  * `features/inventory` – sklad a nákupní seznam
  * `features/assistant` – Bóďa: kalkulátor dávek, kontext, bezpečnostní kontrola, rozhovor
  * `features/backup` – export a import ZIP
  * `features/settings`, `features/stats` – nastavení a statistiky pro testery
  * `features/dashboard` – „Co dnes?“ a tipy od Bódi
  * `features/onboarding` – první spuštění, výběr zón
  * `features/account` + `core/sync` – účet, souhlasy, fronta změn a synchronizace se Supabase
  * `features/premium` – tarif, nabídka Premium, rozhraní plateb
  * `core/telemetry` – hlášení pádů a analytika (jen se souhlasem)
* **State Management:** Riverpod 3 (`AsyncNotifier`, zápisy přes `AsyncValue.guard()`)
* **Lokální databáze:** Drift (SQLite), tabulky odpovídají budoucímu schématu Supabase (spec kap. 8). Snímky schématu jsou v `drift_schemas/`.
* **Notifikace:** `flutter_local_notifications`, plán počítá čistá funkce `planReminders` (testovaná)
* **Lokalizace:** ARB (`lib/l10n/app_cs.arb`), generuje `flutter gen-l10n`
* **Backend (od MVP 1.0):** Supabase (PostgreSQL, Auth, Storage, Edge Functions), viz [specifikace, kap. 7](docs/SPECIFIKACE.md#7-architektura)
* **Design:** světlý i tmavý motiv podle specifikace (kap. 10.2); čeština včetně kalendáře
* **Testování:** flutter_test s ručními in-memory fakes a Drift v paměti, CI v GitHub Actions


## Jak spustit
1. Naklonujte repozitář.
2. `flutter pub get`
3. `flutter run` (jen v telefonu, bez účtu a AI)

S backendem (účet, synchronizace, Bóďa s AI):
```
flutter run --dart-define=SUPABASE_URL=https://<projekt>.supabase.co \
            --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable klíč>
```
Obě hodnoty jsou veřejné (přístup hlídá RLS); nastavení projektu popisuje
[supabase/README.md](supabase/README.md).

Vygenerovaný kód (Drift, lokalizace) je v repozitáři. Po změně tabulek v
`lib/core/database/app_database.dart` spusťte
`dart run build_runner build --delete-conflicting-outputs` a novou verzi schématu
uložte `dart run drift_dev make-migrations`. Po změně `lib/l10n/app_cs.arb`
spusťte `flutter gen-l10n`.

## Testy
```
dart format lib test
flutter analyze
flutter test
```
CI na každém PR kontroluje formátování, analýzu a testy a sestaví instalační APK
(ke stažení u běhu v záložce *Actions* jako artefakt `zahradnik-boda-apk`).

---
*Verze: 1.0.0 (kód MVP 1.0; vydání čeká na účty, viz níže)*
