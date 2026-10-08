# Formát exportu deníku (verze 2)

Záloha z aplikace Zahradník Bóďa (FR-E1, FR-E2, specifikace kap. 8.4). Formát je veřejný, aby data šla kdykoli přečíst i bez aplikace.

## Soubor

`boda-export-YYYY-MM-DD.zip` (datum exportu podle času zařízení):

```
boda-export-2026-10-07.zip
├── data.json
└── photos/
    ├── 3f1c…e9.jpg
    └── …
```

* `data.json` je UTF-8 JSON, klíče v camelCase.
* `photos/<photoId>.<přípona>` jsou fotky záznamů v původní podobě (JPEG, delší strana nejvýš 1 920 px). V ZIP jsou uložené bez komprese.

## `data.json`

```json
{
  "formatVersion": 2,
  "app": "zahradnik_boda",
  "appVersion": "1.0.0",
  "exportedAt": "2026-10-07T08:00:00.000Z",
  "zones": [
    {
      "id": "…",
      "name": "Zelenina",
      "type": "vegetable",
      "archived": false,
      "areaM2": 20,
      "soilTexture": "loamy",
      "ph": 6.6,
      "phMeasuredAt": "2026-04-01",
      "sunExposure": "fullSun",
      "irrigation": "drip",
      "covered": false
    }
  ],
  "activities": [
    {
      "id": "…",
      "type": "harvest",
      "title": "Sklizeň jablek",
      "occurredAt": "2026-09-20T14:45:00.000Z",
      "occurredTz": "+02:00",
      "zoneId": "…",
      "notes": "Jonagold, 2 bedny",
      "photoIds": ["…"],
      "harvestQty": 24.5,
      "harvestUnit": "kg",
      "costCzk": null,
      "materials": [],
      "createdAt": "2026-09-20T15:01:12.000Z",
      "updatedAt": "2026-09-20T15:01:12.000Z"
    }
  ],
  "tasks": [
    {
      "id": "…",
      "title": "Zazimovat hadice",
      "zoneId": "…",
      "due": "2026-10-25",
      "remindAt": "10:00",
      "rrule": "FREQ=YEARLY",
      "snoozedUntil": null,
      "status": "open",
      "notes": null,
      "completedAt": null,
      "completedActivityId": null,
      "durationEstMin": 45,
      "tools": ["Klíč na hadice"],
      "source": "user",
      "materials": [{ "itemId": "…", "qty": 1.2, "unit": "kg" }],
      "createdAt": "…",
      "updatedAt": "…"
    }
  ],
  "inventory": [
    {
      "id": "…",
      "category": "fertilizer",
      "name": "Cererit",
      "unit": "kg",
      "stockQty": 2.5,
      "lowStockThreshold": 1,
      "details": { "n": 12, "p": 11, "k": 18, "form": "granular", "dosePerM2": 60, "doseUnit": "g" }
    }
  ],
  "shopping": [
    { "id": "…", "name": "Cererit", "qty": 5, "unit": "kg", "itemId": "…", "done": false, "source": "lowStock" }
  ],
  "photos": [
    { "id": "…", "file": "photos/….jpg" }
  ]
}
```

### Pole

