# Checklist pro code review

Prochází ho autor PR před předáním k review a reviewer (Papi) při review.
Nemusí se odškrtávat všechno: co se PR netýká, se přeskočí.

## 1. Rozsah

- [ ] PR dělá jednu věc a ta věc patří do **aktuální fáze** ([specifikace, kap. 4](docs/SPECIFIKACE.md#4-roadmapa-a-rozsah-fází)).
- [ ] Popis odkazuje na požadavek ve specifikaci (např. `FR-D5`) nebo vysvětluje, proč žádný není.
- [ ] Nic navíc „když už jsem tam byl“. Nápady mimo rozsah jsou v [NAPADNIK.md](NAPADNIK.md).
- [ ] Mění-li PR rozhodnutí, rozsah nebo architekturu, má záznam v [DECLOG.md](DECLOG.md).

## 2. Funkčnost

- [ ] Funguje **bez internetu** (režim letadlo), pokud jde o jádro aplikace (NFR-1).
- [ ] Ošetřené stavy: načítání, chyba, prázdný seznam.
- [ ] Chyba úložiště nesmaže uživateli zobrazená data ani rozepsaný formulář.
- [ ] Destruktivní akce (smazání) mají potvrzení.
- [ ] Datum a čas: ukládá se UTC (nebo s časovou zónou), zobrazuje se v místním čase v českém formátu.

## 3. Data

- [ ] Změna uloženého modelu (Hive adaptér, pole, box) má **migraci** a test, že data z předchozí verze se načtou (NFR-2).
- [ ] Nové ID = UUID v4.
- [ ] Soubory (fotky) se ukládají do složky aplikace a v datech je **relativní** cesta (na iOS se absolutní cesta ke kontejneru aplikace po aktualizaci mění).
- [ ] Žádná osobní data v logu.

## 4. Architektura a kód

- [ ] Feature-first struktura: `domain` nezávisí na Flutteru ani na Hive; UI nečte databázi přímo.
- [ ] Stav přes Riverpod `AsyncNotifier` / `Notifier`, zápisy přes `AsyncValue.guard()`; žádný nový `StateNotifier`.
- [ ] Závislosti přes providery (testovatelné přes `overrides`), žádné globální singletony.
- [ ] Žádný mrtvý kód, zakomentované bloky ani artefakty z AI nástrojů (např. `:contentReference[...]`).
- [ ] Nová závislost v `pubspec.yaml` je udržovaná (poslední vydání < 12 měsíců), má rozumnou licenci a je zdůvodněná v popisu PR.
- [ ] Generované soubory (`*.g.dart`, `*.mocks.dart`) jsou přegenerované a commitnuté.

## 5. UI a přístupnost

- [ ] Texty česky; od MVP 0.2 v lokalizačních souborech, ne natvrdo v kódu (NFR-7).
- [ ] Dotykové plochy ≥ 48 dp, kontrast textu ≥ 4,5 : 1 v tmavém i světlém motivu (NFR-5).
- [ ] Layout se nerozbije při zvětšeném písmu (200 %) ani na malém displeji.
- [ ] Ikony bez textu mají `tooltip` / `semanticLabel`.

## 6. Testy

- [ ] Nová logika v `domain`/`data` má unit testy; nová obrazovka má aspoň jeden widget test.
- [ ] Testy nezávisí na aktuálním čase ani na pořadí (čas přes `clockProvider`).
- [ ] `flutter analyze` bez nálezů a `flutter test` zelené lokálně i v CI.

## 7. Bezpečnost a soukromí

- [ ] Žádné klíče, tokeny ani hesla v kódu nebo v gitu.
- [ ] Nic se neodesílá ze zařízení bez důvodu a bez souhlasu (kap. 9 specifikace).
- [ ] (od 1.0) Změna Firestore pravidel má test v emulátoru.
- [ ] (od 1.0, Bóďa) Odpověď s čísly bere čísla z kalkulátoru; doporučení chemie jen podle etikety (FR-B4).

## 8. Dokumentace

- [ ] README / ENVIRONMENT aktualizované, pokud se mění spouštění, verze nástrojů nebo závislosti.
- [ ] Popis PR: *Před / Po*, jak to funguje, jak to bylo otestováno.
