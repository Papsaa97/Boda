# Zahradník Bóďa - MVP 0.1 (Offline Deník)

Toto je repozitář pro MVP verze 0.1 aplikace **Zahradník Bóďa**.
Cílem této verze je poskytnout jednoduchý, **offline-first nástroj pro záznam aktivit na zahradě**.

## Funkce (MVP 0.1)
* ✅ **Záznam aktivity:** Název, datum a čas, zóna (výběr), poznámka, fotka.
* ✅ **Timeline:** Chronologický přehled všech aktivit.
* ✅ **Offline-first:** Data se ukládají lokálně na zařízení (pomocí Hive). Žádný backend.
* ✅ **Tip od Bódi:** Statický prvek na hlavní obrazovce pro charakter aplikace.

## Architektura a Technologie
* **Framework:** Flutter
* **Architektura:** Feature-first Clean Architecture (Domain / Data / Presentation)
* **State Management:** Flutter Riverpod (StateNotifierProvider)
* **Lokální Databáze:** Hive (Community Edition)
* **Testování:** Mockito (pro unit testy Data vrstvy)

## Jak spustit
1.  Naklonujte repozitář.
2.  Spusťte `flutter pub get`.
3.  Spusťte generátor kódu (pro Hive adaptéry a mocky):
    `dart run build_runner build --delete-conflicting-outputs`
4.  Spusťte aplikaci:
    `flutter run`

---
*Verze: 0.1.0*
