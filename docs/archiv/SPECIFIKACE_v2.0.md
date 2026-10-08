# Archiv: Specifikace v2.0 Master (originál)

> Tento soubor je **archivní kopie** původní specifikace v2.0, kterou autor vložil do projektu 7. 10. 2026.
> Text je zachován beze změn obsahu (upraveno jen formátování: odstraněny přebytečné prázdné řádky).
> **Platná verze je [`docs/SPECIFIKACE.md`](../SPECIFIKACE.md) (v2.1).** Rozdíly a jejich důvody jsou v [`DECLOG.md`](../../DECLOG.md).

---

# 🪴 ZAHRADNÍK BÓĎA (ZAHRADA APK)

## Kompletní Produktová, Technická a Architektonická Specifikace (v2.0 Master)

**Datum:** Říjen 2026
**Autor:** Michal Papoušek & Tým
**Projekt:** Zahrada apk — „Digitální dvojče zahrady + AI asistent Bóďa“
**Tagline:** *„Tvůj AI parťák na každé semínko i šroubek.“* / *„Vrátit do zahradničení radost a klid namísto stresu a nejistoty.“*

---

## 1. ELEVATOR PITCH A HLAVNÍ VIZE

**Zahradník Bóďa** je mobilní (iOS/Android) a webová aplikace, která vytváří **digitální dvojče** reálné zahrady uživatele a slouží jako **kontextový AI asistent** pro plánování, dokumentaci, diagnostiku a realizaci zahradnických prací.

Aplikace řeší každodenní rozhodovací paralýzu („co teď na zahradě dělat?“, „jakou půdu tu mám?“, „kdy jsem to hnojil?“) tím, že převádí obecné knihovní a internetové rady do **konkrétních kroků, přesných časových harmonogramů, potřebných materiálů a dávkování na m²** přímo na míru pozemku konkrétního uživatele.

---

## 2. CÍLOVÉ PERSONY

1. **Hobby pěstitel:** Vyžaduje jasné instrukce krok za krokem, přehledné termíny a radost z úrody bez zdlouhavého studia diskusních fór.
2. **Chalupář:** Potřebuje dosáhnout maximálního efektu za víkend práce a mít přehled o tom, co je nutné udělat před odjezdem.
3. **Experimentátor / Tvořivý stavitel:** Baví ho plánování, navrhování nových záhonů, stavba vyvýšených záhonů, chodníčků či dřevěných bridges/mostků přes jezírko.
4. **Dokumentarista:** Sleduje historii vývoje zahrady, rád porovnává fotky „před a po“ a vede si detailní přehled o nákladech.

---

## 3. STRATEGICKÁ ROADMAPA & EVOLUCE FÁZÍ (SCOPE CUT)

Vývoj podléhá přísnému řízení rozsahu (*Scope Budget*). Aby se minimalizovalo riziko vývoje nevyužitých funkcí, byl vývoj vědomě rozdělen do navazujících milníků:

```
[ MVP 0.1: Offline Deník ] ➔ [ MVP 1.0: 2D Digitální Dvojče ] ➔ [ V2: AR, Vision AI & Počasí ] ➔ [ V3: Parametrický Guardrails Engine ]
```

| Fáze | Název | Klíčový Cíl | Detailní Rozsah Funkcí |
| --- | --- | --- | --- |
| **MVP 0.1** | **Offline Deník** | Ověřit ochotu uživatelů digitálně zaznamenávat aktivity. | Záznam akcí (`Activity`: název, datum, zóna ze seznamu, foto, poznámka), Časová osa (Timeline), Dashboard „Co dnes?“, statický Tip od Bódi. **Bez 2D plátna a bez LLM AI**. 100% offline. |
| **MVP 1.0** | **2D Digitální Dvojče** | Plnohodnotné 2D prostředí a chytrý parťák. | 2D mapové plátno, kalibrace rozměrů, geometrické zónování, kompletní Inventář zásob s odpisem, textový AI Asistent Bóďa. |
| **V2 (Beta)** | **AR, Vision AI & Počasí** | Vizuální diagnostika a meteo data. | Diagnostika chorob z fotek (on-device + cloud), AR obchůzka pozemku, lokální počasí a zálivkový engine, sdílení v rodině. |
| **V3 (Profi)** | **Parametrický Engine & IoT** | Stavební návrhy a hardware. | Parametrické stavby hlídané bezpečnostními mantinely (*Guardrails*), finanční rozpočty, integrace IoT senzorů vlhkosti půdy (BLE/Wi-Fi), 3D stínování a simulace slunce. |

---

## 4. PODROBNÁ FUNKČNÍ SPECIFIKACE (FR)

### 4.1 2D Mapové Plátno, Měřítko a Zóny

