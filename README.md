# 🪴 Zahradník Bóďa

Mobilní aplikace, která vede **deník a digitální model zahrady** a nad ním nabízí asistenta **Bóďu**: radí, *co, kde, kdy, kolik a čím* udělat právě na tvém záhonu.

> *Vrátit do zahradničení radost a klid místo stresu a nejistoty.*

## Kde je projekt teď

| Fáze | Stav |
| --- | --- |
| **MVP 0.1 – Offline deník** | ✅ implementováno, používání autorem na vlastní zahradě |
| MVP 0.2 – Spolehlivý deník (export/import, úkoly, rychlý zápis) | ○ další krok, k testerům do konce února 2027 |
| Sezóna 2027 – validace „vydrží lidé zapisovat?“ | ○ |
| MVP 1.0 – Chytrý parťák (účet, synchronizace, Bóďa) | ○ |
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

## MVP 0.1 – Offline Deník

Cílem této verze je ověřit, jestli lidé budou digitálně zapisovat práci na zahradě.
Proto je to jednoduchý, **100% offline deník** bez 2D plátna a bez AI.

## Funkce (MVP 0.1)
* ✅ **Úvod a výběr zón:** při prvním spuštění „Začít bez registrace“ a výběr zón velkými kartami.
* ✅ **Co dnes?** Dashboard s hero kartou (co je dnes zapsané, nebo kterou zónu dlouho nikdo neviděl), statistikou za 7 dní a sezónním tipem od Bódi.
* ✅ **Záznam aktivity:** název, datum a čas, zóna ze seznamu, poznámka, fotka (fotoaparát nebo galerie). Rychlé volby (Zálivka, Pletí, naposledy použité) zapíšou záznam jedním ťuknutím.
* ✅ **Deník (Timeline):** všechny záznamy od nejnovějšího, seskupené po dnech, s filtrem podle zóny, detailem, úpravou a smazáním.
* ✅ **Zóny:** výběr z nabídky (Zelenina, Okrasná zahrada, Ovocný sad, Trávník, Skleník, Bylinky, Jezírko), vlastní zóny lze přidat, přejmenovat i smazat.
* ✅ **Tip od Bódi:** statické sezónní tipy podle měsíce, každý den jiný.
* ✅ **Offline-first:** data i fotky zůstávají na zařízení (Hive + složka aplikace). Žádný backend.

Na webu funguje vše kromě fotek (prohlížeč nemá trvalé lokální úložiště souborů).

## Architektura a Technologie
* **Framework:** Flutter (Android, iOS, Web)
* **Architektura:** Feature-first Clean Architecture (Domain / Data / Presentation)
  * `features/activity` – záznamy deníku
  * `features/zones` – seznam zón
  * `features/dashboard` – „Co dnes?“ a tipy od Bódi
  * `features/onboarding` – úvodní obrazovka a výběr zón
* **State Management:** Riverpod (`AsyncNotifier`, zápisy přes `AsyncValue.guard()`)
* **Lokální Databáze:** Hive (v MVP 0.2 přechod na Drift / SQLite, DECLOG D26)
* **Backend (od MVP 1.0):** Supabase (PostgreSQL, Auth, Storage, Edge Functions), viz [specifikace, kap. 7](docs/SPECIFIKACE.md#7-architektura)
* **Design:** tmavý motiv podle palety ze specifikace (kap. 10.2), čeština včetně kalendáře
* **Testování:** flutter_test + Mockito, CI v GitHub Actions


## Jak spustit
1. Naklonujte repozitář.
2. `flutter pub get`
3. `flutter run`

Hive adaptér i mocky jsou v repozitáři vygenerované. Po změně `ActivityHiveModel`
nebo mockovaných tříd je přegenerujte:
`dart run build_runner build --delete-conflicting-outputs`

## Testy
```
flutter analyze
flutter test
```

---
*Verze: 0.1.0*
