# DECLOG – deník rozhodnutí

Každé rozhodnutí: datum, co, proč, dopad.

## 2026-10-07 – Dokončení MVP 0.1 Offline Deník

**D1. Zůstáváme u Hive, ne Firestore.**
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

**D16. Firestore: zahrady jako kolekce nejvyšší úrovně s mapou členů; pole v camelCase; doplněny `activities`, `photos`, `users`.**
Proč: hlavní entita MVP (`Activity`) ve schématu v2.0 chyběla; sdílení zahrady ve V2 by se schématem `users/{uid}/gardens` vyžadovalo migraci; v2.0 míchala snake_case s Dart konvencí.
Dopad: kap. 8 specifikace; lokální model v 0.2 přebírá stejné názvy polí.

**D17. Přechod z `hive` na `hive_ce` v MVP 0.2.**
Proč: `hive` 2.x se už neudržuje; `hive_ce` je udržovaná, API-kompatibilní náhrada a řeší i kolizi generátorů z D2.
Dopad: úkol pro MVP 0.2, s migračním testem.

**D18. Světlý motiv a výchozí motiv „podle systému“ od 0.2 (nahrazuje D8).**
Proč: aplikace se používá venku na slunci, kde je tmavý motiv špatně čitelný. Tyrkysová `#2DD4BF` na bílé nemá dost kontrastu pro text, proto světlý motiv používá `#0F766E`.
Dopad: paleta v kap. 10.2; tmavý motiv zůstává jako volba.

**D19. Bez registrační zdi: host je výchozí stav.**
Proč: účet má smysl až s funkcí, která ho potřebuje; povinná registrace na začátku odradí.
Dopad: úvodní obrazovka „Začít bez registrace“ z PR #1 zůstává jako přivítání, ale nikdy účet nevyžaduje. Účet se nabídne při zapnutí zálohy do cloudu nebo Bódi.

**D20. Byznys: roční tarif 449 Kč (nebo 69 Kč/měsíc), bez reklam, deník vždy zdarma; cíl 100 000 uživatelů do 2026 zrušen.**
Proč: cíl k říjnu 2026 neplatí; 129 Kč měsíčně je pro českého hobby zahradníka hodně a měsíční platba nesedí sezónnímu používání; reklamy odporují poslání „klid místo stresu“.
Dopad: kap. 11; cena je hypotéza H3, před spuštěním plateb změřit náklad na dotaz Bódi.

**D21. AR, IoT senzory, 3D stínování a on-device model chorob přesunuty do NÁPADNÍKU.**
Proč: vysoké náklady, neprokázaná hodnota, malý tým.
Dopad: nejsou v roadmapě; vrátí se po ověření H1–H3.

**D22. Způsob práce: Papi + vlákna Clauda v projektu, výstupem draft PR, merguje jen Papi; repo je jediný zdroj pravdy.**
Proč: projekt se přesunul z kombinace ChatGPT / Gemini / NotebookLM do tohoto projektu; externí „neomylná paměť“ se nedá ověřit ani verzovat.
Dopad: [COLLAB_WORKFLOW.md](COLLAB_WORKFLOW.md), [CODE_REVIEW_CHECKLIST.md](CODE_REVIEW_CHECKLIST.md), šablona PR.

**D23. `NÁPADNÍK.md` se jmenuje `NAPADNIK.md`.**
Proč: diakritika v názvech souborů dělá potíže v git (normalizace Unicode na macOS), v URL a na Windows.
Dopad: odkazy ve specifikaci a README vedou na `NAPADNIK.md`.