| Pole | Typ | Popis |
| --- | --- | --- |
| `formatVersion` | int | Verze tohoto formátu. Aplikace odmítne zálohu z novější verze, starší verze umí načíst. |
| `app`, `appVersion` | text | Kdo zálohu vytvořil (jen informativně). |
| `exportedAt` | ISO 8601 UTC | Čas exportu. |
| `zones[].type` | text | Číselník `zone.type` (spec 8.3); neznámá hodnota se načte jako `other`. |
| `zones[].archived` | bool | Archivovaná zóna (FR-D3). |
| `activities[].type` | text | Číselník `activity.type` (spec 8.3); neznámá hodnota se načte jako `other`. |
| `activities[].occurredAt` | ISO 8601 UTC | Kdy se činnost stala. |
| `activities[].occurredTz` | `±HH:MM` | Posun časové zóny zařízení v tu chvíli (spec 7.3). |
| `activities[].photoIds` | text[] | Fotky v pořadí; soubor dohledá pole `photos`. |
| `tasks[].due`, `snoozedUntil` | `YYYY-MM-DD` | Den (bez času a časové zóny). |
| `tasks[].remindAt` | `HH:MM` | Čas připomínky v den termínu, místní čas; `null` = jen ranní přehled. |
| `tasks[].rrule` | text | Opakování jako podmnožina iCalendar RRULE: `FREQ=WEEKLY\|MONTHLY\|YEARLY`, volitelně `BYMONTH`, `BYMONTHDAY`. |
| `tasks[].status` | text | `open`, `done`, `skipped`. |
| `photos[].file` | text | Cesta k souboru uvnitř ZIP, vždy ve složce `photos/`. |
| `zones[].areaM2`, `ph` | číslo | Výměra v m², pH půdy (od verze 2). |
| `zones[].soilTexture`, `sunExposure`, `irrigation` | text | Číselníky z kap. 8.3 (od verze 2). |
| `zones[].phMeasuredAt` | `YYYY-MM-DD` | Den měření pH. |
| `zones[].covered` | bool | Skleník, fóliovník. |
| `activities[].harvestQty`, `harvestUnit` | číslo, text | Sklizeň (`kg`, `g`, `ks`), od verze 2. |
| `activities[].costCzk` | číslo | Náklady v Kč. |
| `activities[].materials`, `tasks[].materials` | pole | Materiál ze skladu: `itemId`, `qty`, `unit` (`g`, `kg`, `ml`, `l`, `ks`, `pack`). |
| `tasks[].durationEstMin`, `tools` | číslo, text[] | Odhad doby v minutách a nářadí. |
| `tasks[].source` | text | Kdo úkol založil: `user`, `boda` (z odpovědi Bódi), `weather`. Chybí-li, bere se `user`. |
| `inventory[]` | pole | Sklad: `category` (`seed`, `fertilizer`, `plantProtection`, `tool`, `other`), `unit`, `stockQty`, `lowStockThreshold`, `details` podle kategorie (osivo: `species`, `variety`, `lot`, `bestBefore`; hnojivo: `n`, `p`, `k`, `form`, `dosePerM2`, `doseUnit`; přípravek: `activeSubstance`, `authorizationNo`, `phiDays`, `nonProfessional`, `dosePerM2`, `doseUnit`; nářadí: `condition`, `serviceIntervalDays`, `lastServiceAt`). |
| `shopping[]` | pole | Nákupní seznam: `name`, `qty`, `unit`, `itemId` (položka skladu), `done`, `source` (`user`, `boda`, `lowStock`). |

Nepovinná pole mohou chybět nebo být `null`.

## Import

* Varianta **„nahradit vše“** s potvrzením: zóny, záznamy, úkoly a fotky v aplikaci se smažou a nahradí obsahem zálohy (FR-E2).
* Před nahrazením se záloha zkontroluje: musí jít o ZIP s `data.json`, záznam musí odkazovat na zónu ze zálohy a cesta k fotce nesmí vést mimo `photos/`. Při chybě zůstanou data beze změny.
* Fotka, která v ZIP chybí, se vynechá; záznam zůstane.
* Úkol odkazující na neexistující zónu se načte bez zóny; materiál nebo nákup odkazující na neexistující položku skladu se vynechá (nákup zůstane bez odkazu).
* Záloha verze 1 (MVP 0.2) se načte celá, nová pole zůstanou prázdná.

## Změna formátu

Nová verze formátu = vyšší `formatVersion`, převod starší verze v `decodeBackup` (`lib/features/backup/domain/backup_format.dart`), test se zálohou starší verze a úprava tohoto dokumentu.
