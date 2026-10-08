# DECLOG – deník rozhodnutí

Každé rozhodnutí: datum, co, proč, dopad.

## 2026-10-07 – Dokončení MVP 0.1 Offline Deník

**D1. Zůstáváme u Hive, ne Firestore.** *(backend od 1.0 je Supabase, viz D24; lokální DB od 0.2 Drift, viz D26)*
Proč: MVP 0.1 má být 100% offline a bez backendu. Firebase přijde se synchronizací v MVP 1.0.
Dopad: data jsou jen na zařízení, při odinstalaci zmizí. Synchronizace bude nová data source vrstva vedle Hive.

**D2. Riverpod `AsyncNotifier` bez generátoru `@riverpod`.**
Proč: specifikace chce `AsyncNotifier` a `AsyncValue.guard()`, to je splněné. Generátor `riverpod_generator` ale v současných verzích koliduje s `hive_generator` (různé verze analyzeru), a kvůli tomu by se musel měnit celý build.
Dopad: providery jsou psané ručně. Přechod na `@riverpod` je mechanický a dá se udělat spolu s přechodem na novější Hive (hive_ce) nebo Firestore.

**D3. Zóny jako jednoduchý seznam (id + název) v samostatném Hive boxu.**
Proč: MVP 0.1 říká „zóna ze seznamu“. Geometrie, pH, půda a oslunění patří k 2D plátnu v MVP 1.0.
Dopad: výchozí zóny Z1–Z3 mají stejná id jako dřívější napevno zadané zóny, takže starší záznamy se správně zobrazí. Zónu s existujícími záznamy nejde smazat, aby záznamy neosiřely.

**D4. Fotky se kopírují do složky aplikace.**
Proč: image picker vrací cestu do dočasné cache, kterou systém může smazat, a fotka by z deníku zmizela.
Dopad: fotka se zkopíruje až při uložení záznamu; při smazání záznamu nebo výměně fotky se stará kopie smaže. Na webu je fotka vypnutá.

**D5. `image_picker` místo `file_picker`.**
Proč: na zahradě je hlavní případ „vyfotit teď“, `file_picker` fotoaparát neumí.
Dopad: přidané iOS popisky oprávnění pro fotoaparát a galerii.

**D6. „Co dnes?“ bez úkolů a bez AI.**
Proč: úkoly (4.3) a AI Bóďa (4.2) jsou mimo rozsah MVP 0.1.
Dopad: dashboard počítá jen z deníku: dnešní záznamy, záznamy za 7 dní a zóny bez záznamu 7+ dní. Tip od Bódi je statický seznam podle měsíce.

**D7. Navigace přes `Navigator`, GoRouter odložen.**
Proč: tři záložky a dvě podobrazovky GoRouter nepotřebují a zbytečně by komplikovaly testy.
Dopad: s přibývajícími obrazovkami a deep linky v MVP 1.0 přejít na GoRouter.

**D8. Tmavý motiv jako výchozí.**
Proč: paleta ve specifikaci (kap. 7) je navržená pro dark mode.
Dopad: světlý motiv existuje, ale zatím se nepoužívá.

## 2026-10-08 – Revize specifikace v2.1

Rozhodnutí z revize specifikace ([docs/SPECIFIKACE.md](docs/SPECIFIKACE.md), přehled změn v kap. 15). Navrhl je Claude na základě zadání „projdi to celé a uprav to podle sebe, aby to bylo správně nebo lepší“; platí, dokud je Papi při review nezmění.

**D9. Specifikace žije v repozitáři jako `docs/SPECIFIKACE.md`, verze 2.1.**
Proč: v2.0 existovala jen v chatu a externích nástrojích, nedala se verzovat ani porovnávat. Originál v2.0 je archivovaný v `docs/archiv/`.
Dopad: změny specifikace jdou přes pull request; tento DECLOG eviduje proč.

**D10. Každá fáze má hlavní hypotézu a ověřitelnou definici hotovo.**
Proč: v2.0 neříkala, podle čeho poznat, že fáze uspěla. Bez toho se staví další patro na neověřeném základu. Klíčová neznámá je, zda lidé vydrží zapisovat (H1).
Dopad: kap. 3 a 4 specifikace. Přechod do další fáze řídí výsledek hypotézy, ne kalendář.

**D11. Mezi MVP 0.1 a 1.0 vložena MVP 0.2 „Spolehlivý deník“ a jarní validace v sezóně 2027.**
Proč: deník bez zálohy nejde dát testerům na celou sezónu (ztráta telefonu = ztráta dat), úkoly v roadmapě v2.0 chyběly úplně a sezónnost znamená, že produkt musí být u testerů do konce února, jinak se validace posune o rok.
Dopad: MVP 0.2 = export/import, typ činnosti, rychlý zápis, filtr, jednoduché úkoly s tichými hodinami, světlý motiv, technický dluh. 2D plátno a AI až po validaci.

**D12. AI Bóďa (1.0) jde před 2D plátno (1.1); výměru zóny lze zadat číslem.**
Proč: hodnota aplikace je rada na míru konkrétnímu záhonu, k té stačí výměra, půda a oslunění z formuláře. Plátno (kalibrace, 300 uzlů při 60 fps) je drahé a rizikové a samo o sobě hypotézu H2 neověří.
Dopad: MVP 1.0 = účet, synchronizace, vlastnosti zón, Bóďa, lehký sklad, platby; MVP 1.1 = plátno se stejnými `zoneId`.

**D13. Dávky a výměry počítá deterministický kalkulátor, ne jazykový model.**
Proč: LLM chybují v číslech a špatná dávka hnojiva nebo přípravku má reálné následky.
Dopad: model dostává spočítaná čísla jako vstup nebo volá kalkulátor jako nástroj; každá dávka v odpovědi uvádí zdroj.

**D14. Chemická ochrana jen podle etikety a registru ÚKZÚZ, jen přípravky pro neprofesionální uživatele.**
Proč: doporučení přípravků na ochranu rostlin má zdravotní a právní dopad; dávku ani ochrannou lhůtu nesmí AI odhadovat.
Dopad: FR-B4, referenční testy Bódi, pole `authorizationNo` a `nonProfessional` ve skladu.

**D15. Lokální databáze je zdroj pravdy, cloud je záloha a synchronizace (od 1.0).**
Proč: aplikace musí fungovat bez účtu a bez sítě stejně jako s nimi. Firestore offline cache by vyžadovala přihlášení online při prvním spuštění a není zaručeně trvalá.
Dopad: outbox, měkké mazání (`deletedAt`), „poslední zápis vyhrává“. Finální ADR (vlastní sync vs. Firestore cache, Hive CE vs. Drift) na začátku 1.0.

**D16. Firestore: zahrady jako kolekce nejvyšší úrovně s mapou členů; pole v camelCase; doplněny `activities`, `photos`, `users`.** *(tvar schématu nahrazen D28, princip platí)*
Proč: hlavní entita MVP (`Activity`) ve schématu v2.0 chyběla; sdílení zahrady ve V2 by se schématem `users/{uid}/gardens` vyžadovalo migraci; v2.0 míchala snake_case s Dart konvencí.
Dopad: kap. 8 specifikace; lokální model v 0.2 přebírá stejné názvy polí.

**D17. Přechod z `hive` na `hive_ce` v MVP 0.2.** *(nahrazeno D26)*
Proč: `hive` 2.x se už neudržuje; `hive_ce` je udržovaná, API-kompatibilní náhrada a řeší i kolizi generátorů z D2.
Dopad: úkol pro MVP 0.2, s migračním testem.

**D18. Světlý motiv a výchozí motiv „podle systému“ od 0.2 (nahrazuje D8).**
Proč: aplikace se používá venku na slunci, kde je tmavý motiv špatně čitelný. Tyrkysová `#2DD4BF` na bílé nemá dost kontrastu pro text, proto světlý motiv používá `#0F766E`.
Dopad: paleta v kap. 10.2; tmavý motiv zůstává jako volba.