* **Kreslení obrysu:** Vytváření polygonu obvodu zahrady (polyline → polygon) s možností přitahování uzlů (*snap on grid*), úpravou hran a výpočtem celkové výměry v m².
* **Kalibrace rozměrů:** Zadání 2 reálných vzdáleností přepočítá celé plátno do metrické soustavy s tolerovanou odchylkou přesnosti do ±3–5 %.
* **Vrstvy plátna:** Přepínání mezi vrstvami **„Návrh“** (budoucí vize) a **„Realita“** (aktuální stav).
* **Zónování & Agronomické vlastnosti:** Plocha se dělí na logické zóny (Zelenina, Trávník, Ovocný sad, Skleník, Jezírko, Stavby). U každé zóny se eviduje:
  * pH půdy (např. 6.6) a textura půdy (písčitá, hlinitá, jílovitá).
  * Oslunění (plné slunce, polostín, stín) a stav/způsob závlahy.

### 4.2 Kontextový AI Asistent „Bóďa“ (LLM Engine)

* **Znalost kontextu:** Bóďa zná rozměry zón, vlastnosti půdy, historii prací i stav zásob na skladě.
* **Přepočet na m²:** Převádí obecné rady na přesná množství (např. *„Na zónu Zelenina SE o výměře 20 m² aplikuj přesně 1.2 kg hnojiva X“*).
* **Bezpečnostní režim (Eko vs. Chemia):** Vždy primárně doporučuje ekologická řešení. Při použití chemie striktně vyžaduje a hlídá ochrannou lhutu do sklizně (PHI) a ochranné pomůcky (OOPP).
* **Interní prompty (Příklady z dokumentace):**
  * *Příklad 1 (Záhon na rajčata):* Kontext: Zóna „Zelenina SE“, půda hlinitá, pH 6.6, full slunce. Cíl: záhon pro 8 ks tyčkových rajčat. Výstup: postup krok za krokem, nákupní seznam s množstvím, odhad cen a časový plán.
  * *Příklad 2 (Dřevěný most přes jezírko):* Cíl: dřevěný most bez podpěr ve vodě. Výstup: rozměry, statika (max 3 m bez podpěr), ochrana dřeva, rozpočet a harmonogram.

### 4.3 Úkoly, Checklisty a Denní Digest

* **Atributy úkolu:** Termín splnění (`due`), pravidlo opakování (`rrule` dle iCalendar standardu), odložení (`snooze`), odhadovaná doba trvání (`duration_est`), potřebné nářadí (`tools`) a materiály (`materials`).
* **Tiché hodiny:** Notifikace a digest striktně respektují noční klid mezi 21:00 a 08:00.
* **Transakční odpis zásob:** Při dokončení úkolu se automaticky odečte použité množství materiálu ze skladu.

### 4.4 Inventář a Skladové Zásoby

* **Sledované kategorie:**
  * Osiva: odrůda, kód šarže LOT, expirace.
  * Hnojiva: složení N-P-K.
  * Postřiky: účinná látka, ochranná lhůta PHI.
  * Nářadí: stav a servisní intervaly.
* **Hlídač zásob:** Automatická upozornění na docházející materiál nebo prošlé expirace osiv.

### 4.5 Vizuální Diagnostika (Vision AI) & Incidenty (V2)

* **On-device model:** Lokální rozpoznání škůdců a chorob z fotek (TF Lite / CoreML) bez nutnosti připojení k internetu.
* **Cloud Re-check:** Volitelné ověření cloudovým modelem při nízké míře jistoty (`confidence`).
* **Karta Incidentu:** Sleduje detekovaný problém (`label`), míru jistoty (`confidence`), biologický plán (`plan_bio`), chemický plán (`plan_chem`), kalendář kontrol (`followups[D+3, D+7]`) a porovnání fotek „Před a Po“.

### 4.6 Počasí, Fenologie a Zálivkový Engine (V2)

* **Srážkový limit:** Systém sleduje kumulativní sumu srážek za posledních **7 dní** na danou zónu. Pokud naprší dostatečné množství vody, automaticky zruší nebo odloží naplánovaný úkol zálivky.
* **Fenologický kalendář:** Výsevy a řezy přizpůsobené klimatické oblasti a průběhu jara.

### 4.7 Parametrické Návrhy & Guardrails Engine (V3)

* **Stavební prvky:** Návrhy chodníků, vyvýšených záhonů, přístřešků a dřevěných mostů.
* **Guardrails:** Zapracované fyzikální a konstrukční limity omezující nerealistické návrhy (např. max. rozpětí dřevěného mostu bez podpěr je 3 m) s explicitním varováním, že se nejedná o autorizovaný statický výpočet.

---

## 5. NEFUNKČNÍ POŽADAVKY (NFR)

