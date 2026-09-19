# Changelog — ts_bridge

## Aanvulling binnen 0.0.3 — geen versieverhoging
- Configinhoud valideren; onbruikbare configuratie blokkeert operationele exports.
- Server-Notify ondersteunt cooldown per resource, speler en melding-ID.
- ts_bridge_check/GetDiagnostics: config-, provider-, billing- en wachtrijstatus zonder geheimen.
- Webhookwachtrijen per bestemming; totale bovengrens en screenshotreserveringen behouden.
- Screenshotfalen behoudt oorspronkelijke logtekst en voegt een foutveld toe.
- Bewaarde target-/NPC-/radialregistraties herstellen bij providerstart als bridge blijft draaien.
- Geen automatische hervatting van gestopte resources of lopende sessies na volledige bridgeherstart.
- GitHub-updatecontrole voor troyscripts/ts_brigde, version.json, veilige downloadlink en time-out.
- Apex Banking/Billing blijven de standaard. Geen nieuwe okok-integratie.
- Configschema blijft 0.0.3; bestaand server_config.lua werkt, UpdateCheck-blok is optioneel.
- Eerdere build 0.0.3 handmatig vervangen: versiecontrole onderscheidt gelijke versies niet.

## 0.0.3 — Stabiele release
- Beta-aanduiding verwijderd uit manifest, opstartmeldingen en actuele documentatie.
- Notify behoudt string/table-aanroepen en ondersteunt een optionele cooldown per resource en melding-ID.
- Invoer voor Notify wordt gekopieerd; de oorspronkelijke tabel wordt niet gewijzigd.
- RegisterRadialMenu/RemoveRadialMenu: eigen menu's per resource, inclusief opruimen van callbacks bij stop.
- CheckConfigVersion beschikbaar op client en server; bridgeconfigversie 0.0.3.
- GetStatus blijft API 1, met de nieuwe functies in features.
- ts_hostage 1.1.8 gebruikt nu de gedeelde meldingslimiet, configcontrole en radialadapter.
- Bestaande banking-, billing-, inventory- en target-API's behouden.
- Config.lua bijwerken: JA (Version toevoegen). Server_config.lua: geen nieuwe instellingen.
- Bestaande beperkingen voor QBCore/Qbox en automatische factuurbetaling blijven gelden.
- Lua 5.4 syntax en mock-/integratietests geslaagd; geen live FiveM/providertest.

## 0.0.2(BETA) — Aansluiting scripts, status-API en locales
- GetStatus-export op client en server met API 1, versie, functies en providergegevens.
- Ondersteunt verplichte controles in ts_hostage 1.1.7 en ts_keycard 1.1.4.
- Aanpasbare locales/nl.lua; Nederlands standaard en fallback.
- Bestaande Apex-, addonaccount-, inventory-, target- en webhookfuncties behouden.
- okokBilling blijft voorbereid; concrete adapter vereist de resourcebestanden.
- Installatiehandleidingen en tests bijgewerkt.


## 0.0.1(BETA)
- Eerste centrale bridge voor ts_hostage 1.1.6.
- Client/servermeldingen, lokale doodstatus en ESX-jobcontrole.
- Jobmeldingen met straatnaam, locatie en centraal waypointcommand.
- ox_target-exports met eigenaarschap en automatisch opruimen van opties.
- Server-side Discord-webhooks met centrale routes en bestaande URL als fallback.
- screenshot-basic-koppeling, JPEG-controle, timeout en tekstfallback.
- Begrensde gezamenlijke wachtrij en afhandeling van Discord HTTP 429.
- Consolecommand ts_bridge_check, API-documentatie en testinstructies.

### Aanvulling binnen dezelfde beta — geen versiewijziging
- Voorbereiding voor ts_keycard, zonder het kaartscript zelf aan te passen.
- ESX-persoonsgegevens, expliciete ACE/groep/jobrechten en rangen.
- ox_inventory-items, metadata en hooks met opruimen per aanroepende resource.
- NPC-targetopties, itemgebruik en ox_lib voortgang/dialogen.
- Cash- en bankmutaties met saldocontrole en herkenbare onzekere resultaten.
- esx_addonaccount-societyadapter met verse snapshots en rekeningaliases.
- Apex Banking-adapter voor persoonlijk banksaldo en mutaties, zonder fallback-afschrijving.
- Society-mutaties uitsluitend via esx_addonaccount; standaard society_police vóór oude spelling.
- Apex Billing-adapter voor aanmaken en opvragen, plus optioneel custom providercontract.
- Geen automatische factuurbetaling: de geconstateerde Apex-bijschrijvingscontrole vereist later werk in Apex.
- Tests voor mislukte mutaties, rechten, providerrestarts en invoicefouten.

### okok-aanvulling binnen 0.0.1(BETA)
- Instelbare okokBanking-provider voor het persoonlijke ESX-bankaccount.
- Geen gebruik van okok-societyexports; society blijft via esx_addonaccount.
- okokBilling-providerkeuze voorbereid; aanvragen worden geweigerd totdat de echte adapter is aangesloten.
- Instructies, beperkingen en providerregressietest toegevoegd. Apex-defaults behouden.