**D19. Bez registrační zdi: host je výchozí stav.** *(úvodní obrazovka zrušena, viz D36)*
Proč: účet má smysl až s funkcí, která ho potřebuje; povinná registrace na začátku odradí.
Dopad: úvodní obrazovka „Začít bez registrace“ z PR #1 zůstává jako přivítání, ale nikdy účet nevyžaduje. Účet se nabídne při zapnutí zálohy do cloudu nebo Bódi.

**D20. Byznys: roční tarif 449 Kč (nebo 69 Kč/měsíc), bez reklam, deník vždy zdarma; cíl 100 000 uživatelů do 2026 zrušen.**
Proč: cíl k říjnu 2026 neplatí; 129 Kč měsíčně je pro českého hobby zahradníka hodně a měsíční platba nesedí sezónnímu používání; reklamy odporují poslání „klid místo stresu“.
Dopad: kap. 11; cena je hypotéza H3, před spuštěním plateb změřit náklad na dotaz Bódi.

**D21. AR, IoT senzory, 3D stínování a on-device model chorob přesunuty do NÁPADNÍKU.**
Proč: vysoké náklady, neprokázaná hodnota, malý tým.
Dopad: nejsou v roadmapě; vrátí se po ověření H1–H3.

**D22. Způsob práce: Papi + vlákna Clauda v projektu, výstupem PR, který vlákno po zeleném CI a kontrole samo merguje; repo je jediný zdroj pravdy.**
Proč: projekt se přesunul z kombinace ChatGPT / Gemini / NotebookLM do tohoto projektu; externí „neomylná paměť“ se nedá ověřit ani verzovat.
Dopad: [COLLAB_WORKFLOW.md](COLLAB_WORKFLOW.md), [CODE_REVIEW_CHECKLIST.md](CODE_REVIEW_CHECKLIST.md), šablona PR. Samostatné mergování rozhodl Papi 8. 10. 2026 („v GitHubu pracuj vždy sám“, volba „Merguj sám“).

**D23. `NÁPADNÍK.md` se jmenuje `NAPADNIK.md`.**
Proč: diakritika v názvech souborů dělá potíže v git (normalizace Unicode na macOS), v URL a na Windows.
Dopad: odkazy ve specifikaci a README vedou na `NAPADNIK.md`.

## 2026-10-08 – Supabase místo Firebase a revize technologií (specifikace v2.2)

Papi rozhodl: „tak použijeme Supabase. A takto to uprav též v celém projektu. Vždy vyber pro danou věc ten správný předmět. Ten co je aktuálně vedený, použij jako předlohu.“ Na základě toho Claude prošel stack po částech. Změny jsou ve specifikaci (kap. 7, 8, 9, 12, 13, přehled v kap. 15.2).

**D24. Backend od MVP 1.0 je Supabase, ne Firebase.**
Proč: data deníku, zón, úkolů a skladu jsou relační (zóna má záznamy, úkol materiály, materiál pohyby) a PostgreSQL to umí přímo: joiny, transakce, cizí klíče, SQL pro analýzu. Cena je předvídatelná (tarif za projekt), zatímco Firestore účtuje každé čtení a zápis dokumentu, což při synchronizaci deníku roste. Supabase je open source nad standardním PostgreSQL, takže data i schéma jdou kdykoli odnést. Hlavní výhoda Firebase (offline SDK) pro nás neplatí, protože zdrojem pravdy je lokální databáze (D15).
Dopad: Auth, Storage, Edge Functions a RLS místo Firebase Auth, Storage, Cloud Functions a pravidel Firestore; region EU (Frankfurt); projekty `dev` a `prod`, `prod` na placeném tarifu (bezplatný projekt se při neaktivitě uspí). Do kódu aplikace se nepřidávají žádné balíčky Firebase.

**D25. Technologie ve specifikaci jsou předloha, ne závazek.**
Proč: Papiho pravidlo „vždy vyber pro danou věc ten správný předmět“. Volba z v2.0/v2.1 vznikla bez porovnání alternativ.
Dopad: pro každou část se volí nástroj, který se na ni hodí nejlépe; změna = záznam v DECLOGu s důvodem; neměnit kvůli změně samotné. Pravidlo je v kap. 7.1 specifikace.

**D26. Lokální databáze je od MVP 0.2 Drift (SQLite), ne `hive_ce` (nahrazuje D17, uzavírá otevřenou otázku z D15).**
Proč: se Supabase je serverová databáze relační a Drift umí stejné tabulky a sloupce v telefonu (výchozí snake_case jako PostgreSQL). MVP 0.2 potřebuje fulltext (FTS5) a filtry, 1.0 transakce (sklad, outbox ve stejné transakci jako změna). Přechod na Drift až před 1.0 by znamenal převádět skutečná data testerů; v MVP 0.2 proběhne dřív, než testeři začnou zapisovat (konec února 2027). `hive_ce` v kódu od 0.1 (D33) čte soubory Hive beze změny, takže převod do Driftu je jediná skutečná migrace dat. Drift má typované migrace s testy proti snímkům schématu a funguje i na webu (WebAssembly).
Dopad: MVP 0.2 převede data z Hive (`hive_ce`) jednorázově při prvním spuštění (s testem). Odpadá kolize generátorů z D2.

**D27. Synchronizace je vlastní outbox nad Driftem; PowerSync je záložní varianta (upřesňuje D15).**
Proč: Supabase nemá offline SDK, takže nějakou synchronizační vrstvu potřebujeme tak jako tak. Pro deník jednoho uživatele stačí outbox, `upsert` podle UUID a „poslední zápis vyhrává“; další placená služba by byla zbytečná. Stahuje se podle času serveru (`server_updated_at`), aby nevadily rozdílně nastavené hodiny telefonů; trigger na serveru odmítne starší zápis.
Dopad: kap. 7.4. Pokud se se sdílením zahrad ve V2 ukáže vlastní synchronizace jako křehká, přejít na PowerSync (SQLite v telefonu, Drift ho podporuje).

**D28. Datový model jako tabulky PostgreSQL; členství v zahradě je tabulka; snake_case v databázích, camelCase v Dartu (nahrazuje tvar schématu z D16, princip zůstává).**
Proč: místo mapy `members` v dokumentu má relační databáze tabulku `garden_members`, nad kterou jde postavit RLS. snake_case je konvence PostgreSQL i výchozí chování Driftu (camelCase by v SQL vyžadoval uvozovky). Pole s proměnlivým tvarem (detaily položky skladu podle kategorie, nastavení, souhlasy) jsou `jsonb`; materiály úkolů a záznamů jsou vazební tabulky kvůli odpisu ve V2. Nárok na Premium je samostatná tabulka `entitlements`, kterou zapisuje jen backend.
Dopad: kap. 8; export (JSON) zůstává v camelCase.

**D29. Přihlášení přes Supabase Auth: Google, Apple a e-mail s jednorázovým kódem; bez hesel.**
Proč: Google a Apple pokrývají většinu uživatelů; App Store při přihlášení přes Google vyžaduje i alternativu šetrnou k soukromí a Sign in with Apple ji splní nejjednodušeji. Jednorázový kód místo hesla odpadá s resetem hesel. Anonymní přihlášení není potřeba, protože host pracuje jen lokálně (D19).
Dopad: Google přes nativní přihlášení a `signInWithIdToken`, Apple přes nativní dialog; návrat do aplikace přes deep link (GoRouter, 1.0).

