# Jak spolu pracujeme

Tento dokument nahrazuje „projektovou směrnici v1.6“ (ChatGPT jako kodér, Gemini jako auditor, NotebookLM jako paměť). Od října 2026 vývoj běží v projektu Claude, kde Papi zadává práci a vlákna Clauda ji dodávají jako pull requesty.

## Role

| Kdo | Co dělá | Co nedělá |
| --- | --- | --- |
| **Papi** (Michal Papoušek) – vlastník produktu a hlavní architekt | Určuje cíle, priority a rozsah fází. Zadává úkoly v chatu projektu. Může kdykoli udělat review nebo PR zastavit komentářem. Rozhoduje spory a mění DECLOG. | Nemusí psát kód ani ručně kopírovat výstupy mezi nástroji. |
| **Claude – koordinátor** (chat projektu) | Přijme zadání, založí pro něj vlákno, hlídá, aby se vlákna nepřekrývala, a odpovídá na otázky o stavu projektu. | Sám kód nepíše. |
| **Claude – vlákno** (jedno na úkol) | Udělá práci od začátku do konce: přečte specifikaci a kód, implementuje, napíše testy, spustí analýzu, otevře PR, dotáhne CI do zelena, sám ho zkontroluje podle checklistu, **mergne ho** a ve vlákně napíše výsledek. U nejasností zvolí rozumnou výchozí variantu a napíše, kterou. | Nemerguje s červeným CI ani PR, ke kterému Papi napsal připomínku. Nemění produkční nastavení, nemaže data, neposílá nic mimo projekt bez výslovného pokynu. |
| **CI** (GitHub Actions) | Na každém PR spustí `flutter analyze` a `flutter test`. Nahrazuje „auditní štítek“: místo prohlášení, že kód je v pořádku, to ověří stroj. | |

## Zdroj pravdy

Platí jen to, co je v repozitáři:

| Co | Kde |
| --- | --- |
| Co stavíme a proč | [`docs/SPECIFIKACE.md`](docs/SPECIFIKACE.md) |
| Rozhodnutí a jejich důvody | [`DECLOG.md`](DECLOG.md) |
| Nápady mimo aktuální fázi | [`NAPADNIK.md`](NAPADNIK.md) |
| Jak projekt spustit | [`README.md`](README.md), [`ENVIRONMENT.md`](ENVIRONMENT.md) |
| Co kontrolovat v review | [`CODE_REVIEW_CHECKLIST.md`](CODE_REVIEW_CHECKLIST.md) |

Chaty, NotebookLM a poznámky jsou pomůcky. Když se rozcházejí s repem, platí repo; když je repo špatně, opraví se přes PR.

## Průběh úkolu

1. **Zadání** – Papi napíše do chatu projektu, co chce (stačí jedna věta). Pokud zadání míří mimo aktuální fázi, Claude to řekne a nabídne zápis do NAPADNIK.md.
2. **Vlákno** – koordinátor založí vlákno; v něm je vidět průběh (checklist) a výsledek.
3. **Větev** – každé vlákno pracuje na vlastní větvi (viz níže), nikdy přímo na hlavní větvi.
4. **Draft PR** – popis podle šablony (`.github/pull_request_template.md`): co uvidí uživatel *před* a *po*, jak to funguje, jak to bylo otestováno, odkaz na FR/ID ve specifikaci.
5. **CI zelené** – PR se nepředá k review s červeným CI.
6. **Review** – vlákno samo projde PR podle [CODE_REVIEW_CHECKLIST.md](CODE_REVIEW_CHECKLIST.md). Papi se může podívat kdykoli; jeho komentáře v PR nebo ve vlákně mají přednost a vlákno je zapracuje před mergem.
7. **Merge** – vlákno označí PR jako připravený a merguje (preferovaně *Squash and merge*). Špatný merge se vrací revertem. (Rozhodl Papi 8. 10. 2026: „v GitHubu pracuj vždy sám“, „Merguj sám“.)
8. **DECLOG** – pokud PR mění rozhodnutí, rozsah nebo architekturu, obsahuje i záznam v DECLOGu.

**Když Papi spí nebo nemá čas:** vlákna pokračují samostatně s rozumnými výchozími volbami. Krok, který opravdu potřebuje Papiho (platby, účty v obchodech, nastavení repozitáře), se odloží a zbytek práce pokračuje.

## Větve a commity

- **Hlavní větev:** `main` (viz „Jednorázové úkoly“ níže). Chráněná: merge jen přes PR se zeleným CI.
- **Pracovní větve:** `feat/<krátký-popis>`, `fix/<…>`, `docs/<…>`; větve vláken Clauda začínají `claude/`.
- **Commity:** [Conventional Commits](https://www.conventionalcommits.org/) v češtině nebo angličtině: `feat: …`, `fix: …`, `docs: …`, `test: …`, `refactor: …`, `chore: …`.
- **Velikost PR:** jeden PR = jedna věc, ideálně do ~400 změněných řádků bez generovaných souborů. Velké věci rozdělit.
- **Navazující PR:** když PR stojí na jiném, ještě nezmergovaném PR, cílí na jeho větev (stacked PR) a v popisu to uvádí.

## Jednorázové úkoly pro Papiho (nastavení GitHubu, volitelné)

Tyhle kroky vyžadují nastavení repozitáře, na které Claude nemá přístup. Nic na nich nestojí:

1. **Přejmenovat výchozí větev** `feat/mvp01-offline-diary-core` na `main` (Settings → General → Default branch, nebo Branches → přejmenovat). Název feature větve jako výchozí větev mate a CI v `.github/workflows/ci.yml` na ni odkazuje; po přejmenování upravit i tam.
2. **Ochrana hlavní větve** (Settings → Branches → Add rule): vyžadovat PR, vyžadovat zelený check `CI / test`.
3. Volitelně zapnout **automatické mazání větví po merge**.

## Komunikace

- Česky.
- Výsledky se píšou tam, kde práce proběhla (do vlákna), dlouhé texty jako soubor v repu nebo v PR.
- Otázka na Papiho má mít jednoslovnou odpověď a doporučenou variantu.
