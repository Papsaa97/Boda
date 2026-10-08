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
| Android `applicationId` | `com.example.zahradnik_boda_mvp01` | např. `cz.zahradnikboda.app` – **před prvním nahráním na Google Play**, `com.example` obchod odmítne a později už ID změnit nejde |
| iOS bundle ID | `com.example.zahradnikBodaMvp01` | stejný základ jako Android (MVP 1.0) |

## Prostředí backendu (od MVP 1.0)

Zatím žádný backend není. Až přijde Firebase:

* Dva projekty: `zahradnik-boda-dev` a `zahradnik-boda-prod`, region EU (`eur3` / `europe-west3`).
* Přepínání přes Flutter flavors (`dev`, `prod`) a `flutterfire configure` pro každý projekt.
* Konfigurační soubory Firebase (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) nejsou tajné, ale API klíče LLM a platebních bran ano: ty patří **jen** do Cloud Functions (Secret Manager), nikdy do aplikace ani do gitu.
* Lokální vývoj backendu přes Firebase Emulator Suite; testy bezpečnostních pravidel běží proti emulátoru.