**D30. Serverová logika v Supabase Edge Functions (TypeScript), ne Cloud Functions; ochrana backendu bez App Check.**
Proč: Edge Functions jsou součást Supabase, TypeScript zůstává. Supabase nemá obdobu Firebase App Check, ochranu proto dělá povinné přihlášení, limity dotazů na uživatele v Edge Function, strop útrat v Supabase a u poskytovatele LLM a CAPTCHA u registrace e-mailem.
Dopad: složka `supabase/` (migrations, functions, tests) od 1.0; tajné klíče jen v secrets Edge Functions.

**D31. Doplněné a změněné volby pro 1.0: Sentry, PostHog, RevenueCat, FCM jen jako doručovací kanál.**
Proč:
- *Crash reporting* „Crashlytics nebo Sentry“ → **Sentry** (EU): Crashlytics by znamenal Firebase jen kvůli pádům; Sentry má dobrou podporu Flutteru včetně webu a datové centrum v EU.
- *Analytika* (dosud bez volby) → **PostHog** v EU cloudu: kohorty a retence pro měření H1–H4, vlastní instance by šla i provozovat sám; odesílá se jen se souhlasem.
- *Platby* (dosud bez volby) → **RevenueCat** nad Google Play Billing a App Store: předplatné digitální služby musí jít přes obchody, RevenueCat řeší obě platformy, obnovy a zkušební verzi a webhookem nastaví `entitlements`. Vlastní ověřování účtenek by bylo zbytečná práce navíc.
- *Push ze serveru* (V2): **FCM jen jako doručovací kanál** (na Androidu standard), odesílá Edge Function; žádné jiné služby Firebase.
Dopad: kap. 7.1 a 9 (seznam zpracovatelů); balíčky se přidávají až ve fázi, kdy se funkce staví.

**D32. Revize ostatních částí stacku: co zůstává a proč.**

| Část | Rozhodnutí | Důvod |
| --- | --- | --- |
| Flutter (Android, iOS, web) | ponecháno | Jeden kód pro všechny platformy, existující kód MVP 0.1, dobrá podpora Driftu, Supabase i Sentry. |
| Feature-first clean architecture | ponecháno | Repozitáře v domain vrstvě dovolují vyměnit Hive za Drift bez zásahu do UI. |
| Riverpod (`AsyncNotifier`) | ponecháno; Riverpod 3 je v kódu od 0.1 (D33), `@riverpod` volitelně | Funguje a je v kódu; po odchodu z Hive generátory nekolidují, generátor není nutný. |
| Navigace: `Navigator` v 0.x, GoRouter od 1.0 | ponecháno | GoRouter je oficiální balíček Flutteru; v 1.0 jsou potřeba deep linky (notifikace, návrat z přihlášení). |
| Lokální notifikace `flutter_local_notifications` | ponecháno | Standard pro plánované notifikace bez serveru, udržovaný. |
| Geometrie: vlastní výpočet ploch + `turf` | ponecháno s upřesněním | `turf` jen na rovinné predikáty; jeho geodetické funkce počítají ve stupních, plátno má lokální metry (kap. 5.1). |
| AI Bóďa: LLM přes backend, poskytovatel na začátku 1.0 | ponecháno, backend = Edge Function | Výběr modelu teď by byl předčasný; kritéria (čeština, cena za dotaz, EU/DPA) platí. |
| Diagnostika z fotek: cloudový multimodální model (V2) | ponecháno | Specializované API jako alternativa porovnat na stejné sadě fotek před V2. |
| Počasí (V2): zdroj podle licence | ponecháno | Rozhodnutí patří před V2; Open-Meteo vyžaduje pro komerční aplikaci placený tarif, alternativa ČHMÚ. |
| Lokalizace `gen-l10n` + ARB | ponecháno | Oficiální řešení Flutteru, slovenština bez zásahu do kódu. |
| Testy `flutter_test` + Mockito | ponecháno | Už v kódu a v CI; výměna za Mocktail by nic nepřinesla. |
| CI GitHub Actions | ponecháno, od 1.0 rozšířeno | Od 1.0 přibudou testy databáze (`supabase test db`); iOS build přes macOS runner nebo Codemagic. |
| Distribuce: Google Play interní testování | ponecháno | Do 100 testerů zdarma a bez veřejné stránky v obchodě. |

## 2026-10-08 – Revize kódu MVP 0.1 (PR #5)

**D33. `hive_ce` a Riverpod 3 už v MVP 0.1, bez generátoru `@riverpod` (upřesňuje D2; cíl z D26 platí).**
Proč: balíček `hive` se už neudržuje a dokud aplikaci nikdo nepoužívá, je výměna nejlevnější. `hive_ce` čte soubory starého `hive` beze změny, takže to není převod dat, jen výměna balíčku. Riverpod 3 sám drží poslední data při chybě zápisu. Generátor providerů by přidal krok `build_runner` ke každé změně bez přínosu pro tak malý počet providerů.
Dopad: migrační test `test/core/local_storage_migration_test.dart` čte box zapsaný verzí 0.1. `hive_ce` je mezikrok: v MVP 0.2 data jednorázově převede do Driftu (D26) a čte je přitom přes `hive_ce`.

**D34. Fotka se v záznamu ukládá jako relativní cesta ke složce aplikace.**
Proč: na iOS se absolutní cesta ke složce aplikace mění s každou aktualizací; spec 8.2 to tak vyžaduje a usnadní to export (0.2).
Dopad: starší absolutní cesty se při zobrazení dohledají; fotky, které verze 0.1 nechala v cache, se při startu zkopírují do složky aplikace. Fotka se zmenšuje na 1 920 px (FR-D8).

**D35. `applicationId` a iOS bundle ID jsou `cz.zahradnikboda.app`.**
Proč: `com.example…` Google Play odmítne a po prvním nahrání už ID změnit nejde; aplikace zatím nikde vydaná není, takže změna nic nestojí.
Dopad: kdyby Papi chtěl jiné ID (např. podle vlastní domény), stačí ho změnit kdykoli před prvním nahráním do obchodu.

**D36. Onboarding a světlý motiv už v 0.1 (předsunuto z 0.2, viz D18); onboarding má jeden krok „Co pěstuješ?“, jde přeskočit a úvodní obrazovka „Začít bez registrace“ odpadá (upřesňuje D19).**
Proč: bez onboardingu nový uživatel dostal pět zón, které nemusí mít; podoba odpovídá spec 10.1 (bez úvodní obrazovky) a 10.4. Světlý motiv byl levný, protože paleta ve spec 10.2 je hotová.
Dopad: lokalita a první záznam ze spec 10.4 zůstávají na 0.2. Výchozí motiv je „podle systému“.

## 2026-10-08 – MVP 0.2 Spolehlivý deník

Rozhodnutí, která padla při stavbě MVP 0.2. Rozsah je spec kap. 4 (MVP 0.2) a tabulky FR s fází 0.2.

**D37. Převod dat z verze 0.1: zóny dostanou UUID a druh, záznamy odhadnutý typ.**
Proč: verze 0.1 měla zóny s pevnými id `Z1`–`Z7` a záznamy bez typu. Server (1.0) potřebuje UUID a číselník `zone.type`.
Dopad: `lib/core/storage/legacy_hive_import.dart` jednou při prvním spuštění 0.2 převede Hive do Driftu v jedné transakci (příznak `legacy_hive_import_at` v `app_settings`). `Z1` → zelenina, `Z2` → okrasná … podle pevné tabulky; typ záznamu se odhadne z názvu („Zálivka rajčat“ → `watering`), jinak `other`. Soubory Hive zůstávají na disku jako pojistka; když převod selže, aplikace se spustí a převod se zkusí znovu příště. Test čte box zapsaný verzí 0.1.

**D38. Do číselníku `zone.type` přibyly bylinky (`herbs`).**
Proč: onboarding 0.1 nabízí kartu Bylinky a bez vlastního druhu by dostala ikonu i budoucí rady „jiné“.
Dopad: spec 8.3 doplněna.

