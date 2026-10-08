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
Proč: se Supabase je serverová databáze relační a Drift umí stejné tabulky a sloupce v telefonu (výchozí snake_case jako PostgreSQL). MVP 0.2 potřebuje fulltext (FTS5) a filtry, 1.0 transakce (sklad, outbox ve stejné transakci jako změna). Přechod `hive` → `hive_ce` teď a `hive_ce` → Drift před 1.0 by znamenal dvě migrace, z toho druhou na skutečných datech testerů; jedna migrace teď proběhne dřív, než testeři začnou zapisovat (konec února 2027). Drift má typované migrace s testy proti snímkům schématu a funguje i na webu (WebAssembly).
Dopad: MVP 0.2 převede data z Hive jednorázově při prvním spuštění (s testem). Odpadá kolize generátorů z D2.

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
| Riverpod (`AsyncNotifier`) | ponecháno; Riverpod 3 a `@riverpod` volitelně | Funguje a je v kódu; po odchodu z Hive generátory nekolidují, přechod není nutný. |
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
