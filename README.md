# Zahradník Bóďa – MVP 0.1 (Offline Deník)

Toto je repozitář pro MVP verze 0.1 aplikace **Zahradník Bóďa**.
Cílem této verze je ověřit, jestli lidé budou digitálně zapisovat práci na zahradě.
Proto je to jednoduchý, **100% offline deník** bez 2D plátna a bez AI.

## Funkce (MVP 0.1)
* ✅ **Co dnes?** Dashboard s hero kartou (co je dnes zapsané, nebo kterou zónu dlouho nikdo neviděl), statistikou za 7 dní a sezónním tipem od Bódi.
* ✅ **Záznam aktivity:** název, datum a čas, zóna ze seznamu, poznámka, fotka (fotoaparát nebo galerie).
* ✅ **Deník (Timeline):** všechny záznamy od nejnovějšího, seskupené po dnech, s detailem, úpravou a smazáním.
* ✅ **Zóny:** výchozí seznam (Zelenina, Okrasná zahrada, Ovocný sad, Trávník, Skleník), vlastní zóny lze přidat, přejmenovat i smazat.
* ✅ **Tip od Bódi:** statické sezónní tipy podle měsíce, každý den jiný.
* ✅ **Offline-first:** data i fotky zůstávají na zařízení (Hive + složka aplikace). Žádný backend.

Na webu funguje vše kromě fotek (prohlížeč nemá trvalé lokální úložiště souborů).

## Architektura a Technologie
* **Framework:** Flutter (Android, iOS, Web)
* **Architektura:** Feature-first Clean Architecture (Domain / Data / Presentation)
  * `features/activity` – záznamy deníku
  * `features/zones` – seznam zón
  * `features/dashboard` – „Co dnes?“ a tipy od Bódi
* **State Management:** Riverpod (`AsyncNotifier`, zápisy přes `AsyncValue.guard()`)
* **Lokální Databáze:** Hive
* **Design:** tmavý motiv podle palety ze specifikace (kap. 7), čeština včetně kalendáře
* **Testování:** flutter_test + Mockito, CI v GitHub Actions

Rozhodnutí a jejich důvody jsou v [DECLOG.md](DECLOG.md), prostředí v [ENVIRONMENT.md](ENVIRONMENT.md).

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