**D39. Fulltext v deníku se filtruje v paměti, ne přes FTS5 (upřesňuje D26).**
Proč: deník jednoho zahradníka má stovky až nízké tisíce záznamů, filtr v paměti je pod milisekundu. Uživatel píše bez diakritiky („zalivka“), což FTS5 bez vlastního tokenizéru neumí; normalizace v Dartu ano.
Dopad: `ActivityFilter` + `normalizeForSearch`. Přejít na FTS5, až to ukáže měření.

**D40. Čas připomínky je samostatný sloupec `tasks.remind_at` (minuty od půlnoci).**
Proč: `due` je den (spec 8.1). Úkol bez času se objeví jen v ranním přehledu, úkol s časem dostane i vlastní notifikaci.
Dopad: v 1.0 přibude sloupec i v PostgreSQL (`remind_at smallint`); export ho nese jako `"HH:MM"`.

**D41. Notifikace: nepřesné alarmy, plán na 14 dní, 30 minut ochrana před tichými hodinami.**
Proč: přesné alarmy na Androidu 14 vyžadují zvláštní oprávnění a Google Play ho kalendářovým aplikacím nedává automaticky. Nepřesný alarm se může o pár minut zpozdit, proto připomínka v posledních 30 minutách před tichými hodinami přijde na začátku této půlhodiny, ne přes noc. Plán se přepočítá při každé změně úkolů a nastavení a při spuštění.
Dopad: `ReminderPlanner` (unit test prochází všechny kombinace tichých hodin, „notifikace nikdy nepřijde v tichých hodinách“ z definice hotovo). O oprávnění k notifikacím se žádá až při uložení úkolu.

**D42. Záloha: „nahradit vše“, jen v aplikaci pro Android a iOS, formát v `docs/FORMAT_EXPORTU.md`.**
Proč: slučování dvou deníků bez synchronizace by vyžadovalo řešit konflikty; pro výměnu telefonu stačí nahradit vše (FR-E2). Web nemá souborový systém pro fotky.
Dopad: import nejdřív zálohu zkontroluje (ZIP, `data.json`, odkazy na zóny, cesty fotek) a teprve pak v jedné transakci vymění data; při chybě zůstanou stará data. Fotky jsou v ZIP bez komprese (JPEG už komprimovaný je). Připomínka zálohy (FR-E3) je karta na „Co dnes?“ 30 dní po posledním exportu, jen když je co zálohovat. V 1.0 se import musí přepsat na měkké mazání kvůli synchronizaci.

**D43. Nastavení jsou v tabulce `app_settings` (klíč → hodnota) a načítají se při startu.**
Proč: motiv musí být známý před prvním snímkem. V 1.0 se stejné hodnoty synchronizují jako `profiles.settings`.
Dopad: `DriftSettingsRepository`; neplatné hodnoty se nahradí výchozími.

**D44. Tipy od Bódi zůstávají v kódu, ne v ARB.**
Proč: jsou to obsahová data (sezónní rady podle měsíce), ne texty rozhraní; při překladu do slovenštiny se přesunou do obsahového souboru.
Dopad: lint „žádné texty mimo lokalizaci“ se na `boda_tips.dart` nevztahuje.

**D45. Onboarding 0.2 zůstává jednokrokový; lokalita až s tipy na míru (1.0), první záznam nabízí „Co dnes?“.**
Proč: lokalita je v 0.2 nice-to-have a tipy zatím na lokalitě nezávisí. Hero karta „Co dnes?“ po onboardingu rovnou nabízí „Zapsat aktivitu“, samostatný krok by jen přidal klepnutí.
Dopad: spec 10.4 kroky (2) a (3) se vrátí na pořad s Bóďou v 1.0.

**D46. Statistika pro testery počítá „týdny s aspoň 2 záznamy“.**
Proč: přesně to měří hypotéza H1 (≥ 60 % testerů zapisuje aspoň 2× týdně). Tester číslo opíše, aplikace nic neodesílá.
Dopad: obrazovka Statistika v Nastavení: záznamy za 8 týdnů, nejaktivnější zóny a práce.

**D47. Drift na webu přes WebAssembly; `web/sqlite3.wasm` a `web/drift_worker.js` jsou v repozitáři.**
Proč: webová verze má fungovat dál (spec 7.1). Soubory jsou z vydání balíčků `sqlite3` 3.7.0 a `drift` 2.35.2.
Dopad: při upgradu `drift` nebo `sqlite3` stáhnout odpovídající verze souborů.

**D48. Mockito odstraněno, testy stojí na repozitářích v paměti a na Driftu v paměti (upřesňuje D32).**
Proč: po odchodu z Hive Mockito nic nepoužívá; repozitáře v paměti jsou čitelnější a Drift v paměti testuje skutečné SQL.
Dopad: `test/helpers/fakes.dart`, `test/helpers/database.dart`.

**D49. Dart balíček se jmenuje `zahradnik_boda`.**
Proč: přípona `_mvp01` by se táhla celým projektem. Android `namespace` a názvy desktopových runnerů zůstávají, uživatel je nevidí a `applicationId` je už `cz.zahradnikboda.app` (D35).

## 2026-10-08 – MVP 1.0 Chytrý parťák, část 1: zahrada bez internetu

**D50. MVP 1.0 se dodává v několika PR: nejdřív části, které fungují bez účtu a internetu.**
Proč: 1.0 je velká fáze (účet, synchronizace, Bóďa, sklad, platby). Menší PR jdou zkontrolovat a vrátit. Spec 4.2 sice řadí 1.0 až po validaci H1 v sezóně 2027, ale Papi chce dotáhnout, co jde, a lokální funkce testerům v 0.x nevadí.
Dopad: část 1 = schéma v2, vlastnosti zón, sklad, nákupní seznam, úkoly s materiálem, režim víkend, sklizeň a náklady, přehled sezóny. Další části: Bóďa, backend Supabase s účtem a synchronizací, Premium a souhlasy.

**D51. Záložka „Zóny“ se mění na „Zahrada“: zóny, sklad a nákupní seznam pohromadě.**
Proč: sklad patří k zahradě, pátá záložka zůstane pro Bóďu (spec 10.3) a víc než pět položek spodní navigace Material nedoporučuje.
Dopad: Zahrada = karta Sklad (s počtem upozornění) + seznam zón; nákupní seznam z obrazovky Skladu. Klepnutí na zónu otevře detail s vlastnostmi a posledními záznamy, úprava je celá obrazovka (název, druh, výměra, půda, pH s datem, oslunění, závlaha, krytí).

**D52. Údaje položky skladu podle kategorie jsou JSON `details`; dávka z obalu je `dosePerM2` + `doseUnit`.**
Proč: spec 8.1 má `details jsonb`. Dávka na m² z obalu nebo etikety je jediný zdroj čísla pro kalkulátor Bódi (FR-B2), proto ji zadává uživatel přímo u hnojiva nebo přípravku; u přípravku i číslo povolení, ochrannou lhůtu a „povoleno pro neprofesionály“ (FR-B4).
Dopad: neznámá nebo poškozená data se načtou jako prázdná; nulová dávka = žádná dávka.

**D53. Nákupní seznam je tabulka `shopping_items` (ve spec 8.1 chyběla).**
Proč: FR-B5 chce z odpovědi Bódi „nákupní seznam“ a hlídač zásob (FR-S3) potřebuje kam docházející položku poslat. Seznam se má synchronizovat, proto tabulka, ne nastavení.
Dopad: položka může odkazovat na položku skladu; odškrtnutí takové položky s množstvím přičte koupené do skladu (ruční změna stavu, ne odpis z FR-S4). Hlídač ani Bóďa nepřidají položku, která už na seznamu nekoupená je.

**D54. Materiál úkolu se při zápisu do deníku zapíše jako `activity_materials`, stav skladu se nemění.**
Proč: automatický odpis je až ve V2 (FR-S4); záznam o spotřebě se ale hodí už teď (přehled sezóny, pozdější odpis).
Dopad: nový výskyt opakovaného úkolu přebírá dobu, nářadí i materiál.

