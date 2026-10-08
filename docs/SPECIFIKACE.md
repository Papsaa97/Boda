# 🪴 Zahradník Bóďa

## Produktová a technická specifikace v2.2

| | |
| --- | --- |
| **Verze** | 2.2 (v2.1 + Supabase místo Firebase a revize technologií) |
| **Datum** | 8. 10. 2026 |
| **Autor** | Michal Papoušek (produkt), revize Claude |
| **Stav** | Živý dokument. Mění se přes pull request, každá podstatná změna má záznam v [`DECLOG.md`](../DECLOG.md). |
| **Předchozí verze** | v2.1 v historii gitu; v2.0 v [`docs/archiv/SPECIFIKACE_v2.0.md`](archiv/SPECIFIKACE_v2.0.md) |

**Tagline:** *„Tvůj AI parťák na každé semínko i šroubek.“*
**Poslání:** *Vrátit do zahradničení radost a klid místo stresu a nejistoty.*

> **Co se změnilo proti v2.0 (stručně):** přidány hypotézy a měřitelná kritéria úspěchu; roadmapa rozdělena na menší kroky s jasnou „definicí hotovo“; AI Bóďa přesunut před 2D plátno (hodnota je v radě na míru, ne v kreslení); výpočty dávek dělá kód, ne jazykový model; doplněny chybějící části (entita `Activity` v datovém modelu, záloha a export dat, GDPR, testovací strategie, rizika, sezónnost); zastaralý cíl 100 000 uživatelů do roku 2026 nahrazen cíli po fázích; cena přepracována na roční tarif; AR, IoT a 3D stínování přesunuty do [`NÁPADNÍK.md`](../NAPADNIK.md). Podrobně v kapitole 15 a v DECLOGu.
>
> **Co přinesla v2.2:** backend je **Supabase** (PostgreSQL s řádkovým zabezpečením, Auth, Storage, Edge Functions) místo Firebase; lokální databáze je od MVP 0.2 **Drift (SQLite)** místo Hive; doplněny konkrétní volby pro crash reporting, analytiku, platby a push. Technologie v této specifikaci jsou **výchozí volba, ne dogma**: pro každou část se vybírá nástroj, který se na ni hodí nejlépe, a změna se zapíše do DECLOGu (kap. 7.1, 15.2).

---

## Obsah

