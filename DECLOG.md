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