**D55. Hlídač zásob: práh u položky, osiva 60 dní před datem, nářadí podle servisního intervalu.**
Proč: zimní inventura osiv (spec 11.4) potřebuje vědět dopředu, co koupit; 60 dní pokryje plánování před sezónou.
Dopad: upozornění na kartě Skladu, v Zahradě a na „Co dnes?“; žádné notifikace (klid, spec 10.1).

**D56. Režim víkend vybírá hladově: úkoly na řadě do 7 dní, zpožděné první, úkol bez odhadu = 30 min.**
Proč: FR-U8 chce seznam, který se vejde do času; optimální batoh by u pár úkolů nepřinesl nic viditelného a hůř by se vysvětloval.
Dopad: co se nevejde, je v sekci „Nevejde se“; obrazovka sečte nářadí a materiál „Vezmi s sebou“.

**D57. Přehled sezóny počítá kalendářní rok; v lednu a únoru ukazuje loňský; fotky = poslední z každého měsíce.**
Proč: FR-D11 je zimní důvod aplikaci otevřít. „Nejlepší fotky“ aplikace posoudit neumí, jedna za měsíc ukáže průběh sezóny.
Dopad: karta na „Co dnes?“ od listopadu do února, obrazovka i ze Statistiky. Sklizeň v gramech se sčítá do kilogramů.

**D58. Formát zálohy 2 jen přidává nepovinná pole; jeden dekodér čte verze 1 i 2.**
Proč: vlastnosti zón, sklad, nákupní seznam, sklizeň, náklady a materiál musí přežít výměnu telefonu (FR-E1); záloha z 0.2 se musí dát načíst (FR-E2).
Dopad: `docs/FORMAT_EXPORTU.md` popisuje verzi 2; test načte zálohu verze 1.

**D59. Navigace zatím zůstává `Navigator`; GoRouter až s první funkcí, která potřebuje adresy (upřesňuje D7, posouvá spec 7.1).**
Proč: přihlášení Googlem jde nativně (`signInWithIdToken`) a e-mailem jednorázovým kódem, takže návrat z prohlížeče není potřeba; klepnutí na notifikaci otevře aplikaci. Přepis všech obrazovek na GoRouter by teď nic nepřinesl a rozbil by testy.
Dopad: GoRouter s webovými adresami přijde s plánováním na velké obrazovce (1.1) nebo s odkazy z notifikací na konkrétní úkol.

## 2026-10-08 – MVP 1.0 Chytrý parťák, část 2: Bóďa

**D60. Bóďa je pátá záložka uprostřed spodní navigace (Dnes, Deník, Bóďa, Úkoly, Zahrada).**
Proč: rada na míru je hlavní hodnota 1.0 a hypotéza H2 měří, kolik lidí se Bódi ptá každý týden; schovaný v menu by se neměřil poctivě.
Dopad: záložka Bóďa ani Zahrada nemá plovoucí tlačítko pro nový záznam.

**D61. Dávky počítá kalkulátor v telefonu: dávka z obalu nebo etikety × výměra zóny (FR-B2).**
Proč: jazykové modely chybují v číslech. Výpočty jdou s dotazem jako `calculations` i se zdrojem dávky a model je jen přebírá (pravidlo v promptu funkce `boda-chat`).
Dopad: interní tabulka dávek, kterou FR-B2 připouští, zatím není. Bez ověřeného zdroje by to byl odhad; když dávka z obalu chybí, Bóďa ji neuvede a řekne, co doplnit. Přípravek bez povolení pro neprofesionály se nepočítá vůbec (FR-B4).

**D62. Kontext k dotazu je whitelist podle kontraktu `boda-chat`; zóny jmenované v dotazu určují, z kterých zón jdou záznamy (FR-B1).**
Proč: minimalizace dat (kap. 9) a menší, levnější dotaz. Limity: 50 zón, 30 záznamů, 30 otevřených úkolů, 100 položek skladu, 20 výpočtů; ze skladu jen údaje z obalu a etikety (bez šarže).
Dopad: lokalitu zahrada zatím nemá (`garden: null`), přijde s plátnem v 1.1 jako souřadnice zaokrouhlené na ~1 km. „Z čeho vycházím“ ukazuje shrnutí uložené ke každé odpovědi.

**D63. Druhá pojistka k FR-B4 běží v telefonu nad hotovou odpovědí.**
Proč: pravidla v promptu model většinou dodrží, ale ne vždy. Kontrola najde dávku, která není z výpočtu, etikety ani dotazu, přípravek jen pro profesionály a chybějící ochrannou lhůtu.
Dopad: u odpovědi se ukáže varování, odpověď se neschová. Je to heuristika (čísla s jednotkou na m² nebo ve větě o hnojení či postřiku), ne záruka.

**D64. Do připojení účtu běží Bóďa v ukázkovém režimu bez AI.**
Proč: skutečný backend potřebuje projekt Supabase a klíč k modelu, které ještě nejsou. Ukázkový režim odpovídá deterministicky z dat v telefonu (výpočty dávek, nejbližší úkoly, co dochází) a nabízí akce.
Dopad: je vždy označený banerem a štítkem u odpovědi; nic neodesílá, proto zatím nepotřebuje souhlas se zpracováním AI. Souhlas, přihlášení a volání `boda-chat` přijdou v části 3 za stejným rozhraním `AssistantBackend`.

**D65. Dotaz bez připojení čeká ve stavu `pending` a odešle se později (FR-B7).**
Proč: venku na zahradě často není signál; dotaz se nemá ztratit.
Dopad: odešle se po klepnutí na „Odeslat“ nebo při dalším otevření záložky. Ostatní chyby (přihlášení, limit, server) jsou `failed` s důvodem; vyčerpaný limit se neopakuje.

**D66. Rozhovory jsou v tabulkách `assistant_threads` a `assistant_messages` (schéma 3), v zálohovacím ZIPu nejsou.**
Proč: nejsou součást deníku; s účtem se budou synchronizovat a patří do exportu GDPR (FR-E5). Text zprávy je lokálně ve sloupci `body`, na serveru `text` (název `text` koliduje s API Driftu).
Dopad: import zálohy rozhovory nemaže. Hodnocení 👍/👎 s komentářem (FR-B6) se ukládá ke zprávě.

**D67. Úkol má zdroj `source` (`user`, `boda`, `weather`) podle spec 8.3.**
Proč: měření H2 a pozdější přehled „co navrhl Bóďa“.
Dopad: zdroj se ukládá, přechází na další výskyt opakovaného úkolu a je v záloze jako nepovinné pole formátu 2.

**D68. Akce z odpovědi se ukládají jedním klepnutím (FR-B5).**
Proč: rada má skončit v úkolech a nákupu, ne v chatu.
Dopad: úkol bez termínu dostane dnešek a neznámá zóna se zahodí. Položka nákupu se propojí se skladem podle názvu, aby šla po koupi přičíst. Záznam do deníku otevře předvyplněný formulář a uloží ho až uživatel.

## 2026-10-08 – MVP 1.0 Chytrý parťák, část 3: účet a synchronizace

**D69. Frontu změn plní triggery SQLite, odesílá ji jedna funkce `sync_push` v jedné transakci.**
Proč: trigger zachytí každý zápis, i ten, který repozitář nezná (obnova ze zálohy maže tabulky natvrdo). Úkoly a záznamy na sebe odkazují oběma směry, proto server přijme celou dávku najednou s odloženou kontrolou cizích klíčů.
Dopad: `sync_outbox` drží jen klíč řádku, obsah se čte až při odeslání. Řádek, který v telefonu už není, odejde jako náhrobek (`deleted`), server ho měkce smaže. Stažené změny se zapisují s příznakem `applying`, aby se neposlaly zpátky. Stahuje se po tabulkách podle `server_updated_at` s překryvem 5 s; poslední zápis vyhrává podle `updated_at` v telefonu i na serveru. Fotky dostaly sloupec `updated_at` (schéma 4).