1. [Vize a problém](#1-vize-a-problém)
2. [Cíloví uživatelé](#2-cíloví-uživatelé)
3. [Hypotézy a měření úspěchu](#3-hypotézy-a-měření-úspěchu)
4. [Roadmapa a rozsah fází](#4-roadmapa-a-rozsah-fází)
5. [Funkční specifikace](#5-funkční-specifikace)
6. [Nefunkční požadavky](#6-nefunkční-požadavky)
7. [Architektura](#7-architektura)
8. [Datový model](#8-datový-model)
9. [Soukromí, GDPR a bezpečnost](#9-soukromí-gdpr-a-bezpečnost)
10. [UI / UX](#10-ui--ux)
11. [Byznys model](#11-byznys-model)
12. [Kvalita a testování](#12-kvalita-a-testování)
13. [Rizika](#13-rizika)
14. [Způsob práce](#14-způsob-práce)
15. [Změny proti v2.0 a v2.1](#15-změny-proti-v20-a-v21)
16. [Slovníček](#16-slovníček)

---

## 1. Vize a problém

**Zahradník Bóďa** je mobilní aplikace (Android, iOS; web jako doplněk), která vede **deník a digitální model zahrady** a nad ním nabízí **kontextového asistenta Bóďu**.

**Problém:** hobby zahradník se denně rozhoduje bez opory. *Co mám teď dělat? Kdy jsem naposledy hnojil? Kolik hnojiva dát na tenhle záhon?* Rady z knih, fór a videí jsou obecné. Převést je na konkrétní záhon (jeho výměru, půdu, oslunění, historii) musí člověk sám, a to je přesně to, co ho stresuje.

**Řešení:** aplikace si pamatuje, co se na zahradě dělo a kde, a z toho odvozuje konkrétní kroky: *co, kde, kdy, kolik a čím*. Obecné rady převádí na **dávku na m² konkrétní zóny**, na harmonogram a na nákupní seznam.

**Proč to někdo bude používat (jádro hodnoty):** rada šitá na konkrétní záhon. Obecné zahradnické aplikace a fóra ji nedají, protože neznají historii a parametry zahrady. Proto je **deník základ všeho**: bez dat o zahradě není z čeho radit.

**Co aplikace není (non-goals):**
- Není to statik ani projektant. Stavební návrhy jsou orientační.
- Není to náhrada etikety přípravku na ochranu rostlin. Dávky chemie se řídí etiketou, ne AI.
- Není to sociální síť ani e-shop (alespoň do V3).
- Není to profesionální nástroj pro farmy a zahradnictví.

---

## 2. Cíloví uživatelé

Persony jsou seřazené podle priority. Priorita určuje, pro koho se rozhoduje, když se zájmy střetnou.

| Priorita | Persona | Potřeba | Kdy ji obsloužíme |
| --- | --- | --- | --- |
| **1** | **Hobby pěstitel** (zelenina, ovoce, záhony u domu) | Jasné kroky, termíny, „co dnes?“, radost z úrody bez studia fór. | MVP 0.1 (deník), plně v 1.0 (Bóďa) |
| **2** | **Dokumentarista** | Historie zahrady, fotky „před a po“, přehled nákladů a sklizně. | MVP 0.1 (deník s fotkami), 0.2 (sklizeň, náklady, export) |
| **3** | **Chalupář** (zahrada jen o víkendech) | Maximum za víkend, co je nutné udělat před odjezdem, co zalít. | 0.2 (úkoly), V2 (počasí a zálivka) |
| **4** | **Tvořivý stavitel / experimentátor** | Navrhování záhonů, vyvýšených záhonů, chodníčků, mostků přes jezírko. | 1.1 (2D plátno), V3 (parametrické návrhy) |

**Primární trh:** Česko (čeština, české názvy odrůd, česká legislativa k přípravkům, klimatické podmínky ČR). Slovensko jako druhý trh s minimálními náklady. Další země střední Evropy až po ověření v ČR.

**Primární uživatel pro validaci:** autor sám na vlastní zahradě a 10–30 testerů z okolí (rodina, sousedé, zahrádkářské skupiny).

---

## 3. Hypotézy a měření úspěchu

Každá fáze ověřuje jednu hlavní hypotézu. Pokud ji neověří, další fáze se nezačíná, dokud se nerozhodne, co změnit.

| ID | Hypotéza | Ověřuje | Kritérium úspěchu | Signál k přehodnocení |
| --- | --- | --- | --- | --- |
| **H1** | Lidé vydrží zapisovat práci na zahradě do mobilu. | MVP 0.1–0.2, sezóna 2027 | ≥ 60 % testerů zapisuje aspoň 2× týdně po dobu 6 týdnů hlavní sezóny (duben–červen). | < 30 % po 4 týdnech: zjednodušit zápis (šablony, hlasový zápis, zápis jedním klepnutím) nebo přehodnotit koncept. |
| **H2** | Rada na míru konkrétní zóně má pro uživatele hodnotu. | MVP 1.0 | ≥ 40 % aktivních uživatelů se Bódi zeptá aspoň jednou týdně; ≥ 70 % odpovědí dostane 👍. | < 20 % týdenních dotazů: Bóďa je jen „hezký doplněk“, zaměřit se na deník a úkoly. |
| **H3** | Uživatelé za to zaplatí. | MVP 1.0 (sezóna 2028) | ≥ 3 % aktivních uživatelů koupí Premium během první placené sezóny. | < 1 %: změnit hranici Free/Premium nebo cenu. |
| **H4** | Uživatelé se po zimě vrátí. | 1.0+ | ≥ 40 % uživatelů aktivních v červnu je aktivních i v dubnu dalšího roku. | Nízký návrat: posílit zimní funkce (plánování, přehled sezóny). |

**Jak měřit, když je MVP 0.1 offline a bez analytiky:** aplikace žádná data neodesílá. Od MVP 0.2 umí deník exportovat do souboru (kap. 5.5); tester po 4 a 8 týdnech pošle export dobrovolně (nebo jen souhrnná čísla, která aplikace zobrazí v „Statistice“). Kvalitativní zpětná vazba: krátký rozhovor s každým testerem po 4 týdnech. Od MVP 1.0 anonymní analytika jen se souhlasem (kap. 9).

---

## 4. Roadmapa a rozsah fází

### 4.1 Přehled

```
MVP 0.1        MVP 0.2           Sezóna 2027       MVP 1.0             MVP 1.1        V2                    V3
Offline deník → Spolehlivý deník → validace H1    → Chytrý parťák     → 2D plátno   → Počasí, diagnostika → Parametrické návrhy
(hotovo, PR#1)  (zima 2026/27)    (březen–červen)   (účet, sync, Bóďa)   (mapa zahrady) (sdílení, zásoby)     (rozpočty)
```

Časy jsou orientační. **Přechod do další fáze řídí splnění „definice hotovo“ a výsledek hypotézy, ne kalendář.** Jedinou pevnou kotvou je začátek sezóny: MVP 0.2 musí být v rukou testerů **do konce února 2027**, jinak validace H1 posune o celý rok.

> **Proč tohle pořadí:** sezónnost je tvrdá. Od listopadu do února zahradu skoro nikdo neotevře, takže zima je čas na vývoj a jaro na ověřování. Zmeškat jaro znamená ztratit rok.

### 4.2 Fáze podrobně

#### MVP 0.1 – Offline deník ✅ (implementováno v PR #1)

**Cíl:** mít použitelný deník pro vlastní zahradu autora.
**Rozsah:** záznam aktivity (název, datum a čas, zóna ze seznamu, fotka, poznámka); rychlé volby pro častý zápis (Zálivka, Pletí, naposledy použité); deník seřazený od nejnovějšího s detailem, úpravou, smazáním a filtrem podle zóny; správa seznamu zón; onboarding „Co pěstuješ?“ s výběrem zón velkými kartami (jde přeskočit); dashboard „Co dnes?“ počítaný z deníku; statický sezónní tip od Bódi. Bez účtu, bez internetu, bez AI, bez 2D plátna.
**Definice hotovo:**
- [x] Všechny funkce výše fungují na Androidu bez připojení k internetu.
- [x] Fotka přežije restart aplikace i promazání cache (kopíruje se do složky aplikace).
- [x] `flutter analyze` bez nálezů, testy zelené v CI.
- [ ] Autor deník používá sám aspoň 2 týdny a sepíše, co mu chybí (vstup pro MVP 0.2).

#### MVP 0.2 – Spolehlivý deník (zima 2026/27)

**Cíl:** deník, který se dá s klidným svědomím dát testerům na celou sezónu.
**Rozsah (must-have):**
1. **Export a import dat** (ZIP: JSON + fotky) přes systémové sdílení. Bez toho tester při výměně nebo ztrátě telefonu přijde o celou sezónu. *(kap. 5.5)*
2. **Typ činnosti** u záznamu (výsev, výsadba, zálivka, hnojení, postřik, řez, sklizeň, pletí, jiné) s ikonou a rychlým výběrem. Usnadní zápis a je to podklad pro pozdější rady i statistiky.
3. **Rychlý zápis:** nový záznam na ≤ 3 klepnutí a do 15 sekund. Rychlé volby z 0.1 navázat na typ činnosti (bod 2), předvyplnit poslední zónu.
4. **Filtrování deníku** podle typu činnosti a fulltext v názvu a poznámce (filtr podle zóny je hotový v 0.1).
5. **Jednoduché úkoly s připomínkou** (název, termín, zóna, opakování týdně/měsíčně), lokální notifikace s tichými hodinami (kap. 5.3). Dokončení úkolu nabídne vytvořit záznam v deníku.
6. **Statistika** pro testery: počet záznamů za týden, nejaktivnější zóny (podklad pro H1).
7. **Světlý motiv** a přepínání podle systému (venku na slunci je tmavý motiv špatně čitelný, kap. 10). *(hotovo už v 0.1, DECLOG D36)*
8. **Technický dluh:** přechod z `hive_ce` (od 0.1 místo `hive`, DECLOG D33) na **Drift (SQLite)** s jednorázovou migrací dat z verze 0.1 (kap. 7.1, DECLOG D26), schéma s verzí, časovými razítky a měkkým mazáním (kap. 8).
9. **Distribuce:** Google Play interní testování (do 100 testerů).

**Nice-to-have (jen pokud zbude čas):** sklizeň s množstvím (kg/ks), náklady (Kč) u záznamu, porovnání dvou fotek „před a po“, lokalita v onboardingu pro sezónní tipy.

**Definice hotovo:**
- Export → odinstalace → instalace → import obnoví všechna data včetně fotek (ověřeno ručně i testem).
- Upgrade z verze 0.1 na 0.2 zachová data (migrační test).
- Notifikace nikdy nepřijde v tichých hodinách (unit test plánovače).
- Aplikace je v interním testování na Google Play a nainstalovaná aspoň u 10 testerů.

#### Sezóna 2027 – validace H1 (březen–červen 2027)

Vývoj se zpomalí, priorita je **pozorovat**. Opravují se jen chyby a tření při zápisu. Po 4 a po 8 týdnech se vyhodnotí H1 (kap. 3). Výsledek a rozhodnutí se zapíší do DECLOGu.

#### MVP 1.0 – Chytrý parťák (po úspěšné validaci H1)

**Cíl:** ověřit H2 (hodnota rady na míru) a H3 (ochota platit).
**Rozsah:**
1. **Účet a synchronizace:** aplikace dál funguje bez registrace; účet (Google, Apple, e-mail) se nabídne, až když uživatel chce zálohu do cloudu, víc zařízení nebo Bóďu. Data z lokálního deníku se při prvním přihlášení nahrají do cloudu. *(kap. 7.4)*
2. **Vlastnosti zón formulářem:** typ, výměra v m² (zadaná číslem), textura půdy, pH (s datem měření), oslunění, způsob závlahy, kryté/nekryté (skleník, fóliovník). **Bez kreslení mapy**: výměru zahradník zná nebo ji změří pásmem.
3. **Asistent Bóďa (text):** odpovídá v kontextu zahrady (zóny, historie, úkoly), převádí rady na dávky na m² přes deterministický kalkulátor, z odpovědi umí vytvořit úkoly a nákupní seznam. *(kap. 5.2)*
4. **Lehký sklad:** evidence zásob (osiva, hnojiva, přípravky, nářadí) bez automatického odpisu; Bóďa ví, co je doma.
5. **Úkoly v plném rozsahu** (kap. 5.3) včetně materiálů a nářadí.
6. **Premium a platby** (kap. 11), spuštění na začátku sezóny 2028.
7. **iOS** (App Store) a crash reporting.

**Definice hotovo:** sada referenčních dotazů pro Bóďu (aspoň 30, včetně příkladů z kap. 5.2) prochází hodnocením kvality ≥ 80 %; žádná referenční odpověď neobsahuje dávku chemického přípravku, která není z etikety; synchronizace přežije souběžnou úpravu na dvou zařízeních bez ztráty dat; řádkové zabezpečení databáze (RLS) ověřené automatickými testy (kap. 8.1, 12.1); funguje smazání účtu z aplikace.

#### MVP 1.1 – 2D plátno

**Cíl:** obsloužit personu 4 a zpřesnit výměry.
**Rozsah:** obrys zahrady jako polygon (přitahování k mřížce, úprava uzlů), kalibrace měřítka, zóny jako polygony s automatickým výpočtem výměry, vrstvy „Realita“ a „Návrh“, propojení zón na plátně s existujícími zónami z 1.0 (stejná `zoneId`). *(kap. 5.1)*
**Definice hotovo:** výměra obdélníku 10 × 5 m nakresleného po kalibraci se liší od 50 m² o méně než 3 %; plátno s 300 uzly drží 60 fps na referenčním zařízení střední třídy (kap. 6).

#### V2 – Počasí, diagnostika, sdílení

Počasí a zálivkový engine (kap. 5.6), diagnostika problémů z fotek přes cloudový model se souhlasem (kap. 5.5b), karta incidentu s kontrolami, sdílení zahrady v rodině (role vlastník/člen), sklad s automatickým odpisem při dokončení úkolu, fenologický kalendář.

#### V3 – Parametrické návrhy

Parametrické stavby (vyvýšený záhon, chodník, mostek, přístřešek) s mantinely (*guardrails*), rozpočty a výkaz materiálu. *(kap. 5.7)*

#### Mimo roadmapu (viz [`NÁPADNÍK.md`](../NAPADNIK.md))

AR obchůzka, IoT senzory vlhkosti, 3D stínování a simulace slunce, on-device model pro rozpoznávání chorob. Mají vysoké náklady a zatím neprokázanou hodnotu; vrátí se, až budou ověřené H1–H3.

---

## 5. Funkční specifikace

Každý požadavek má ID pro odkazování v PR a testech. Sloupec **Fáze** říká, kdy se implementuje.

### 5.0 Deník (jádro)

| ID | Požadavek | Fáze |
| --- | --- | --- |
| FR-D1 | Záznam aktivity: název, datum a čas (výchozí teď), zóna, poznámka, fotka (fotoaparát nebo galerie). | 0.1 ✅ |
| FR-D2 | Deník seřazený od nejnovějšího, seskupený po dnech; detail, úprava, smazání (s potvrzením). | 0.1 ✅ |
| FR-D3 | Zóny jako seznam s výchozími položkami; přidat, přejmenovat; zónu se záznamy nelze smazat (jen archivovat od 0.2). | 0.1 ✅ / 0.2 |
| FR-D4 | Dashboard „Co dnes?“: dnešní záznamy, zóny bez záznamu 7+ dní, počet záznamů za 7 dní, sezónní tip. | 0.1 ✅ |
| FR-D5 | Typ činnosti u záznamu (pevný číselník, kap. 8.3). | 0.2 |
| FR-D6 | Rychlý zápis: ≤ 3 klepnutí, předvyplněná poslední zóna. Rychlé volby (Zálivka, Pletí, naposledy použité) jsou hotové. | 0.1 ✅ / 0.2 |
| FR-D7 | Filtr podle zóny (hotový), podle typu a fulltext. | 0.1 ✅ / 0.2 |
| FR-D8 | Víc fotek u záznamu (max. 5), zmenšené na delší stranu 1 920 px, JPEG ~80 %. | 0.2 |
| FR-D9 | Sklizeň s množstvím a jednotkou; náklady v Kč. | 0.2 (nice-to-have) |
| FR-D10 | Porovnání „před a po“: dvě fotky téže zóny vedle sebe / s posuvníkem. | 0.2 (nice-to-have) |
| FR-D11 | Přehled sezóny („Tvoje sezóna 2027“): počet záznamů, sklizeň, nejlepší fotky. Zimní důvod aplikaci otevřít. | 1.0 |

### 5.1 2D plátno, měřítko a zóny (MVP 1.1)

| ID | Požadavek |
| --- | --- |
| FR-P1 | Kreslení obrysu zahrady: lomená čára → uzavřený polygon, přitahování k mřížce, přidání/posun/smazání uzlu, výpočet výměry v m². |
| FR-P2 | Kalibrace: uživatel označí úsečku a zadá její skutečnou délku → plátno se přepočte na metry. Druhá známá vzdálenost je **kontrolní**: aplikace ukáže odchylku a při odchylce > 5 % upozorní, že podklad je zkreslený. |
| FR-P3 | Volitelný podklad: fotka plánku / snímek z katastrální mapy / satelitní snímek vložený uživatelem. Aplikace sama mapové dlaždice nestahuje (licence). |
| FR-P4 | Zóny jako polygony uvnitř obrysu; výměra se počítá automaticky a přepíše ručně zadanou výměru z 1.0 (s potvrzením). |
| FR-P5 | Vrstvy **Realita** (aktuální stav) a **Návrh** (plán); prvek z Návrhu lze „zrealizovat“ (přesun do Reality se záznamem v deníku). |
| FR-P6 | Undo/redo posledních 20 kroků. |

**Výpočty:** souřadnice plátna jsou lokální v metrech (rovina), výměra polygonu se počítá shoelace vzorcem ve vlastním kódu (pár řádků, plně pokryté testy). Pro rovinné predikáty (bod v polygonu, obsahuje, protíná) použít existující Dart port Turf (balíček `turf`), ne vlastní port; jeho **geodetické** funkce (plocha, délka) na lokální metrové souřadnice nepoužívat, počítají se zeměpisnými stupni. Pokud bude potřeba ořez a sjednocení polygonů, vybrat udržovanou knihovnu pro rovinný ořez až v 1.1 (DECLOG). Izoláty jen pokud měření ukáže, že výpočet blokuje UI (pro 300 uzlů to nehrozí).

### 5.2 Asistent Bóďa (MVP 1.0)

**Princip: jazykový model radí a vysvětluje, kód počítá.** Jazykové modely dělají chyby v číslech. Všechny dávky, plochy a množství proto počítá deterministický **kalkulátor** v aplikaci/backendu a model dostane výsledek jako vstup (nebo ho zavolá jako nástroj). Model nikdy sám nevymýšlí číslo dávky.

| ID | Požadavek |
| --- | --- |
| FR-B1 | **Kontext:** k dotazu se automaticky přiloží relevantní data: zahrada (lokalita na úrovni obce), zóny a jejich vlastnosti, posledních N záznamů z dotčené zóny, otevřené úkoly, zásoby. Uživatel vidí, co Bóďa „ví“ (rozbalovací „Z čeho vycházím“). |
| FR-B2 | **Přepočet na m²:** např. *„Na zónu Zelenina JV (20 m²) dej 1,2 kg hnojiva X (60 g/m² dle obalu).“* Dávka na m² pochází z obalu/etikety zadané uživatelem nebo z interní tabulky, výpočet dělá kalkulátor, odpověď uvádí zdroj dávky. |
| FR-B3 | **Eko na prvním místě:** Bóďa vždy nejdřív nabídne neschemické řešení (agrotechnika, mechanická ochrana, biologické prostředky). |
| FR-B4 | **Chemická ochrana – tvrdá pravidla:** Bóďa doporučí jen přípravek povolený pro **neprofesionální uživatele** a jen na plodinu a účel uvedený na etiketě; dávku a ochrannou lhůtu (PHI) přebírá **z etikety / registru přípravků ÚKZÚZ**, nikdy je neodhaduje; vždy uvede ochrannou lhůtu do sklizně, osobní ochranné pomůcky a omezení k ochraně včel; při nejistotě odkáže na etiketu a odmítne dávku uvést. |
| FR-B5 | **Výstupy jako akce:** z odpovědi lze jedním klepnutím vytvořit úkoly (s termíny), nákupní seznam a záznam do deníku. |
| FR-B6 | **Zpětná vazba:** 👍/👎 u každé odpovědi s volitelným komentářem (měření H2, zlepšování promptů). |
| FR-B7 | **Offline:** bez připojení Bóďa nefunguje a řekne to; dotaz lze uložit a odeslat později. Zbytek aplikace funguje dál. |
| FR-B8 | **Limity:** Free X dotazů měsíčně, Premium fair-use (kap. 11). Limit hlídá backend. |
| FR-B9 | **Stavební dotazy** (mostek, pergola): jen orientační rozměry a materiál, vždy s upozorněním, že nejde o statický výpočet, a u nosných konstrukcí doporučení konzultovat statika. |

**Referenční dotazy (součást testovací sady, kap. 12):**
1. *Záhon na rajčata:* zóna „Zelenina JV“, 20 m², hlinitá půda, pH 6,6, plné slunce; cíl: 8 tyčkových rajčat. Očekávaný výstup: postup krok za krokem, sponový plán, nákupní seznam s množstvím (kompost, opory, úvazky), časový plán podle místního termínu posledních mrazíků, odhad ceny jako rozpětí.
2. *Mšice na fazolích:* nejdřív mechanicky/biologicky, chemie až na výslovný dotaz a jen s údaji z etikety, PHI a ochranou včel.
3. *Dřevěný mostek přes jezírko bez podpěr ve vodě:* orientační rozpětí a průřezy, ochrana dřeva, rozpočet; upozornění na statika.

**Technicky:** volání modelu jde **vždy přes backend** (Supabase Edge Function), API klíč nikdy není v aplikaci. Backend hlídá limity, loguje náklady na dotaz a odstraňuje z kontextu osobní údaje, které model nepotřebuje. Výběr modelu a poskytovatele je rozhodnutí na začátku 1.0 (zapsat do DECLOG): kritéria kvalita v češtině, cena za dotaz, zpracování dat v EU / smlouva o zpracování (DPA).

### 5.3 Úkoly, připomínky a denní přehled

| ID | Požadavek | Fáze |
| --- | --- | --- |
| FR-U1 | Úkol: název, termín (`due`), zóna, poznámka, stav (otevřený / hotový / přeskočený). | 0.2 |
| FR-U2 | Opakování: v 0.2 jen jednoduché (každý týden / měsíc / rok, volitelně jen v určitých měsících); interně uložené jako iCalendar RRULE, aby šlo později rozšířit. | 0.2 |
| FR-U3 | Odložení (`snooze`) o 1 den / do víkendu / o týden. | 0.2 |
| FR-U4 | Dokončení úkolu nabídne vytvořit záznam v deníku (předvyplněný). | 0.2 |
| FR-U5 | **Tiché hodiny:** výchozí 21:00–08:00, **nastavitelné** (chalupář může chtít jiné časy o víkendu). Notifikace naplánovaná do tichých hodin se posune na jejich konec. | 0.2 |
| FR-U6 | Denní přehled (digest): jedna notifikace ráno po skončení tichých hodin s úkoly na dnešek; vypínatelný; v zimě (listopad–únor) výchozí týdenní. | 0.2 |
| FR-U7 | Odhad doby (`durationEstMin`), nářadí (`tools`), materiály (`materials` s vazbou na sklad a množstvím). | 1.0 |
| FR-U8 | Režim „víkend na chalupě“: seznam úkolů seřazený podle priority a odhadované doby, aby se vešel do zadaného času. | 1.0 |

### 5.4 Sklad a zásoby

| ID | Požadavek | Fáze |
| --- | --- | --- |
| FR-S1 | Položky po kategoriích: **osiva** (druh, odrůda, šarže, datum spotřeby / klíčivosti), **hnojiva** (N-P-K, forma), **přípravky na ochranu rostlin** (účinná látka, číslo povolení, ochranná lhůta PHI ve dnech, povoleno pro neprofesionály ano/ne), **nářadí** (stav, servisní interval), ostatní. | 1.0 |
| FR-S2 | Množství s jednotkou (g, kg, ml, l, ks, balení); převody jen v rámci stejné veličiny. | 1.0 |
| FR-S3 | Hlídač: upozornění na docházející zásobu (uživatelem nastavený práh) a prošlá osiva. | 1.0 |
| FR-S4 | **Automatický odpis** při dokončení úkolu s materiálem: zapíše se pohyb (`movement`) a sníží stav v jedné transakci; vrácení úkolu do stavu „otevřený“ pohyb stornuje; stav nikdy nejde pod nulu (místo toho upozornění). | V2 |

### 5.5 Záloha, export a import

| ID | Požadavek | Fáze |
| --- | --- | --- |
| FR-E1 | Export celého deníku do jednoho ZIP souboru (`data.json` + složka `photos/`), sdílení přes systémové menu (Disk, e-mail, …). Formát je verzovaný (`formatVersion`) a zdokumentovaný v `docs/`. | 0.2 |
| FR-E2 | Import ze ZIP: varianta „nahradit vše“ s potvrzením. Import starší verze formátu musí fungovat. | 0.2 |
| FR-E3 | Připomínka zálohy jednou měsíčně, dokud uživatel nemá cloudovou synchronizaci. | 0.2 |
| FR-E4 | Export CSV deníku (pro tabulky). | 1.0 |
| FR-E5 | Export dat pro GDPR (čl. 20) = FR-E1 + data z cloudu; smazání účtu a všech dat z aplikace i webu. | 1.0 |

### 5.5b Diagnostika z fotek a incidenty (V2)

| ID | Požadavek |
| --- | --- |
| FR-V1 | Uživatel vyfotí problém → fotka se **se souhlasem** odešle cloudovému modelu (multimodální LLM nebo specializované API na rozpoznávání chorob rostlin). Před odesláním se z fotky odstraní EXIF včetně GPS. |
| FR-V2 | Výsledek ukazuje 1–3 nejpravděpodobnější příčiny **s jasným „možná“**, ne jako jistou diagnózu; číselná „jistota“ se nezobrazuje, pokud není kalibrovaná. |
| FR-V3 | Karta incidentu: zóna, problém (`label`), fotky, biologický plán, chemický plán (podle FR-B4), kontroly D+3 a D+7 jako úkoly, porovnání fotek před a po, stav (otevřený/vyřešený). |
| FR-V4 | Incident jde založit i ručně bez AI. |

On-device model (TF Lite / Core ML) je v NÁPADNÍKU: vyžaduje vlastní trénovací data a údržbu modelu, což je mimo možnosti malého týmu. Vrátit se k němu, až bude jasné, které problémy uživatelé fotí nejčastěji.

### 5.6 Počasí, fenologie a zálivka (V2)

| ID | Požadavek |
| --- | --- |
| FR-W1 | Počasí pro polohu zahrady (souřadnice zaokrouhlené na ~1 km): předpověď na 7 dní, srážky za posledních 7 dní. Zdroj vybrat podle licence pro komerční aplikaci (např. Open-Meteo je zdarma jen pro nekomerční použití, pro placenou aplikaci je potřeba placený tarif; alternativa otevřená data ČHMÚ). |
| FR-W2 | Zálivkový engine: srážky se vztahují ke **zahradě**, ne k zóně; zóna jen určuje, zda déšť dostane (**krytá zóna** – skleník, fóliovník – srážky nezapočítává). |
| FR-W3 | Pravidlo: pokud suma srážek za posledních 7 dní ≥ práh zóny (výchozí **15 mm**, nastavitelné podle typu zóny) nebo předpověď na příštích 24 h ≥ 5 mm, úkol zálivky se **navrhne** odložit (uživatel potvrdí jedním klepnutím, nebo zapne automatiku). Výchozí prahy jsou startovní hodnoty k ověření v praxi. |
| FR-W4 | Varování před mrazem (předpověď ≤ 0 °C) pro zóny s citlivými výsadbami v sezóně. |
| FR-W5 | Fenologický kalendář: termíny výsevů a řezů posunuté podle nadmořské výšky a lokality (startovní tabulka pro ČR, později podle skutečného průběhu jara). |

### 5.7 Parametrické návrhy a guardrails (V3)

| ID | Požadavek |
| --- | --- |
| FR-G1 | Šablony staveb: vyvýšený záhon, chodník, mostek, přístřešek; parametry (rozměry, materiál) → výkres v 2D, výkaz materiálu, rozpočet. |
| FR-G2 | Guardrails: tabulka konstrukčních limitů podle materiálu a průřezu (např. dřevěný mostek pro pěší bez podpory ve vodě orientačně do 3 m při odpovídajícím průřezu nosníků). Při překročení se návrh nezablokuje potichu, ale ukáže důvod a doporučení. |
| FR-G3 | Každý návrh nese trvalé upozornění: *„Orientační návrh, nejde o autorizovaný statický výpočet.“* U konstrukcí nesoucích osoby nad stanovenou mez doporučení statika. |

---

## 6. Nefunkční požadavky

| ID | Oblast | Požadavek | Jak se ověří |
| --- | --- | --- | --- |
| NFR-1 | **Offline** | Jádro (deník, zóny, úkoly, sklad, plátno) funguje 100 % bez internetu. Funkce, které internet potřebují (Bóďa, počasí, diagnostika, synchronizace), to jasně řeknou a zbytek aplikace neomezí. | Ruční test v režimu letadlo, widget testy s fake síťovou vrstvou. |
| NFR-2 | **Trvanlivost dat** | Žádná ztráta dat při pádu aplikace, vybité baterii nebo aktualizaci. Každá změna schématu má migraci a test. | Migrační testy, test exportu/importu. |
| NFR-3 | **Rychlost zápisu** | Nový záznam do 15 s, ≤ 3 klepnutí (s fotkou ≤ 5). | Ruční měření na testerech. |
| NFR-4 | **Výkon** | Studený start < 2 s na referenčním zařízení střední třídy (Android, 4 GB RAM); deník s 2 000 záznamy se posouvá plynule. Plátno (1.1): 300+ uzlů při 60 fps. | Profilování v release buildu. |
| NFR-5 | **Použitelnost venku** | Dotykové plochy ≥ 48 dp (rukavice, špinavé ruce), kontrast textu ≥ WCAG AA (4,5 : 1), světlý motiv čitelný na přímém slunci, ovládání jednou rukou. | Kontrola kontrastu, test venku. |
| NFR-6 | **Přístupnost** | Podpora zvětšeného písma systému do 200 % bez rozbití layoutu, popisky pro čtečky obrazovky u ikon. | Widget testy s `textScaler`, ruční test TalkBack. |
| NFR-7 | **Lokalizace** | Čeština první; texty v ARB souborech od 0.2 (slovenština bez zásahu do kódu); metrické jednotky; formát data `d. M. yyyy`; časy ukládat v UTC, zobrazovat v časové zóně zařízení. | Review, lint na natvrdo psané texty. |
| NFR-8 | **Soukromí** | Viz kap. 9. Nic se neodesílá bez důvodu a bez souhlasu. | Review, kontrola síťového provozu. |
| NFR-9 | **Velikost** | Instalační balíček Android < 30 MB do 1.0. | CI report velikosti. |
| NFR-10 | **Spolehlivost (od 1.0)** | Podíl relací bez pádu ≥ 99,5 %. | Crash reporting. |

---

## 7. Architektura

### 7.1 Technologie

**Pravidlo výběru:** pro každou část se volí nástroj, který se na ni hodí nejlépe. Tabulka je výchozí volba, ne závazek. Kdo navrhne změnu, zapíše do DECLOGu, co se mění a proč; měnit kvůli změně samotné se nemá. Nová knihovna musí být udržovaná (vydání za posledních 12 měsíců) a mít vhodnou licenci (kap. 12, checklist).

| Vrstva | Volba | Poznámka |
| --- | --- | --- |
| Aplikace | **Flutter** (Android, iOS, web) | Android první (většina českého trhu, testování bez Macu); iOS od 1.0; web jako doplněk (plánování na velké obrazovce od 1.1). Na webu se Flutter vykresluje přes CanvasKit/Skwasm; na mobilu přes Impeller. Plátno je `CustomPainter`. |
| Architektura | **Feature-first clean architecture** | `lib/features/<feature>/{domain,data,presentation}`, sdílené věci v `lib/core`. Domain nezávisí na Flutteru ani na databázi. |
| Stav | **Riverpod**, `AsyncNotifier`/`Notifier`, zápisy přes `AsyncValue.guard()` | `StateNotifier` se v novém kódu nepoužívá (v Riverpodu je legacy). Riverpod 3 je v kódu od 0.1 (DECLOG D33); generátor `@riverpod` je po odchodu z Hive možný, ale volitelný. |
| Navigace | `Navigator`; **GoRouter** s první funkcí, která potřebuje adresy (DECLOG D59) | Webové URL (1.1), odkazy z notifikací na konkrétní úkol. Přihlášení jde bez návratu z prohlížeče (nativní Google, e-mailový kód). |
| Lokální data | **Drift (SQLite)** od 0.2 | Relační model 1 : 1 se serverovou databází (stejné tabulky a sloupce), transakce (sklad, outbox), fulltext přes FTS5, typované migrace s testy. Na webu přes WebAssembly. Nahrazuje `hive` 2.x, který se neudržuje (DECLOG D26). |
| Backend (od 1.0) | **Supabase**: PostgreSQL s řádkovým zabezpečením (RLS), Auth, Storage, Edge Functions | Region EU (Frankfurt). Projekty `dev` a `prod`, lokální vývoj přes Supabase CLI. Schéma jako SQL migrace v gitu. Open source, data jdou kdykoli odnést (standardní PostgreSQL). DECLOG D24. |
| Synchronizace (1.0) | **Vlastní outbox** nad Drift → Supabase | Kap. 7.4. Záložní varianta, pokud vlastní synchronizace nebude stačit (sdílení ve V2): PowerSync. |
| Přihlášení (1.0) | **Supabase Auth**: Google (nativní přihlášení + `signInWithIdToken`), Apple, e-mail s jednorázovým kódem | Bez hesel. Host (bez účtu) je výchozí stav (kap. 10.1). |
| Fotky v cloudu (1.0) | **Supabase Storage**, soukromý bucket | Náhled (~400 px) se dělá v telefonu, nahrávají se oba soubory. Přístup přes pravidla RLS podle členství v zahradě. |
| Serverová logika (1.0) | **Supabase Edge Functions** (TypeScript) | Bóďa (volání LLM, limity, náklady), webhook plateb, smazání účtu. Tajné klíče jen v secrets Edge Functions. |
| AI (od 1.0) | LLM přes Edge Function | Kap. 5.2. Poskytovatel se vybere na začátku 1.0 podle kvality češtiny, ceny za dotaz a zpracování v EU (DPA). |
| Diagnostika z fotek (V2) | Multimodální LLM přes Edge Function | Specializované API na choroby rostlin jako alternativa, porovnat na stejné sadě fotek. Kap. 5.5b. |
| Geometrie (1.1) | Vlastní výpočet ploch + `turf` pro rovinné predikáty | Kap. 5.1. |
| Notifikace (0.2) | `flutter_local_notifications` + plánovač respektující tiché hodiny | Push ze serveru až ve V2 (počasí, sdílení): FCM jen jako doručovací kanál, odesílá Edge Function. |
| Crash reporting (1.0) | **Sentry** (datové centrum v EU) | Bez osobních údajů v logu. Firebase Crashlytics odpadá spolu s Firebase. |
| Analytika (1.0) | **PostHog** (EU cloud) | Jen se souhlasem (kap. 9). Měření H1–H4 včetně kohort a meziroční retence. |
| Platby (1.0) | **RevenueCat** nad Google Play Billing a App Store | Předplatné digitální služby musí jít přes obchody. RevenueCat řeší obě platformy, obnovy a zkušební verzi; webhook do Edge Function zapíše nárok na Premium. |
| Lokalizace (0.2) | `flutter_localizations` + ARB soubory (`gen-l10n`) | NFR-7. |
| CI | GitHub Actions: `flutter analyze`, `flutter test` na každý PR | Od 0.2 i build APK jako artefakt; od 1.0 i testy databáze (`supabase test db`). iOS build přes macOS runner nebo Codemagic. |

### 7.2 Struktura kódu (cílová)

```
lib/
  app.dart, main.dart
  core/          # téma, formátování, DI, fotky, notifikace, sdílené widgety
  features/
    activity/    # deník
    zones/       # zóny
    dashboard/   # Co dnes?, tipy
    tasks/       # úkoly (0.2)
    backup/      # export/import (0.2)
    inventory/   # sklad (1.0)
    assistant/   # Bóďa (1.0)
    account/     # účet, sync (1.0)
    canvas/      # 2D plátno (1.1)
supabase/        # (1.0) migrations/ (SQL), functions/ (Edge Functions, TypeScript), tests/ (testy RLS)
docs/            # specifikace, formát exportu, ADR
```

### 7.3 Pravidla

- UI nečte databázi přímo, jen přes controller → repozitář.
- Doménové entity jsou neměnné (`final`, `copyWith`), porovnatelné (`Equatable`).
- Každé ID je UUID v4 generované na zařízení (funguje offline a bez kolizí při synchronizaci).
- Čas: ukládat UTC; „datum činnosti“ uchovat i s časovou zónou, aby se záznam při cestování nepřesunul na jiný den.
- Natvrdo psané texty v UI jen do 0.1; od 0.2 lokalizace (NFR-7).

### 7.4 Offline-first a synchronizace (1.0)

**Lokální databáze je vždy zdroj pravdy**, cloud je záloha a most mezi zařízeními. Díky tomu režim bez registrace funguje stejně jako s účtem a aplikace nikdy nečeká na síť.

- Každý řádek má `updated_at` (čas změny na zařízení) a `deleted_at` (měkké mazání, aby se smazání propsalo na ostatní zařízení). Server navíc při každém zápisu nastaví `server_updated_at`; podle něj se stahují změny, aby nevadily rozdílně nastavené hodiny telefonů.
- Změny se ve stejné transakci zapíší do lokální fronty (`sync_outbox`) a odesílají na pozadí jako `upsert` podle `id`. Konflikt řeší **poslední zápis vyhrává** podle `updated_at` na úrovni řádku; databázový trigger odmítne zápis starší, než je uložená verze. Pro deník jednoho uživatele to stačí; u sdílených zahrad ve V2 přehodnotit.
- Stahování: řádky zahrad, kde je uživatel členem, se `server_updated_at` větším než poslední stažený. Realtime odběr změn jen pokud bude potřeba (sdílení ve V2).
- Fotky se nahrávají zvlášť, ve výchozím stavu jen přes Wi-Fi; v cloudu se ukládá i náhled (~400 px) vytvořený v telefonu.
- První přihlášení: nahrát lokální data do nové zahrady v cloudu; přihlášení na druhém zařízení s lokálními daty nabídne sloučit nebo nahradit.
- Supabase nemá offline SDK jako Firestore; vlastní outbox je proto nutnost, ne volba navíc. Hotová alternativa je **PowerSync** (synchronizační služba nad Supabase se SQLite v telefonu); zvážit, pokud se vlastní synchronizace ukáže jako křehká, hlavně se sdílením ve V2. Drift obě cesty nechává otevřené.

---

## 8. Datový model

Jeden logický model pro lokální databázi (Drift), serverovou databázi (PostgreSQL v Supabase) i export. Pojmenování:

- **V databázích snake_case** (`occurred_at`, `zone_id`): konvence PostgreSQL a výchozí chování Driftu, takže lokální a serverové tabulky mají stejné názvy sloupců.
- **V Dartu a v JSON exportu camelCase** (`occurredAt`, `zoneId`); převod dělá datová vrstva.
- Uložené hodnoty číselníků jsou anglické klíče (kap. 8.3), české popisky jsou v lokalizaci.

Schéma je navržené **od začátku pro sdílení** (V2), aby se nemuselo později migrovat: data patří zahradě, ne uživateli, a členství je samostatná tabulka.

### 8.1 PostgreSQL v Supabase (od 1.0)

Společné pro všechny tabulky se synchronizovanými daty: `id uuid` (primární klíč generovaný v zařízení), `created_at`, `updated_at`, `deleted_at?` (měkké mazání), `server_updated_at` (nastavuje server, kap. 7.4). Číselníky jsou `text` s kontrolou `check (… in (…))`, ne typ `enum` (snáz se rozšiřují). Čas je `timestamptz` v UTC.

```
profiles                       # 1 řádek na uživatele, id = auth.users.id
  id, display_name?, created_at, updated_at
  settings jsonb      { quietHoursStart: "21:00", quietHoursEnd: "08:00", theme: "system", digest: "daily" }
  consents jsonb      { analytics: {granted, at}, photoUpload: {granted, at}, aiProcessing: {granted, at}, policyVersion }

entitlements                   # nárok na Premium; zapisuje JEN backend (webhook plateb), uživatel jen čte
  user_id (PK → auth.users), plan: 'free' | 'premium', valid_until?, source: 'play' | 'appstore' | 'promo', updated_at

gardens
  id, name, owner_id → auth.users
  location_lat?, location_lng?   # numeric zaokrouhlené na 2 desetinná místa (~1 km), volitelné
  altitude_m?, bounds jsonb?, scale_meters_per_unit?    # bounds a měřítko: 2D plátno, 1.1

garden_members                 # PK (garden_id, user_id)
  garden_id → gardens, user_id → auth.users, role: 'owner' | 'editor' | 'viewer', created_at

zones
  garden_id → gardens, name, type, area_m2?, soil_texture?, ph?, ph_measured_at?, sun_exposure?, irrigation?
  covered bool, archived bool
  polygon jsonb?, layer?: 'reality' | 'plan'           # 1.1

activities
  garden_id, zone_id → zones, type, title, occurred_at, occurred_tz, notes?
  harvest_qty?, harvest_unit?, cost_czk?, task_id? → tasks

activity_materials             # 1.0, spotřebovaný materiál; PK (activity_id, item_id)
  activity_id → activities, item_id → inventory_items, qty, unit

photos
  garden_id, activity_id?, incident_id?, storage_path, thumb_path, width, height, taken_at
                                                       # lokální cesta k souboru se na server neukládá

tasks
  garden_id, title, zone_id?, due, rrule?, snoozed_until?, status: 'open' | 'done' | 'skipped'
  duration_est_min?, tools text[]?, completed_at?, completed_activity_id?, incident_id?
  source: 'user' | 'boda' | 'weather'

task_materials                 # 1.0; PK (task_id, item_id)
  task_id → tasks, item_id → inventory_items, qty, unit

inventory_items
  garden_id, category: 'seed' | 'fertilizer' | 'plantProtection' | 'tool' | 'other'
  name, unit, stock_qty, low_stock_threshold?
  details jsonb       # podle kategorie:
                      #   seed            { species, variety, lot, bestBefore }
                      #   fertilizer      { n, p, k, form }
                      #   plantProtection { activeSubstance, authorizationNo, phiDays, nonProfessional }  (povinné, check)
                      #   tool            { condition, serviceIntervalDays, lastServiceAt }

shopping_items                 # 1.0, nákupní seznam (DECLOG D53)
  garden_id, name, qty?, unit?, item_id? → inventory_items, done bool, source: 'user' | 'boda' | 'lowStock'

inventory_movements            # V2: odpis; jen přibývají, nemění se
  item_id → inventory_items, qty_delta, reason: 'purchase' | 'task' | 'manual' | 'reversal', task_id?, at

incidents                      # V2; kontroly D+3 a D+7 jsou úkoly s incident_id
  garden_id, zone_id, label, source: 'user' | 'model', candidates jsonb?, plan_bio?, plan_chem?
  status: 'open' | 'resolved'

assistant_threads, assistant_messages                  # 1.0, ve výchozím stavu jen lokálně
  role, text, context_summary?, feedback?: 'up' | 'down', created_at
```

**Zabezpečení (RLS, princip):**
- RLS je zapnuté na **každé** tabulce; tabulka bez pravidel je nedostupná.
- Pomocná funkce `is_garden_member(garden_id, roles)` (v neveřejném schématu, `security definer`) rozhoduje o přístupu ke všem datům zahrady: číst smí každý člen, zapisovat `owner` a `editor`, členy spravuje jen `owner`.
- `profiles`: každý jen svůj řádek. `entitlements`: uživatel jen čte svůj řádek, zapisuje výhradně Edge Function se servisní rolí.
- Storage: soukromý bucket `photos`, cesta `<gardenId>/<photoId>.jpg` a `<gardenId>/<photoId>_thumb.jpg`; pravidla nad `storage.objects` ověřují členství podle první složky cesty.
- Každé pravidlo má automatický test (pgTAP, `supabase test db`): cizí uživatel nic nepřečte, `viewer` nezapíše, nikdo kromě backendu nezmění `entitlements`. Testy běží v CI.
- Servisní klíč (service role) je jen v Edge Functions; v aplikaci je jen veřejný (publishable) klíč, který bez RLS k ničemu nepustí.

### 8.2 Lokální úložiště (0.x, Drift)

Stejné tabulky a sloupce jako v 8.1, bez `profiles`, `entitlements` a `garden_members`. V 0.x je jedna implicitní zahrada s UUID vygenerovaným při prvním spuštění; při prvním přihlášení v 1.0 se nahraje jako nová zahrada. Od 1.0 přibude tabulka `sync_outbox` (kap. 7.4). Fotky jsou soubory ve složce aplikace, v databázi jen relativní cesta. Verze schématu je Drift `schemaVersion`; každá změna má migraci a test (Drift umí uložit snímek schématu každé verze a ověřit migraci z libovolné starší). Data z Hive (MVP 0.1) se při prvním spuštění 0.2 jednorázově převedou.

### 8.3 Číselníky

| Číselník | Hodnoty |
| --- | --- |
| `activity.type` | `sowing` výsev, `planting` výsadba, `watering` zálivka, `fertilizing` hnojení, `spraying` postřik/ošetření, `pruning` řez, `harvest` sklizeň, `weeding` pletí, `mowing` sekání, `other` jiné |
| `zone.type` | `vegetable` zelenina, `herbs` bylinky (DECLOG D38), `fruit` ovocný sad, `ornamental` okrasná, `lawn` trávník, `greenhouse` skleník/fóliovník, `pond` jezírko, `structure` stavba, `other` |
| `zone.soilTexture` | `sandy` písčitá, `loamy` hlinitá, `clay` jílovitá, `unknown` |
| `zone.sunExposure` | `fullSun` plné slunce (6+ h), `partShade` polostín (3–6 h), `shade` stín (< 3 h) |
| `zone.irrigation` | `none`, `manual` konev/hadice, `drip` kapková, `sprinkler` postřikovač |

Uložené hodnoty jsou anglické klíče, české popisky jsou v lokalizaci.

### 8.4 Formát exportu (0.2)

`boda-export-YYYY-MM-DD.zip` → `data.json` (`formatVersion`, `exportedAt`, `appVersion`, `zones[]`, `activities[]`, `tasks[]`) + `photos/<photoId>.jpg`. Přesný popis je v [`docs/FORMAT_EXPORTU.md`](FORMAT_EXPORTU.md).

---

## 9. Soukromí, GDPR a bezpečnost

**Do MVP 0.2 včetně:** aplikace nemá účet ani backend a nic neodesílá. Stačí krátké prohlášení v obchodě a v aplikaci („data zůstávají v telefonu“) a pravdivě vyplněný formulář *Data safety* na Google Play.

**Od MVP 1.0** (účet, cloud, AI) je provozovatel správcem osobních údajů a musí:

| Oblast | Požadavek |
| --- | --- |
| Zásady ochrany soukromí | Veřejná stránka (CZ), odkaz v aplikaci i v obchodech. Kdo je správce, jaká data, proč, jak dlouho, kteří zpracovatelé (Supabase, poskytovatel LLM, Sentry, PostHog, RevenueCat, Google Play a App Store). |
| Souhlasy | Odděleně a odvolatelně: odesílání fotek k diagnostice, zpracování dotazů AI, analytika. Bez souhlasu s analytikou se nic analytického neodesílá. Záznam verze a času souhlasu. |
| Práva subjektu | Export dat (čl. 20) a **smazání účtu přímo v aplikaci i přes web** (vyžaduje i Google Play a App Store). Smazání (Edge Function) odstraní účet, data v databázi i fotky ve Storage do 30 dní; zahrady sdílené s jinými členy předá dalšímu vlastníkovi nebo smaže. |
| Minimalizace | Poloha zahrady zaokrouhlená (~1 km); z fotek se před nahráním odstraňují EXIF data včetně GPS; do LLM jde jen kontext potřebný k odpovědi, bez jména a e-mailu. |
| Umístění dat | Supabase, Sentry i PostHog v EU (Frankfurt); u poskytovatele LLM smlouva o zpracování (DPA) a ideálně zpracování v EU, bez použití dat k trénování. |
| Bezpečnost | RLS na každé tabulce a v úložišti fotek, s testy (kap. 8.1); v aplikaci jen veřejný klíč, servisní a API klíče jen v Edge Functions (kontrola v CI přes secret scanning); Edge Functions vyžadují přihlášení a hlídají limity na uživatele proti nákladovým útokům; zapnutý strop útrat v Supabase a limit útraty u poskytovatele LLM; CAPTCHA u registrace e-mailem. |
| Děti | Aplikace není určena dětem do 15 let (nesbírá se věk, uvedeno v zásadách). |

---

## 10. UI / UX

### 10.1 Principy

1. **Zápis musí být rychlejší než zapomenutí.** Hlavní akce „+ Záznam“ je vždy na jedno klepnutí.
2. **Venku na slunci, v rukavicích.** Velké dotykové plochy, vysoký kontrast, světlý motiv.
3. **Klid, ne stres.** Žádné reklamy, žádné agresivní notifikace, upozornění jen když na něm záleží. Tón Bódi: přátelský, věcný, bez poučování.
4. **Bez registrační zdi.** Aplikace jde používat hned; účet se nabídne až s funkcí, která ho potřebuje (záloha do cloudu, Bóďa). Aplikace začíná rovnou onboardingem (10.4), bez úvodní obrazovky a bez volby účtu; host je výchozí stav.
5. **Data patří uživateli.** Export je vždy zdarma a vždy dostupný.

### 10.2 Barvy a motivy

**Tmavý motiv** (z v2.0, implementováno v PR #1): pozadí `#020617` / `#0F172A`, povrchy `#1E293B`, primární tyrkysová `#2DD4BF`, sekundární zelená `#10B981`, varování oranžová `#F59E0B`, chyba červená `#EF4444`.

**Světlý motiv** (doplněno, od 0.2): pozadí `#F8FAFC`, povrchy `#FFFFFF` / `#F1F5F9`, text `#0F172A`, primární tmavší tyrkysová `#0F766E` (tyrkysová `#2DD4BF` na bílé nemá dostatečný kontrast pro text), sekundární `#047857`, varování `#B45309`, chyba `#B91C1C`.

**Výchozí motiv: podle systému** (s ručním přepnutím v nastavení). Ověřit kontrast všech kombinací textu a pozadí (≥ 4,5 : 1).

### 10.3 Obrazovky podle fází

| Obrazovka | 0.1 | 0.2 | 1.0 | V2 |
| --- | --- | --- | --- | --- |
| **Co dnes?** (bento dashboard) | hero karta z deníku, 7 dní, tip | + dnešní úkoly | + doporučení Bódi | + widget počasí |
| **Deník** | seznam po dnech, detail, filtr podle zóny | + typy, fulltext, víc fotek | + sklizeň, náklady | |
| **Zóny** | seznam | + archivace | + vlastnosti zóny | |
| **Úkoly** | – | seznam, kalendářní pohled týdne | + materiály, režim víkend | + úkoly z počasí |
| **Bóďa** | – | – | chat s akcemi | + diagnostika z fotky |
| **Nastavení** | – | motiv, tiché hodiny, export/import | účet, souhlasy, Premium | sdílení |

Widget počasí z v2.0 patří až do V2 (počasí v dřívějších fázích není).

### 10.4 Onboarding

Maximálně 3 kroky a 60 sekund: (1) „Co pěstuješ?“ velké karty s ikonami a ukazatelem průběhu, z výběru vzniknou zóny (**hotovo v 0.1**); (2) volitelně lokalita (obec) pro sezónní tipy (0.2); (3) první záznam. Vše jde přeskočit.

---

## 11. Byznys model

### 11.1 Úpravy proti v2.0 a proč

- **Cíl 100 000 aktivních uživatelů do roku 2026** je neplatný (je říjen 2026 a aplikace není venku). Nahrazen cíli po fázích (11.3).
- **129 Kč měsíčně** je pro českého hobby zahradníka hodně a měsíční platba se nehodí k sezónnímu používání (lidé by předplatné na zimu rušili). Hlavní tarif je **roční**.
- **Reklamy** ve Free tarifu odporují poslání „klid místo stresu“ a v malém českém trhu vydělají zanedbatelně. Aplikace je **bez reklam** v obou tarifech.
- **Deník zůstává vždy zdarma.** Je to jádro hodnoty a data uživatele; zpoplatnit jde chytrost nad ním.

### 11.2 Tarify (od 1.0, spuštění plateb na začátku sezóny 2028)

| | **Free** | **Premium** |
| --- | --- | --- |
| Deník, zóny, úkoly, připomínky, export | ✅ neomezeně | ✅ |
| Zahrady | 1 | neomezeně |
| Záloha a synchronizace textových dat | ✅ | ✅ |
| Záloha fotek do cloudu | do 200 fotek | neomezeně (fair-use) |
| Bóďa | 10 dotazů měsíčně | fair-use (např. 300 měsíčně) |
| Sklad, přehled sezóny | ✅ | ✅ |
| Počasí a zálivka, diagnostika z fotek, sdílení v rodině (V2) | – | ✅ |
| **Cena** | 0 Kč | **449 Kč / rok** nebo 69 Kč / měsíc |

**Výchozí cena je startovní hypotéza** (H3), ne dogma. Před spuštěním ověřit:
- **Náklad na jeden dotaz Bódi** (tokeny × cena modelu) a průměrný počet dotazů na platícího uživatele. Pravidlo: náklady na AI + cloud na platícího uživatele < 30 % čistého příjmu po poplatku obchodu (15 % v programech pro malé vývojáře).
- Zaváděcí akce v únoru–březnu (začátek sezóny), 7denní zkušební verze Premium.

### 11.3 Cíle po fázích (orientační)

| Milník | Cíl |
| --- | --- |
| Konec sezóny 2027 | 10–30 testerů, vyhodnocená H1 |
| Červen 2028 (první placená sezóna) | 1 000 aktivních uživatelů měsíčně v ČR/SK, ≥ 3 % platících |
| Červen 2029 | 5 000 aktivních uživatelů měsíčně, rozhodnutí o expanzi (PL, DE, AT) |

### 11.4 Sezónnost

Používání bude silně kolísat (vrchol duben–červen, minimum listopad–únor). Důsledky:
- Vydání nových verzí plánovat na únor–březen, kdy lidé plánují sezónu.
- Zimní funkce, které dávají smysl otevřít: přehled uplynulé sezóny (FR-D11), plánování výsevů, inventura osiv.
- Měřit retenci meziročně (H4), ne jen měsíčně.
- Roční tarif vyhlazuje příjmy přes zimu.

### 11.5 Konkurence (k ověření před 1.0)

Na trhu existují zahradnické deníky (např. Gardenize), plánovače záhonů (např. GrowVeg / Garden Planner), aplikace na rozpoznávání rostlin a chorob (např. Plantix, PictureThis) a aplikace na péči o pokojovky (např. Planta). **Mezera, kterou Bóďa cílí:** česky, s českými odrůdami a legislativou, a hlavně rada spočítaná z historie a parametrů konkrétního záhonu. Před 1.0 udělat krátkou rešerši aktuálního stavu konkurence a českých alternativ (zapsat do `docs/`).

---

## 12. Kvalita a testování

### 12.1 Testovací pyramida

| Úroveň | Co | Kdy |
| --- | --- | --- |
| **Unit** | Doménová logika: dashboard, plánovač notifikací a tiché hodiny, kalkulátor dávek, výměry polygonů, migrace, mapování entit. | Každá nová logika; cíl pokrytí domain + data ≥ 80 %. |
| **Widget** | Klíčové obrazovky: zápis záznamu, deník, zóny, úkoly; stavy načítání/chyby/prázdno. | Každá nová obrazovka. |
| **Integrační** | Šťastná cesta „první spuštění → záznam s fotkou → zobrazení v deníku → export → import“. | Od 0.2, v CI na emulátoru. |
| **Migrace** | Data uložená předchozí verzí se po aktualizaci načtou. | Každá změna schématu. |
| **Zabezpečení databáze** | Testy RLS (pgTAP, `supabase test db`) proti lokální Supabase: cizí uživatel nic nepřečte, člen bez práv nezapíše, `entitlements` mění jen backend. | Od 1.0, v CI. |
| **Kvalita Bódi** | Sada ≥ 30 referenčních dotazů s očekávanými vlastnostmi odpovědi (obsahuje dávku z kalkulátoru, nevymýšlí chemii, zmíní PHI…); hodnotí se automaticky (kontroly) + ručně před vydáním. | Od 1.0, při každé změně promptu nebo modelu. |
| **Ruční** | Krátký checklist před vydáním: režim letadlo, venku na slunci, velké písmo, starý telefon. | Každé vydání. |

### 12.2 Definice hotovo pro každý PR

Viz [`CODE_REVIEW_CHECKLIST.md`](../CODE_REVIEW_CHECKLIST.md). Minimum: CI zelené, testy pro novou logiku, žádné texty mimo lokalizaci (od 0.2), aktualizovaný DECLOG, pokud PR mění rozhodnutí nebo rozsah.

### 12.3 Vydávání

- Verzování SemVer `MAJOR.MINOR.PATCH+build`; verze aplikace odpovídá fázi (0.1.x, 0.2.x, 1.0.x).
- Android: interní testování → uzavřené testování → produkce. iOS: TestFlight → App Store.
- Každé vydání má krátké poznámky v češtině (co je nového).

---

## 13. Rizika

| Riziko | Pravděpodobnost | Dopad | Opatření |
| --- | --- | --- | --- |
| **Rozsah přeroste kapacitu** (spec na roky, jeden člověk) | vysoká | vysoký | Přísné fáze s definicí hotovo, NÁPADNÍK pro vše ostatní, každá nová funkce musí ukázat na hypotézu. |
| **Lidé přestanou zapisovat** (H1 neplatí) | střední | kritický | Rychlý zápis, šablony, připomínky; validace před investicí do AI a plátna. |
| **Zmeškaná sezóna** | střední | vysoký | MVP 0.2 k testerům do konce února 2027; zbytné věci škrtat, ne posouvat termín. |
| **Ztráta dat uživatele** | střední | vysoký | Export/import v 0.2, migrační testy, cloudová záloha v 1.0. |
| **AI poradí špatně** (dávka, chemie) | střední | vysoký (zdraví, právo, důvěra) | Kalkulátor místo LLM pro čísla, údaje o přípravcích jen z etikety/registru, referenční testy, upozornění, 👎 zpětná vazba. |
| **Náklady na AI převýší příjmy** | střední | střední | Měření nákladu na dotaz, limity ve Free, fair-use v Premium, levnější model pro jednoduché dotazy. |
| **Sezónnost** zabije retenci | vysoká | střední | Zimní funkce, roční tarif, měření H4. |
| **Licence dat** (počasí, mapy, registr přípravků) | střední | střední | Před V2 ověřit licenci pro komerční použití; mapové dlaždice nestahovat. |
| **Opuštěné knihovny** (`hive` 2.x) | už nastalo | nízký | Přechod na Drift v 0.2, repozitáře odstiňují úložiště. |
| **Závislost na poskytovateli backendu** | nízká | střední | Supabase je open source nad standardním PostgreSQL: schéma je v gitu jako SQL migrace, data jdou vyexportovat a projekt jde provozovat i u jiného poskytovatele. Žádná logika jen v klikacím rozhraní. |
| **Náklady a uspání projektu** | střední | nízký | Bezplatný tarif Supabase uspí neaktivní projekt; `prod` proto od spuštění na placeném tarifu (Pro), `dev` může zůstat zdarma. Strop útrat zapnutý. |
| **Závislost na jednom vývojáři / AI nástrojích** | vysoká | střední | Repo jako jediný zdroj pravdy (spec, DECLOG, README), CI, čitelný kód s testy. |

---

## 14. Způsob práce

Podrobně v [`COLLAB_WORKFLOW.md`](../COLLAB_WORKFLOW.md). Shrnutí:

- **Michal Papoušek (Papi)** – vlastník produktu a hlavní architekt: určuje cíle a priority; review může udělat kdykoli a jeho připomínky mají přednost.
- **Claude** (v tomto projektu) – implementace a revize: každý úkol běží ve vlastním vlákně, výstupem je PR s popisem, testy a zeleným CI, který vlákno po kontrole podle checklistu samo merguje (rozhodnutí Papiho z 8. 10. 2026).
- **Repozitář je paměť projektu.** Platí, co je v `docs/SPECIFIKACE.md`, `DECLOG.md` a v kódu. Externí poznámky (NotebookLM, chaty) jsou pomůcka, ne zdroj pravdy; nic nepovažujeme za „neomylné“, rozhodnutí lze změnit novým záznamem v DECLOGu.
- **Rozsah hlídá roadmapa:** nápad mimo aktuální fázi jde do NÁPADNÍKU, ne do kódu.

Povinné soubory repozitáře: `README.md`, `DECLOG.md`, `ENVIRONMENT.md`, `NAPADNIK.md`, `COLLAB_WORKFLOW.md`, `CODE_REVIEW_CHECKLIST.md`, `docs/SPECIFIKACE.md`. (Název `NÁPADNÍK.md` byl změněn na `NAPADNIK.md` bez diakritiky: diakritika v názvech souborů dělá potíže v git, URL a na Windows.)

---

## 15. Změny proti v2.0 a v2.1

### 15.1 Změny proti v2.0 (v2.1)

| # | Kapitola v2.0 | Změna | Důvod |
| --- | --- | --- | --- |
| 1 | – | Nová kapitola Hypotézy a měření (3) | Spec neříkala, jak poznat úspěch fáze; bez toho nejde rozhodnout, jestli pokračovat. |
| 2 | 3 Roadmapa | Vložena MVP 0.2 a sezóna validace; AI Bóďa přesunut z „2D dvojčete“ do 1.0 před plátno (1.1); definice hotovo u každé fáze | Hodnota je v radě na míru; výměru lze zadat číslem, plátno je drahé a rizikové. Sezónnost vyžaduje mít produkt u testerů do jara. |
| 3 | 3 Roadmapa | Úkoly (4.3) zařazeny do fáze (0.2) | V2.0 je neměla v žádné fázi, přitom na nich stojí „Co dnes?“. |
| 4 | 3, V2/V3 | AR, IoT, 3D stínování, on-device model → NÁPADNÍK | Vysoké náklady, neprokázaná hodnota. |
| 5 | 4.2 Bóďa | Čísla počítá kalkulátor, ne LLM; tvrdá pravidla pro chemii (etiketa, ÚKZÚZ, neprofesionální uživatelé, včely); offline chování; volání přes backend | Jazykové modely chybují v číslech; doporučení chemie má právní a zdravotní dopad. |
| 6 | 4.3 Úkoly | Tiché hodiny nastavitelné; digest; zimní režim | Pevné 21–08 nesedí všem (chalupář), v zimě je denní digest otravný. |
| 7 | 4.4 Sklad | Jednotky, pohyby zásob, storno odpisu, číslo povolení přípravku, PHI z etikety | „Transakční odpis“ bez jednotek a storna nejde implementovat spolehlivě. |
| 8 | 4.5 Vision | Cloud nejdřív, on-device do NÁPADNÍKU; nezobrazovat nekalibrovanou „jistotu“; odstranit EXIF/GPS | Vlastní model vyžaduje trénovací data; falešná přesnost škodí důvěře. |
| 9 | 4.6 Počasí | Srážky na zahradu, ne zónu; kryté zóny; konkrétní výchozí práh; licence zdroje | „Dostatečné množství“ nebylo definované; skleník déšť nedostane. |
| 10 | 4.1 Plátno | Druhá vzdálenost je kontrolní; podklad plánku; výpočty bez vlastního portu Turf | K měřítku stačí jedna vzdálenost, druhá ověřuje přesnost; existuje hotový port. |
| 11 | 5 NFR | „100 % offline“ upřesněno na jádro; doplněna trvanlivost dat, rychlost zápisu, použitelnost venku, přístupnost, lokalizace | AI a počasí bez internetu fungovat nemohou; spec si sama odporovala. |
| 12 | 6.1 Stack | Hive → Hive CE; Drift k rozhodnutí; CanvasKit upřesněn; StateNotifier zakázán v novém kódu; Android první | `hive` 2.x se neudržuje; CanvasKit je webový renderer, ne knihovna plátna. |
| 13 | 6.2 Schéma | Doplněny `activities`, `photos`, `users`, časová razítka, měkké mazání, `schemaVersion`; zahrady jako kolekce nejvyšší úrovně s členy; camelCase | Hlavní entita MVP v schématu chyběla; sdílení ve V2 by se schématem `users/{uid}/gardens` vyžadovalo migraci. |
| 14 | – | Nová kapitola Soukromí a GDPR (9) | Účet, fotky a AI v EU bez toho nejdou vydat; obchody vyžadují smazání účtu. |
| 15 | 7 UI | Světlý motiv a výchozí „podle systému“; widget počasí až ve V2; bez registrační zdi | Tmavý motiv je na slunci špatně čitelný; počasí v dřívějších fázích není. |
| 16 | 8 Byznys | Roční tarif 449 Kč, bez reklam, deník vždy zdarma, cíle po fázích místo 100 000 do 2026, sezónnost | Původní cíl je k říjnu 2026 neplatný; měsíční cena vysoká a nesedí sezónnímu používání. |
| 17 | 9 Metodika | Repo jako jediný zdroj pravdy, práce přes vlákna a draft PR | Projekt se přesunul sem; „neomylná“ externí paměť se nedá ověřit ani verzovat. |
| 18 | – | Nové kapitoly Testování (12) a Rizika (13) | Chyběly úplně. |
| 19 | celé | Opraveny překlepy a směs jazyků („Chemia“, „lhutu“, „bridges/mostků“, „full slunce“) | Čitelnost. |

### 15.2 Změny ve v2.2 (8. 10. 2026)

Papi rozhodl: backend bude Supabase a technologie ve specifikaci jsou předloha, ne závazek; pro každou část se má vybrat to správné. Podrobnosti a důvody v DECLOGu (D24–D32).

| # | Kapitola | Změna | Důvod |
| --- | --- | --- | --- |
| 1 | 7.1, 8, 9, 12 | Firebase → **Supabase** (PostgreSQL + RLS, Auth, Storage, Edge Functions); schéma Firestore převedeno na tabulky PostgreSQL; pravidla Firestore → RLS s testy pgTAP | Data deníku, zón a skladu jsou relační; SQL, transakce a joiny; předvídatelná cena místo platby za každé čtení a zápis; open source a přenositelná data. |
| 2 | 4.2, 7.1, 8.2 | Lokální databáze: `hive_ce` → **Drift (SQLite)** už od 0.2 | Model 1 : 1 se serverem, FTS5 pro fulltext, transakce pro sklad a outbox; jediná migrace dat proběhne před příchodem testerů (`hive_ce` čte soubory Hive beze změny). |
| 3 | 7.4 | Synchronizace: vlastní outbox s `server_updated_at` a triggerem „poslední zápis vyhrává“; PowerSync jako záložní varianta | Supabase nemá offline SDK; čas serveru řeší rozdílné hodiny telefonů. |
| 4 | 7.1 | Doplněny konkrétní volby: Sentry, PostHog (EU), RevenueCat, FCM jen jako doručovací kanál push | Crashlytics a Firebase Analytics odpadly s Firebase; platby a analytika ve spec neměly technologii. |
| 5 | 5.1 | `turf` jen pro rovinné predikáty, ne geodetickou plochu | Plátno má lokální souřadnice v metrech, geodetické funkce počítají ve stupních. |
| 6 | 8 | Pojmenování: snake_case v databázích, camelCase v Dartu a exportu | Konvence PostgreSQL a Driftu; v Dartu zůstává camelCase. |

---

## 16. Slovníček

| Pojem | Význam |
| --- | --- |
| **Zóna** | Logická část zahrady (záhon, sad, trávník, skleník). Má vlastnosti (výměra, půda, oslunění) a od 1.1 i tvar na plátně. |
| **Záznam / aktivita** (`Activity`) | Jedna zapsaná činnost v deníku. |
| **Úkol** (`Task`) | Činnost naplánovaná do budoucna; po dokončení z ní může vzniknout záznam. |
| **Zásoba** (`InventoryItem`) | Položka skladu: osivo, hnojivo, přípravek, nářadí. |
| **Incident** | Zdravotní problém rostlin v zóně s plánem řešení a kontrolami. |
| **PHI** | Ochranná lhůta: minimální počet dní mezi ošetřením přípravkem a sklizní (podle etikety). |
| **OOPP** | Osobní ochranné pracovní prostředky (rukavice, respirátor…). |
| **ÚKZÚZ** | Ústřední kontrolní a zkušební ústav zemědělský; vede registr povolených přípravků na ochranu rostlin. |
| **Guardrails** | Mantinely: pravidla, která brání nerealistickým nebo nebezpečným návrhům. |
| **Definice hotovo** | Ověřitelný seznam podmínek, po jejichž splnění je fáze nebo úkol dokončený. |
| **ADR** | Architecture Decision Record: zápis technického rozhodnutí (u nás v DECLOGu). |
