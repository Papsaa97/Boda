# 🪴 Zahradník Bóďa

Mobilní aplikace, která vede **deník a digitální model zahrady** a nad ním nabízí asistenta **Bóďu**: radí, *co, kde, kdy, kolik a čím* udělat právě na tvém záhonu.

> *Vrátit do zahradničení radost a klid místo stresu a nejistoty.*

## Kde je projekt teď

| Fáze | Stav |
| --- | --- |
| **MVP 0.1 – Offline deník** | ✅ implementováno |
| **MVP 0.2 – Spolehlivý deník** (export/import, úkoly, rychlý zápis) | ✅ implementováno, k testerům do konce února 2027 |
| Sezóna 2027 – validace „vydrží lidé zapisovat?“ | ○ |
| MVP 1.0 – Chytrý parťák (účet, synchronizace, Bóďa) | ◐ rozpracováno: zahrada, sklad a úkoly s materiálem hotové (DECLOG D50) |
| MVP 1.1 – 2D plátno, V2, V3 | ○ |

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
* ✅ **Offline-first:** data i fotky zůstávají na zařízení (SQLite přes Drift + složka aplikace). Žádný backend. Data z verze 0.1 se při prvním spuštění jednorázově převedou.

Na webu funguje vše kromě fotek, zálohy a připomínek (prohlížeč nemá trvalé úložiště souborů ani plánované notifikace).

## Architektura a Technologie
* **Framework:** Flutter (Android, iOS, Web)
* **Architektura:** Feature-first Clean Architecture (Domain / Data / Presentation)
  * `features/activity` – záznamy deníku
  * `features/zones` – zóny
  * `features/tasks` – úkoly, opakování, plán připomínek
  * `features/inventory` – sklad a nákupní seznam
  * `features/backup` – export a import ZIP
  * `features/settings`, `features/stats` – nastavení a statistiky pro testery
  * `features/dashboard` – „Co dnes?“ a tipy od Bódi
  * `features/onboarding` – první spuštění, výběr zón
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
3. `flutter run`

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
*Verze: 0.2.0*
