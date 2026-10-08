# NÁPADNÍK

Parkoviště nápadů, které **nejsou v aktuální roadmapě** ([docs/SPECIFIKACE.md](docs/SPECIFIKACE.md), kap. 4).
Nápad sem patří, když je dobrý, ale nedokazuje žádnou z hypotéz aktuální fáze. Neztratí se a nebrzdí vývoj.

**Jak s nápadníkem pracovat**
- Nový nápad = nový řádek v tabulce (datum, kdo, krátký popis, proč by to stálo za to).
- Na začátku každé fáze se nápadník projde: co dává smysl, přesune se do specifikace přes PR a záznam v DECLOGu.
- Nápad se nemaže, jen se mu změní stav (`čeká`, `přesunuto do vX`, `zamítnuto` + proč).

## Přesunuto ze specifikace v2.0

| Nápad | Proč zaparkováno | Kdy se vrátit | Stav |
| --- | --- | --- | --- |
| **AR obchůzka pozemku** | Velmi drahá na vývoj i testování (ARCore/ARKit, kalibrace venku), hodnota pro zahradníka neověřená. | Až bude 2D plátno používané a uživatelé budou chtít „vidět návrh na místě“. | čeká |
| **IoT senzory vlhkosti půdy** (BLE / Wi-Fi) | Hardware, párování, baterie, podpora různých výrobců; malé procento uživatelů senzory má. | Po V2 (zálivkový engine), pokud testeři budou chtít přesnější data než počasí. | čeká |
| **3D stínování a simulace slunce** | Potřebuje výšky objektů a 3D model; pro radu „slunce / polostín / stín“ stačí volba u zóny. | Po V3, pokud persona „stavitel“ bude významná. | čeká |
| **On-device model chorob** (TF Lite / Core ML) | Vyžaduje vlastní trénovací data a údržbu modelu. V2 začne cloudovým modelem se souhlasem. | Až bude známo, jaké problémy lidé fotí nejčastěji, a cloud bude drahý. | čeká |

## Nové nápady z revize v2.1

| Datum | Kdo | Nápad | Proč by to stálo za to | Stav |
| --- | --- | --- | --- | --- |
| 2026-10-08 | Claude | **Hlasový zápis** („Zalil jsem rajčata“ → záznam) | Nejrychlejší možný zápis s rukama v hlíně; přímo podporuje H1. Kandidát pro 0.2+, pokud H1 bude váhat. | čeká |
| 2026-10-08 | Claude | **Šablony činností** (opakované záznamy jedním klepnutím) | Zrychlí zápis rutinních prací (zálivka, sekání). | čeká |
| 2026-10-08 | Claude | **Widget na ploše** „+ Záznam“ a „Co dnes?“ | Zápis bez otevírání aplikace. | čeká |
| 2026-10-08 | Claude | **Katalog odrůd a plodin** (termíny výsevu, spon, sousedství) | Podklad pro Bódu i pro tipy; česká data jsou konkurenční výhoda. Pozor na licence zdrojů. | čeká |
| 2026-10-08 | Claude | **Střídání plodin** (co bylo v zóně minulé roky) | Logicky navazuje na deník po první sezóně; jednoduché upozornění „tady byla loni rajčata“. | čeká |
| 2026-10-08 | Claude | **Kalendář setí podle Měsíce** | Mezi českými zahrádkáři oblíbené; jen jako volitelná vrstva, bez tvrzení o účinnosti. | čeká |
| 2026-10-08 | Claude | **Sdílení fotky / přehledu sezóny** na sociální sítě | Přirozený marketing zdarma (přehled sezóny v zimě). | čeká |
| 2026-10-08 | Claude | **Výměna osiv mezi uživateli** | Komunita, retence přes zimu; ale moderace a odpovědnost. | čeká |
| 2026-10-08 | Claude | **Tisk / PDF plánu zahrady a deníku** | Dokumentarista, chalupář na chatě bez signálu. | čeká |
| 2026-10-08 | Claude | **Import z jiných aplikací / tabulek** (CSV) | Snižuje bariéru přechodu pro lidi, kteří už si něco vedou. | čeká |
| 2026-10-08 | Claude | **Sloučení dvou zahrad** při přihlášení na druhém telefonu (spec 7.4) | Teď jde jen převzít zahradu z účtu (DECLOG D70); sloučení by potřebovalo párování zón a duplicit. | čeká |
| 2026-10-08 | Claude | **Synchronizace fotek jen přes Wi-Fi** a menší náhled v cloudu | Šetří data; potřebuje zjišťování typu sítě a zmenšení náhledu v telefonu (DECLOG D70). | čeká |
| 2026-10-08 | Claude | **Ořez a sjednocení zón na plánu** (zóna oříznutá obrysem, sloučení dvou záhonů) | Teď plátno jen upozorní, že zóna přesahuje obrys (DECLOG D81); ořez potřebuje knihovnu pro rovinné operace. | čeká |
| 2026-10-08 | Claude | **Podklad plánu v cloudu** | Podklad je teď jen v telefonu (DECLOG D78); na druhém telefonu by se hodil, pokud to licence obrázku dovolí. | čeká |