**D70. Druhý telefon s jinou zahradou si vybere: převzít zahradu z účtu, nebo zůstat bez synchronizace.**
Proč: Free plán má jednu zahradu; sloučení dvou zahrad (spec 7.4 „sloučit nebo nahradit“) by potřebovalo párování zón a duplicit, které zatím nikdo nepotřebuje.
Dopad: převzetí smaže data v telefonu (po potvrzení) a stáhne zahradu z účtu, aplikace se znovu načte. Sloučení je v NAPADNIKu. Synchronizace běží při přihlášení, startu, návratu do aplikace a ručně; periodický časovač ani „jen přes Wi-Fi“ zatím nejsou (fotky jdou po jakékoli síti, náhled je zatím stejný soubor jako fotka).

**D71. Backend se zapíná při buildu přes `--dart-define` (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`); přihlášení e-mailem jednorázovým kódem.**
Proč: build bez backendu (testeři 0.2, CI) běží beze změny jen v telefonu. Kód z e-mailu nepotřebuje heslo ani přesměrování zpět do aplikace; Google a Apple potřebují nastavení v konzolích, která zakládá Papi.
Dopad: bez proměnných se účet nenabízí a Bóďa zůstává v ukázkovém režimu. Šablona e-mailu v Supabase musí obsahovat `{{ .Token }}`. Smazání účtu volá funkci `delete-account`, data v telefonu zůstanou. Rozhovory s Bóďou se synchronizují s ostatními daty.

**D72. Skutečná AI až po přihlášení a výslovném souhlasu; souhlas jde odvolat v Nastavení.**
Proč: dotaz s daty zahrady odchází k poskytovateli jazykového modelu (kap. 9, GDPR).
Dopad: bez souhlasu odpovídá ukázkový režim a nic neodchází; Bóďa ukáže kartu se souhlasem. Datum souhlasu se ukládá v nastavení telefonu; na server (`profiles.consents`) se zapíše s obrazovkou souhlasů v části 4.

## 2026-10-08 – MVP 1.0 Chytrý parťák, část 4: Premium, souhlasy, provoz

**D73. Platby jsou za rozhraním `PurchaseService`; balíček RevenueCat se přidá až s jeho klíči.**
Proč: nákup nejde vyzkoušet bez projektu RevenueCat, produktů v Google Play a App Store a podpisového klíče, a nativní balíček bez klíčů jen přidá riziko do buildu. Platby se podle spec 11.2 spouštějí až na začátku sezóny 2028.
Dopad: nabídka Premium (srovnání tarifů, 449 Kč ročně / 69 Kč měsíčně, 7 dní zdarma, obnovení nákupů) je hotová a ukazuje „spustíme na začátku sezóny 2028“. Nárok se čte ze serveru (`entitlements`, zapisuje jen webhook). Napojení = jedna třída `RevenueCatPurchaseService` (`purchases_flutter`, `Purchases.logIn(id uživatele)`), override v `main.dart`.

**D74. Souhlasy mají vlastní obrazovku a ukládají se i do `profiles.consents` s verzí zásad.**
Proč: kap. 9 chce souhlasy oddělené, odvolatelné a se záznamem verze a času.
Dopad: v 1.0 jsou dva souhlasy, zpracování dotazů AI a anonymní analytika; diagnostika z fotek přijde s V2. Odvolání se zapíše jako `granted: false` s časem. Adresa zásad je `PRIVACY_POLICY_URL` (výchozí `zahradnikboda.cz/soukromi`), stránku a text zásad musí zveřejnit Papi.

**D75. Hlášení pádů a analytika jsou rozhraní bez SDK, analytika jen se souhlasem.**
Proč: Sentry a PostHog potřebují účty (EU) a DSN/klíč; do té doby by SDK nic neposílalo.
Dopad: `CrashReporter` zachytí chyby Flutteru i nezachycené výjimky (zatím jen do konzole). `Analytics` posílá jen čísla a výčty (záznam, splněný úkol, dotaz na Bóďu, zobrazení nabídky) a bez souhlasu nic. Napojení = implementace rozhraní a override `analyticsSinkProvider` / `crashReporterProvider`.

**D76. Verze 1.0.0 = kód MVP 1.0 hotový; vydání čeká na účty a testy na zařízeních.**
Proč: zbývající kroky (Supabase projekty, klíč k modelu, RevenueCat, obchody, podpis, iOS build na Macu, testeři) nejdou udělat bez Papiho.
Dopad: build bez `--dart-define` je dál offline deník; s backendem je to celé MVP 1.0. Definice hotovo z kap. 4 (referenční dotazy ≥ 80 %, souběžná úprava na dvou zařízeních, RLS testy, smazání účtu) je ověřená automatickými testy kromě hodnocení referenčních dotazů, které potřebuje skutečný model.

## 2026-10-08 – MVP 1.1 2D plátno

**D77. Plán zahrady má souřadnice v metrech a synchronizuje se s ostatními daty.**
Proč: kalibrace (FR-P2) přepočítá rovnou body plánu, takže výměry a délky jsou v metrech bez dalšího převodu; plán je součást digitálního modelu zahrady a má být i na druhém telefonu.
Dopad: obrys je v `gardens.bounds` jako `{"outline": [[x, y], …]}`, tvar zóny v `zones.polygon`, vrstva v `zones.layer` (Drift schéma 5). `gardens.scale_meters_per_unit` zůstává nevyužitý. Funkce `sync_push` od migrace `20261008000600` zapisuje i tyto sloupce (pgTAP `07_plan_sync`). Záloha má formát 3 s nepovinnými poli `polygon`, `layer` a `garden.outline`.

**D78. Podklad plánu (fotka plánku, snímek mapy) zůstává jen v telefonu.**
Proč: FR-P3 je pomůcka pro kreslení; obrázky map mohou mít licenci, která nedovoluje je ukládat k nám, a nahrávání by stálo data i úložiště.
Dopad: obrázek se zkopíruje do `plan/` ve složce aplikace a jeho měřítko a poloha jsou v nastavení telefonu (`canvas_background`). Nesynchronizuje se ani nezálohuje; kalibrace ho posune a zvětší spolu s plánem a jde vrátit.

**D79. Zóna z Návrhu se v deníku, kalkulačce dávek a u Bódi nenabízí, dokud se nezrealizuje.**
Proč: záhon, který zatím neexistuje, by v rychlém zápisu a ve výpočtu dávek mátl.
Dopad: `ZoneEntity.isActive` = nearchivovaná a ve vrstvě Realita. V seznamu zón má Návrh vlastní sekci. „Zrealizovat“ přesune zónu do Reality a zapíše do deníku záznam typu Jiné.

**D80. Výměra z plánu se nastaví sama jen zóně bez výměry; zadanou výměru přepíše až po potvrzení.**
Proč: FR-P4 („přepíše ručně zadanou výměru s potvrzením“); výměru z 1.0 mohl uživatel změřit přesněji, než ji nakreslil.
Dopad: když se plocha z plánu liší o víc než 1 %, plátno nabídne „Použít“. Zóna na plátně je stejný záznam jako zóna v seznamu (stejné `id`), tvar jde odebrat a zóna zůstane.

**D81. Geometrie: plochy, délky a kalibrace počítá vlastní kód, „bod v polygonu“ a „polygon v polygonu“ balíček `turf`.**
Proč: spec 5.1; geodetické funkce `turf` počítají ve stupních a na metrové souřadnice se nehodí. Ořez a sjednocení polygonů zatím nikdo nepotřebuje, knihovnu pro ně nevybírám.
Dopad: zóna přesahující obrys se uloží, plátno jen upozorní. Historie zpět/znovu drží 20 kroků; tah uzlem je jeden krok. Plynulost 60 fps s 300 uzly ověří až test na telefonu střední třídy (definice hotovo, kap. 4); kreslení je jeden `CustomPainter` bez widgetů na uzel.

## 2026-10-08 – V2, část 1: odpis ze skladu a incidenty

**D82. Odpis ze skladu (FR-S4) se zapíše při dokončení úkolu a stornuje při jeho vrácení; stav skladu je dál sloupec položky.**
Proč: spec chce pohyb a snížení stavu v jedné transakci. Počítat stav jen ze součtu pohybů by znamenalo přepsat sklad i synchronizaci, a dvě souběžné úpravy stavu jedné položky na dvou telefonech jsou zatím vzácné.
Dopad: `inventory_movements` (Drift schéma 6) s důvody `task`, `reversal`, `purchase` (odškrtnutí nákupu s doplněním skladu) a `manual` (změna stavu ve formuláři). Odpis převádí jednotky jen v rámci veličiny (g a kg ano, kg a litry ne, takový materiál se přeskočí a hláška to řekne). Stav nejde pod nulu; odepíše se, co je, a aplikace řekne, kolik chybělo. Úkol se neodepíše dvakrát. Při souběžné úpravě stavu stejné položky na dvou telefonech vyhrává poslední zápis stavu, pohyby zůstanou všechny; přepočet stavu z pohybů je v NAPADNIKu.

**D83. Incident jde založit ručně (FR-V4); kontroly D+3 a D+7 jsou obyčejné úkoly s `incident_id`.**
Proč: úkoly už umí připomínky, tiché hodiny a víkendový režim; kontrola nemusí mít vlastní mechanismus.
Dopad: tabulka `incidents` v telefonu i na serveru (migrace `20261008000700`, RLS jako ostatní data zahrady, pgTAP `08_incidents_stock`), fotky incidentu jsou řádky `photos` s `incident_id`. Vyřešení incidentu přeskočí jeho otevřené kontroly. Chemický plán je volný text s trvalým upozorněním na etiketu (FR-B4); dávku aplikace sama nenavrhuje. Porovnání „před a po“ ukazuje první a poslední fotku. Diagnostika z fotky (FR-V1, FR-V2) přijde v další části a bude plnit `source = model` a `candidates`.

**D84. Záloha formát 4: incidenty, pohyby na skladě a vazba úkolu na incident.**
Proč: záloha má obnovit všechno, co uživatel zapsal (FR-E1).
Dopad: nová pole jsou nepovinná, starší zálohy se načtou. Fotky incidentů jsou ve stejné složce `photos/` jako fotky záznamů.

## 2026-10-08 – V2, část 2: počasí, zálivka, mráz a kalendář prací

**D85. Počasí stahuje Edge Function `weather` s klíčem poskytovatele v secrets; je jen pro Premium, poloha se ukládá zaokrouhlená na ~1 km.**
Proč: spec 5.6 a kap. 11 (počasí a zálivka jsou v Premium); klíč nesmí být v aplikaci (kap. 9). Open-Meteo je zdarma jen nekomerčně, placená aplikace potřebuje placený tarif nebo jiný zdroj s licencí, a to vybírá Papi.
Dopad: funkce volá API ve tvaru Open-Meteo (`WEATHER_API_URL`, `WEATHER_API_KEY`), bez nich vrací `503`, bez Premium `402`. Poloha je ve sloupcích `gardens.location_lat/lng` (2 desetinná místa) a `altitude_m`, synchronizuje se (migrace `20261008000800`, pgTAP `09_garden_location`) a je v záloze. Počasí se ukládá v telefonu a stahuje znovu po 3 hodinách nebo tažením dolů; bez signálu se ukazuje poslední stažené. Poloha telefonu (`geolocator`, přibližná) se zjistí jen po klepnutí, jde ji zadat i ručně. Push upozornění (mráz) přijdou s FCM, které potřebuje účet Papiho; zatím je varování na dashboardu.

**D86. Zálivka: srážky jsou zahrady, práh je podle druhu zóny, odložení je návrh na jedno klepnutí, automatika nejvýš jednou denně.**
Proč: FR-W2 a FR-W3. Výchozí prahy (bylinky 12 mm, zelenina a ostatní 15 mm, ovoce a trávník 20 mm za 7 dní; předpověď ≥ 5 mm na dnešek nebo zítřek) jsou startovní hodnoty k ověření v praxi. Denní data nemají hodiny, proto „příštích 24 h“ = vyšší z dneška a zítřka.
Dopad: krytá zóna a skleník déšť nezapočítávají, jezírko a stavba zálivku neřeší. Úkol zálivky se pozná podle názvu (úkoly nemají typ). Úkol bez zóny se odloží, jen když může počkat každá nekrytá zóna. Odložení posune úkol o den za den, kdy je na řadě; automatika se spustí po stažení počasí a jen jednou za den, aby úkol neujížděl. Varování před mrazem (≤ 0 °C v příštích 3 dnech, březen až červen a září až říjen) se týká nekrytých zón, kde se za posledních 8 týdnů selo nebo sázelo.

**D87. Fenologický kalendář je zdarma a offline: startovní tabulka 16 prací pro ČR posunutá o 3 dny na 100 m výšky.**
Proč: FR-W5; kap. 11 ho mezi placenými funkcemi nemá a nic nestojí. Hopkinsův zákon (zhruba 3 dny na 100 m) je dost dobrý start; skutečný průběh jara je přesnější, ale potřebuje data, která zatím nemáme.
Dopad: okna jsou pro 250 m n. m.; výška se bere zadaná, jinak z počasí, jinak 300 m. Jarní práce se s výškou posouvají později, podzimní dřív. Ukazují se jen práce pro druhy zón, které zahrada má; „Teď je čas“ je i na dashboardu a každou práci jde přidat jako úkol.


## 2026-10-08 – V2, část 3: diagnostika z fotek a sdílení zahrady

**D88. Diagnostika z fotky jde přes Edge Function `diagnose`: jen Premium, jen se souhlasem s nahráním fotek, bez EXIF a s 1–3 kandidáty bez chemie a dávek.**
Proč: FR-V1 a FR-V2; spec kap. 9 chce samostatný souhlas pro posílání fotek a zákaz polohy v metadatech; AI nikdy nepočítá dávky (D23). Model se volí jen přes `LLM_MODEL`, klíč je v secrets.
Dopad: aplikace před odesláním odstraní z JPEGu segmenty APP1 (EXIF a XMP s polohou), APP13 a komentáře; server JPEG s metadaty odmítne (`400 metadata_present`) a fotku nikam neukládá. Souhlas je v `profiles.consents.photoUpload` a server ho ověřuje sám (`403 consent_required`); v aplikaci se dá zapnout v dialogu u prvního použití nebo na obrazovce souhlasů. Diagnóza čerpá ze stejného měsíčního limitu jako Bóďa a při chybě modelu se dotaz vrací. Výsledek je „Možná jde o…“ s důvodem, čím to ověřit a šetrnou péčí; zvolený kandidát vyplní název incidentu a prázdný šetrný plán, incident dostane `source = model` a všechny kandidáty. Chemický plán zůstává na uživateli a etiketě (FR-B4). Na webu tlačítko není (fotky tam nejsou).

**D89. Sdílení zahrady kódem pozvánky: zve vlastník s Premium, kód má 8 znaků, platí 7 dní a jednou; pozvaný je vždy člen s právem zápisu.**
Proč: FR-S5 a kap. 11.2 (rodinné sdílení je v Premium); spec mluví o vlastníkovi a členech, role jen pro čtení zatím nemá využití. Kód se dá nadiktovat po telefonu, odkaz by potřeboval doménu a deep linky.
Dopad: tabulka `garden_invites` bez přístupu z aplikace, vše přes RPC `create_garden_invite`, `accept_garden_invite`, `garden_member_list` (migrace `20261008000900`, pgTAP `10_garden_sharing`). Kód nepoužívá 0/O ani 1/I/L. Pozvat nejde zahradu, kterou synchronizace ještě nenahrála. Členové zahrady vidí jména a e-maily ostatních členů. Připojení nahradí data v telefonu sdílenou zahradou; změny z telefonu se před tím odešlou a dosavadní zahrada zůstane v účtu. Vlastník může člena odebrat, člen může zahradu opustit; telefon, který k zahradě ztratí přístup, to pozná při synchronizaci a nabídne začít novou prázdnou zahradu. Změny ostatních se přenesou synchronizací (ne v reálném čase); souběžné úpravy řeší poslední zápis jako dosud (D70).

## 2026-10-08 – V3: parametrické návrhy staveb

**D90. Návrhy staveb počítá aplikace v telefonu, offline a zdarma: čtyři šablony, výkres, výkaz materiálu a rozpočet z orientačních cen, které uživatel přepíše.**
Proč: spec 5.7 (FR-G1). Ceník v kap. 11.2 návrhy mezi placenými funkcemi nemá a výpočet nic nestojí; jestli budou v Premium, rozhodne Papi. AI do výpočtů nevstupuje (D23). Ceny materiálu se liší podle obchodu a kraje, proto jsou výchozí ceny jen orientační (Kč s DPH, podzim 2026) a u každé položky jdou přepsat.
Dopad: `lib/features/builds`, Drift schéma 8 (tabulka `builds`: šablona, parametry a ceny jako JSON), synchronizace (migrace `20261008001000`, pgTAP `11_builds`), záloha formát 5. Výkres, výkaz a mantinely se neukládají, počítají se z parametrů, takže oprava výpočtu se projeví i ve starých návrzích. Výkres je půdorys, u chodníku příčný řez vrstvami. Výkaz jde jedním klepnutím přidat na nákupní seznam. Vstup je karta Stavby v záložce Zahrada; umístění stavby na plán zahrady je v NAPADNIKu.

**D91. Mantinely počítají dřevo jako C24 zjednodušeně podle ČSN EN 1995-1-1 s opatrnými součiniteli; u mostku nad 3 m rozpětí nebo 1 m výšky doporučí statika.**
Proč: FR-G2 a FR-G3. Pevná tabulka limitů by nepokryla kombinace rozměrů a průřezů; posouzení ohybu, smyku a průhybu prostého nosníku je krátké a dá se ověřit testem. Součinitele jsou záměrně na straně bezpečnosti (kmod 0,65, dotvarování, průhyb L/300 u mostku a L/200 u střechy, mostek zatížený jako dav 5 kN/m²) a statika nenahrazují.
Dopad: záhon: mezisloupky podle tloušťky prken (25, 32, 40 mm → pole 1,0, 1,3, 1,6 m, u záhonu nad 0,6 m o pětinu kratší), rozpěry u vyšších dlouhých záhonů, varování nad 1,2 m šířky. Chodník: vrstvy podkladu podle povrchu, kamenivo v tunách, varování u dlažby bez obrubníku. Mostek: posouzení nosníků s návrhem většího průřezu, pole podlahových prken (28, 32, 40 mm → 0,5, 0,6, 0,8 m), zábradlí nad 0,5 m. Přístřešek: krokve a vaznice se sněhem podle sněhové oblasti I až V, sloupky se přidají, dokud vaznice nevyhoví; nad 25 m² upozornění na stavební úřad, kotvení vždy. Mantinely návrh nikdy neblokují, jen ukážou důvod a doporučení. Upozornění „Orientační návrh, nejde o autorizovaný statický výpočet.“ je trvale v seznamu návrhů i v každém návrhu.

## 2026-10-08 – Zprovoznění na Papiho počítači (Windows)

**D92. Na Windows leží projekt v cestě jen z ASCII znaků (`C:\dev\Boda`), Flutter projektu je samostatná instalace vedle systémové a testy nesmí záviset na časovém pásmu.**
Proč: uživatelská složka `C:\Users\Bóďa` má diakritiku. Android Gradle plugin build v takové cestě odmítne („project path contains non-ASCII characters“) a `flutter analyze` 3.47.6 v ní padá s `FormatException` v LSP kanálu analyzeru. Z `C:\dev\Boda` projde `flutter analyze` i `flutter build apk`. Systémový Flutter 3.35.7 (Dart 3.9) na projekt nestačí (`drift_dev` chce Dart ≥ 3.10) a mohou ho používat jiné projekty, proto je verze z CI zvlášť v `C:\dev\flutter-3.47.6`. Test importu z Hive 0.1 porovnával místní čas a v Praze (UTC+2) padal, zatímco v CI (UTC) prošel; fixtura uchovává okamžik, ne místní čas.
Dopad: `android.overridePathCheck` se nepoužívá, místo toho jiná složka. Build na Androidu potřebuje NDK 28.2.13676358 (sdkmanager). Když Gradle hlásí „Unable to establish loopback connection“, pomůže nastavit `TMP` a `TEMP` na složku bez diakritiky (např. `C:\dev\tmp`). Test `legacy_hive_import_test` srovnává v UTC.

**D93. Vývojový backend je projekt Supabase „Zahradník“ (organizace `zahradnik-boda-dev`, Frankfurt, Free); počasí v dev bere bezplatné Open-Meteo, Bóďa výchozí model `claude-sonnet-5-5`.**
Proč: Papi projekt založil sám a bezplatný tarif dovolí na účtu jen dva projekty, proto se nový `zahradnik-boda-dev` nezakládal. Bezplatné `api.open-meteo.com` je jen pro nekomerční použití, na vývoj stačí; `prod` potřebuje placený tarif s klíčem (D85). Sonnet je rozumný kompromis ceny a kvality pro chat; model je jen v secrets (`LLM_MODEL`), dá se změnit bez vydání aplikace.
Dopad: migrace 0000 až 1000 a všech pět Edge Functions jsou nasazené (`supabase functions deploy --use-api`, bez Dockeru). Aplikace se připojí přes `--dart-define-from-file=env/dev.json` (publishable klíč, mimo git). Délka přihlašovacího kódu je 6 číslic a v Redirect URLs je `cz.zahradnikboda.app://login-callback`. Šablonu e-mailu s `{{ .Token }}` Supabase na Free s vestavěným e-mailem změnit nedovolí, takže přihlášení začne fungovat až s vlastním SMTP.

**D94. Edge Functions běží s `verify_jwt = false`, přihlášení ověřuje jen funkce sama (`auth.getUser`).**
Proč: nové projekty Supabase podepisují tokeny asymetrickým klíčem (ES256). Starší ověřování v bráně Edge Functions je odmítá, takže Bóďa vracel chybu i přihlášenému uživateli. Všech pět funkcí si uživatele ověřuje samo a bez platného tokenu vrací 401, druhá kontrola v bráně tedy nic nepřidává. Supabase pro nové klíče postupuje stejně. Rozhodl Papi (volba A, 8. 10. 2026).
Dopad: `supabase/config.toml` má u `boda-chat`, `weather`, `diagnose` a `delete-account` `verify_jwt = false` a nasazuje se s `--no-verify-jwt`. Každá nová funkce pro přihlášené uživatele musí sama volat `authenticateRequest` (`_shared/supabase.ts`) a bez uživatele vrátit 401. Ověřeno: neplatný token dostane 401 `unauthorized`. Složka `env/` (soubory pro `--dart-define-from-file`, D71) je v `.gitignore`, aby se do gitu nedostala adresa a klíč konkrétního projektu Supabase; hodnoty nejsou tajné, ale patří k jednomu počítači.
