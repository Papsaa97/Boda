# Formát exportu deníku (verze 1)

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
  "formatVersion": 1,
  "app": "zahradnik_boda",
  "appVersion": "0.2.0",
  "exportedAt": "2026-10-07T08:00:00.000Z",
  "zones": [
    { "id": "…", "name": "Zelenina", "type": "vegetable", "archived": false }
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
      "createdAt": "…",
      "updatedAt": "…"
    }
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

Nepovinná pole mohou chybět nebo být `null`.

## Import

* Varianta **„nahradit vše“** s potvrzením: zóny, záznamy, úkoly a fotky v aplikaci se smažou a nahradí obsahem zálohy (FR-E2).
* Před nahrazením se záloha zkontroluje: musí jít o ZIP s `data.json`, záznam musí odkazovat na zónu ze zálohy a cesta k fotce nesmí vést mimo `photos/`. Při chybě zůstanou data beze změny.
* Fotka, která v ZIP chybí, se vynechá; záznam zůstane.
* Úkol odkazující na neexistující zónu se načte bez zóny.

## Změna formátu

Nová verze formátu = vyšší `formatVersion`, převod starší verze v `decodeBackup` (`lib/features/backup/domain/backup_format.dart`), test se zálohou starší verze a úprava tohoto dokumentu.