* **Výkon:** Plynulé kreslení a úprava plátna s více než **300 uzly** při 60 FPS na zařízeních střední třídy.
* **Offline-first & Persistence:** Aplikace musí být 100% funkční bez internetu. Data se ukládají lokálně a synchronizují do cloudu na pozadí.
* **Soukromí:** Data patří výhradně uživateli (`user-owned` Firestore Security Rules). Odeslání fotek do cloudu probíhá pouze s explicitním souhlasem.

---

## 6. TECHNICKÁ ARCHITEKTURA A DATOVÝ MODEL

### 6.1 Technologický Stack

* **Frontend:** Flutter (iOS, Android, Web), CanvasKit pro plátno, GoRouter.
* **Architecture:** *Feature-First Clean Architecture* (Presentation, Domain, Data vrstvy).
* **State Management:** Riverpod (`AsyncNotifier` s využitím generátoru `@riverpod`, bezpečné ošetření stavů přes `AsyncValue.guard()`).
* **Backend:** Google Firebase (Firestore, Auth, Storage, Cloud Functions).
* **Geometrie/GIS:** Dart isolates pro výpočty ploch a průniků (port knihovny Turf).

### 6.2 Firestore Datové Schéma

```
users/{userId}
   └── gardens/{gardenId}
         ├── bounds: Polygon (geometrie obvodu)
         ├── scale_factor: double (metrický koeficient kalibrace)
         ├── zones/{zoneId}
         │     ├── polygon: Polygon
         │     ├── type: String (zelenina, trávník, stavba...)
         │     ├── ph: double
         │     ├── soil_texture: String (písčitá, hlinitá...)
         │     └── sun_exposure: String (full_sun, shade...)
         ├── tasks/{taskId}
         │     ├── due: Timestamp
         │     ├── rrule: String
         │     ├── duration_est: int (minuty)
         │     └── materials: Array
         ├── inventory/{itemId}
         │     ├── category: String (osivo, hnojivo, postřik...)
         │     ├── lot: String
         │     ├── expiration: Timestamp
         │     ├── phi_days: int
         │     └── stock_qty: double
         └── incidents/{incidentId}
               ├── label: String
               ├── confidence: double
               ├── plan_bio: String
               ├── plan_chem: String
               └── followups: Array [D+3, D+7]
```

---

## 7. UI / UX DESIGN SYSTEM

* **Barevná paleta (Dark Mode):** Pozadí `#020617` / `#0F172A`, prvky `#1E293B`, Primární akcent Tyrkysová Teal (`#2DD4BF`), sekundární Zelená (`#10B981`), Oranžová (`#F59E0B`), Červená (`#EF4444`).
* **Welcome Screen:** Vstupní obrazovka s tlačítkem *„Začít bez registrace (Pokračovat jako Host)“* pro vyzkoušení bez zadání e-mailu.
* **Smart Onboarding:** Vizuální výběr pěstebních kategorií pomocí velkých karet s indikátorem průběhu (*Progress bar*).
* **Bento Grid Dashboard:** Přehledná mřížka obsahující **Hero kartu** (nejdůležitější akce dne), **Weather Widget** a sekci nadcházejících úkolů.

---

## 8. BYZNYS MODEL A MONETIZACE

* **Free Tarif (0 Kč):** 1 projekt zahrady, základní katalog, manuální úkoly, Offline Akční Deník.
* **Premium Tarif (129 Kč / měsíc):** Neomezeně projektů, AI Asistent Bóďa, Vizuální AI Diagnostika z fotek, AR náhledy, automatické plánování podle počasí, bez reklam.
* **Cíl:** Dosáhnout **100 000 aktivních uživatelů do roku 2026** ve střední Evropě.

---

## 9. PROJEKTOVÁ SMĚRNICE & TÝMOVÁ METODIKA

Vývoj je řízen projektovou směrnicí (v1.6) za využití tříčlenné AI-lidské struktury:

1. **Uživatel (Hlavní Architekt):** Určuje strategické cíle a zadává ucelené funkční celky.
2. **ChatGPT (Seniorní Výkonný Kodér):** Dodává kompletní modulární řešení v rámci jednoho výstupu a dokládá ho auditním štítkem.
3. **Gemini (Technický Auditor):** Provádí hloubkový audit rizik, hlídá architektonickou čistotu a stráží dodržení rozsahu MVP.
4. **NotebookLM (Projektová Paměť):** Centralizovaná neomylná znalostní báze.

**Povinné soubory repozitáře:** `README.md`, `DECLOG.md` (eviduje všechna rozhodnutí s datem a dopadem), `ENVIRONMENT.md`, `NÁPADNÍK.md`, `COLLAB_WORKFLOW.md` a `CODE_REVIEW_CHECKLIST.md`.

---

Tento dokument představuje **kompletní, definitivní a všezahrnující souhrn projektu Zahradník Bóďa**. Je v něm obsaženo vše od filozofie a uživatelského rozhraní až po Firestore schéma, zálivkový engine, Guardrails a pravidla týmové práce!
