# Zásady ochrany soukromí – Zahradník Bóďa

**Návrh k doplnění a zveřejnění.** Před vydáním doplnit údaje označené `[…]`, nechat zkontrolovat právníkem nebo aspoň porovnat s aktuálním zněním GDPR a zveřejnit na adrese z `PRIVACY_POLICY_URL` (výchozí `https://zahradnikboda.cz/soukromi`). Stejná adresa se vyplňuje v Google Play a App Store. Verze zásad v aplikaci je `privacyPolicyVersion` v `lib/features/account/domain/consents.dart` (teď `2026-10`); při podstatné změně zásad ji zvýšit, aplikace si pak vyžádá souhlasy znovu.

*Platí od: [datum vydání]. Verze 2026-10.*

## 1. Kdo data zpracovává

Správcem osobních údajů je **[jméno a příjmení / název firmy]**, IČO **[…]**, se sídlem **[adresa]**, e-mail **[kontaktní e-mail, např. ahoj@zahradnikboda.cz]** (dále „my“).

## 2. Co aplikace dělá bez účtu

Deník, zóny, úkoly, sklad, plán zahrady a návrhy staveb fungují **bez účtu a bez připojení k internetu**. Všechna data jsou jen ve vašem telefonu a my k nim nemáme přístup. Záloha (ZIP) a export deníku (CSV) vznikají v telefonu a posíláte je sami, kam chcete.

Bez účtu aplikace na naše servery nic neodesílá.

## 3. Co se zpracovává s účtem

Účet je dobrovolný. Slouží k záloze a synchronizaci mezi zařízeními, k Bóďovi s umělou inteligencí, k počasí a ke sdílení zahrady v rodině.

| Údaj | Proč | Právní základ | Jak dlouho |
| --- | --- | --- | --- |
| E-mailová adresa | přihlášení (jednorázový kód), obnova přístupu, oznámení o účtu | plnění smlouvy (čl. 6 odst. 1 písm. b) GDPR) | po dobu trvání účtu |
| Data zahrady: zóny, záznamy deníku, úkoly, sklad, nákupní seznam, problémy, stavby, plán | synchronizace a záloha; sdílení s členy rodiny, které sami pozvete | plnění smlouvy | po dobu trvání účtu |
| Fotky k záznamům | záloha a synchronizace (Free do 200 fotek) | plnění smlouvy | po dobu trvání účtu |
| Přibližná poloha zahrady (zaokrouhlená na cca 1 km) a nadmořská výška | předpověď počasí, doporučení zálivky a varování před mrazem | souhlas (zadáte ji sami nebo povolíte polohu) | dokud ji nesmažete |
| Dotazy pro Bóďu a k nim vybraná data zahrady (zóny, poslední záznamy, úkoly, sklad; nikdy jméno ani e-mail) | odpověď jazykového modelu | souhlas (zvlášť, odvolatelný v Nastavení) | historie konverzací po dobu trvání účtu; u poskytovatele modelu viz bod 5 |
| Fotka problému na rostlině (bez údajů z fotoaparátu a bez polohy) | diagnostika chorob a škůdců | souhlas (zvlášť, odvolatelný) | fotka se k diagnostice jen přepošle a neukládá se u nás |
| Souhlasy (co, kdy, verze zásad) | prokázání souhlasu | právní povinnost | po dobu trvání účtu |
| Informace o předplatném (identifikátor účtu, stav nároku na Premium) | aktivace Premium | plnění smlouvy | po dobu trvání účtu |
| Anonymní statistiky používání (počty záznamů a úkolů, které funkce se používají; žádné texty, fotky ani poloha) | zlepšování aplikace | souhlas (zvlášť, odvolatelný) | 12 měsíců |
| Hlášení o pádech aplikace (typ chyby, verze aplikace a systému; bez textů z deníku) | oprava chyb | oprávněný zájem na stabilní aplikaci | 90 dní |

Platbu zpracovává Google Play nebo App Store; čísla karet k nám nikdy nejdou.

## 4. Kde data leží

Data účtu, zahrady a fotky jsou uložené u společnosti **Supabase** v datovém centru v **EU (Frankfurt)**. Hlášení o pádech (**Sentry**) a statistiky (**PostHog**) jsou rovněž na serverech v EU.

## 5. Komu data předáváme (zpracovatelé)

| Zpracovatel | K čemu | Kde |
| --- | --- | --- |
| Supabase, Inc. | databáze, přihlášení, úložiště fotek, serverové funkce | EU (Frankfurt) |
| **[Poskytovatel jazykového modelu – podle nastavení serveru, např. Anthropic, PBC]** | odpovědi Bódi a diagnostika z fotek; data se nepoužívají k trénování modelu | **[USA – předání na základě standardních smluvních doložek / rozhodnutí o odpovídající ochraně (EU-US DPF); doplnit podle smlouvy s poskytovatelem]** |
| **[Poskytovatel počasí, např. Open-Meteo]** | předpověď pro přibližnou polohu zahrady (jen souřadnice, bez identifikace uživatele) | **[doplnit]** |
| RevenueCat, Inc. | správa předplatného | USA (standardní smluvní doložky) |
| Functional Software, Inc. (Sentry) | hlášení o pádech | EU |
| PostHog, Inc. | anonymní statistiky | EU |
| Google Play / Apple App Store | distribuce a platby | podle podmínek obchodu |
| **[Poskytovatel e-mailů pro přihlašovací kódy, např. Resend]** | odeslání jednorázového kódu | **[doplnit]** |

## 6. Vaše práva

Máte právo na přístup k údajům, jejich opravu, výmaz, omezení zpracování, přenositelnost a právo vznést námitku. Souhlasy jde kdykoli odvolat v aplikaci (Nastavení → Souhlasy a soukromí); odvolání nemá vliv na zpracování před ním.

- **Export dat:** Nastavení → Exportovat zálohu (ZIP se vším) nebo Exportovat deník do tabulky (CSV).
- **Smazání účtu:** Nastavení → Účet a synchronizace → Smazat účet. Účet, data v databázi i fotky v úložišti smažeme do 30 dnů; data v telefonu zůstanou vám. Zahradu sdílenou s dalšími členy předáme jinému vlastníkovi nebo smažeme. Smazání jde požádat i e-mailem na **[kontaktní e-mail]**.
- **Stížnost:** u Úřadu pro ochranu osobních údajů, Pplk. Sochora 27, 170 00 Praha 7, www.uoou.cz.

## 7. Děti

Aplikace není určena dětem mladším 15 let a vědomě od nich údaje nesbíráme.

## 8. Zabezpečení

Přístup k datům hlídá databáze po řádcích (každý vidí jen svoji zahradu a zahrady, do kterých byl pozván). Klíče ke službám třetích stran jsou jen na serveru, v aplikaci je jen veřejný klíč. Spojení je šifrované (TLS).

## 9. Změny zásad

O podstatné změně dáme vědět v aplikaci a vyžádáme si souhlasy znovu. Starší verze zásad na vyžádání.
