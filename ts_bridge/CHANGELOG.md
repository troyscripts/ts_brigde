# Changelog — ts_bridge

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
