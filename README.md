# Troy Scripts — ts_bridge

**Versie 1.1.0** · FiveM · centrale ondersteuning voor Troy Scripts

Alle instellingen staan in `config/config.lua`; geheime webhook-URLs staan in `config/webhook_config.lua` (uitsluitend server-side). Kies `Locale = 'nl'` of `Locale = 'en'`. Het configschema is **0.0.9**.

Lees [INSTALLATIE.md](INSTALLATIE.md) voor installatie en migratie en [CHANGELOG.md](CHANGELOG.md) voor de versiegeschiedenis.

## Gedeelde camera en combatcontext

### Nieuwe client-API

```lua
exports.ts_bridge:RequestFirstPerson('aim', {
    scope = 'ped', -- 'ped' of 'vehicle'
    restore = true,
    restoreDelayMs = 50, -- geheel getal 0 t/m 60000
    defaultCamera = 1 -- 0, 1, 2 of 4
})
-- Aanvragen bij statuswisseling; de bridge blijft zelf iedere frame forceren.
exports.ts_bridge:ReleaseFirstPerson('aim')

-- Gerichte integratie met antipunch. Schiet-/slagblokkeringen blijven actief.
exports.ts_bridge:SetCombatContext('animation', {
    suspendCamera = false,
    suspendMeleeCancel = true
})
exports.ts_bridge:SetCombatContext('animation', nil)
local context = exports.ts_bridge:GetCombatContext()
```

RequestFirstPerson, ReleaseFirstPerson en SetCombatContext geven true bij
acceptatie en false bij ongeldige parameters/ontbrekende aanroeper. Een ontbrekende,
dode of fataal gewonde ped krijgt geen camera-aanvraag. Keys zijn strings van 1
t/m 100 tekens. Dezelfde key vervangt de eigen aanvraag binnen dezelfde scope.
Een ander script kan jouw aanvraag of context niet verwijderen.

ReleaseFirstPerson verwijdert beide scopes van de eigen key. Een tweede argument
true vraagt onmiddellijk herstel; andere deelnemers behouden hun aanvraag.
Herstel gebeurt alleen wanneer de bridge zelf de camera wijzigde en deze nog in
first person staat. Vooraf zelf gekozen first person blijft behouden. De vertraging
van de laatste vrijgave geldt; opnieuw aanvragen annuleert het geplande herstel.

Als minstens één vrijgegeven deelnemer herstel vroeg, wordt de oorspronkelijke
stand na de laatste aanvraag hersteld. Anders blijft first person staan. De bridge
forceert voertuigaanvragen alleen in voertuigen en ped-aanvragen alleen te voet.

Resource-stop verwijdert alleen aanvragen/contexten van die resource. Overlijden,
pedwissel en bridge-stop ruimen alles op met herstel van actieve eigen
camerawijzigingen. Afnemers gebruiken daarnaast IsDead voor de geconfigureerde
ambulance-statekeys. Na bridgeherstart moeten de afnemers opnieuw starten.

GetCombatContext geeft de samengevoegde booleans suspendCamera en
suspendMeleeCancel. Bij wijziging volgt het lokale event
ts_bridge:combatContextChanged. Antipunch respecteert die pauzes als
Config.RespectCombatContexts = true. Hostage pauzeert alleen de melee-noodrem.
Er zijn geen net-events voor deze API toegevoegd; het is clientbesturing, geen
serverbeveiliging. Directe camerawijzigingen van andere scripts kunnen nog botsen.

De integratie is lokaal met gesimuleerde FiveM-functies getest; geen live FiveM-test.


Centrale ondersteuningsresource voor Troy Scripts. Lees INSTALLATIE.md voor installatie,
configuratie, teststappen en terugzetten.

Deze versie ondersteunt ESX-jobcontrole, ox_lib-meldingen, ox_target, politiemeldingen met
locatie en waypoint, Discord-webhooks en screenshot-basic. De gijzelingsregels,
handen-omhoog-functie en animaties blijven in ts_hostage.

Voor de keycard-aansluiting zijn inventory-, ESX-speler/rechten-, cash/bank- en
societyfuncties toegevoegd. Zie **KEYCARD-BANKING-BILLING.md** voor de volledige API.
Persoonlijke bankmutaties gebruiken Apex Banking. Society-mutaties gebruiken alleen
esx_addonaccount. Facturen aanmaken en opvragen gebruikt Apex Billing. Automatische
factuurbetaling is nog niet aangesloten; zie de concrete Apex-beperking in die handleiding. QBCore en Qbox zijn niet geïmplementeerd.
De bijbehorende scriptupdates vereisen deze bridgebuild. Start ts_bridge vóór beide scripts.
Er is geen Fiveguard-adapter toegevoegd; geen anticheatinstellingen worden gewijzigd.

## Bestanden

| Bestand | Functie |
| --- | --- |
| config/config.lua | Alle algemene instellingen zonder geheimen |
| config/webhook_config.lua | Geheime webhookroutes, uitsluitend server-side |
| locales/ | Nederlandse en Engelse teksten en de locale-loader |
| tests/ en tools/ | Ontwikkelcontroles; niet nodig op de FiveM-server |
| client/main.lua | Meldingen, doodstatus en targetopties |
| client/alerts.lua | Straatnaam, meldingslocatie en waypoint |
| server/main.lua | Jobcontrole, jobmeldingen en diagnosecommand |
| server/webhooks.lua | Wachtrij, upload, JPEG-validatie en time-outs |

## Gebruik door andere resources

Zet `dependency 'ts_bridge'` in hun fxmanifest.lua en start ts_bridge eerst.
De onderstaande exports zijn de API van deze versie; hun namen zijn hoofdlettergevoelig.

### Client

```lua
exports['ts_bridge']:Notify({
    title = 'Troy Scripts', description = 'Actie uitgevoerd.', type = 'success'
})
local dead = exports['ts_bridge']:IsDead(PlayerPedId())
```

| Export | Resultaat / afspraken |
| --- | --- |
| Notify(string of table) | boolean; table gebruikt ox_lib-notificatievelden |
| IsDead(ped) | boolean; lokale dood/laststand-state geldt alleen voor eigen ped |
| GetTargetResource() | ingestelde ox_target-resourcenaam |
| AddGlobalPlayer(options) | boolean; ox_target-opties inclusief callbacks |
| AddGlobalVehicle(options) | boolean; ox_target-opties inclusief callbacks |
| RemoveGlobalPlayer(name) | boolean; uitsluitend eigen geregistreerde optie |
| RemoveGlobalVehicle(name) | boolean; uitsluitend eigen geregistreerde optie |

Targetnamen moeten beginnen met de aanroepende resource plus `_`, bijvoorbeeld
`ts_hostage_player`. De bridge verwijdert opties bij het stoppen van de aanroeper
of zichzelf. Na een targetresource-herstart moet het aangesloten script zijn opties
opnieuw aanmelden; ts_hostage doet dit al.

### Server

```lua
local job, reason = exports['ts_bridge']:GetJob(playerId)
exports['ts_bridge']:Notify(playerId, { description = 'Actie uitgevoerd.' })
local sent = exports['ts_bridge']:AlertJobs(
    { police = true },
    { title = 'Politiemelding', description = 'Hulp gevraagd.', type = 'warning' },
    { x = 100.0, y = 200.0, z = 30.0 }, 60
)
```

GetJob geeft `{ name, grade, label }` of nil; een tweede waarde kan de ontbrekende
koppeling verklaren. Standalone geeft nil. AlertJobs geeft het aantal ontvangers;
controle gebeurt op serverjobs en heeft geen dienststatusfilter. Coördinaten moet
het aangesloten script zelf uit een geldige serveractie bepalen. Notify accepteert
één online speler-ID, geen broadcast-ID.

```lua
local accepted, reason = exports['ts_bridge']:SendWebhook('start', '', {
    username = 'Troy Scripts',
    embeds = { { title = 'Actie gestart', description = 'Voorbeeld' } }
}, { screenshot = true, playerId = playerId })
```

SendWebhook(route, fallbackUrl, payload, options) is uitsluitend server-side.
De route wordt opgezocht in TSBridgeServer.Webhooks[aanroependeResource][route].
Zonder centrale URL wordt de server-side fallbackUrl gebruikt. payload vereist minstens
één embed; mentions worden uitgeschakeld. true betekent geaccepteerd voor verwerking,
geen bevestiging van aflevering. false plus reden betekent niet aangenomen.

Alleen HTTPS Discord-webhooks op discord.com worden geaccepteerd. Screenshots worden
als JPEG-bijlage meegestuurd; zonder beschikbare foto volgt een tekstlog. De wachtrij
is centraal begrensd, met maximaal drie retries op HTTP 429. Time-outs van een POST
worden niet opnieuw verstuurd om dubbele logs te beperken. Eén screenshot wordt hoogstens
één keer afgehandeld, ook bij late of dubbele callbacks. Er zijn geen clientevents
waarmee spelers zelf jobs kunnen kiezen of een webhook/screenshot kunnen aanvragen.
De aanroepende serverresource blijft verantwoordelijk voor autorisatie van de actie.

## Validatie

De meegeleverde Lua-testscripts in beide resources controleren samen de bestaande gijzelingscontroles,
jobselectie, waypoint, webhooktransport, screenshots, betalingen, rechten, billingcontract en targetcleanup met gesimuleerde API's.
Voer tests uit vanuit de map van de betreffende resource met Lua 5.4, bijvoorbeeld
`lua tests/client_spec.lua`. De hostage-integratietests verwachten ts_bridge ernaast.
Live controle blijft nodig; zie INSTALLATIE.md.

## okok-keuzes

okokBanking is als ESX-bankaccountadapter toegevoegd. okokBilling heeft een voorbereide
providerkeuze, maar vereist nog jouw resourcebestanden voor de daadwerkelijke serverkoppeling.
Zie **OKOK.md**. Apex blijft standaard ingesteld; society-geld blijft bij esx_addonaccount.

## Status-API en locales

GetStatus() is aan beide kanten beschikbaar: `{api=1, version, side, features}`.
De server geeft tevens framework/resources/banking terug; de client de targetresource.
De aangesloten scripts controleren deze gegevens; ts_antipunch 1.8.2 en ts_hostage 1.1.9 vereisen minimaal 0.0.5.
Herstart afhankelijke scripts na een bridgeherstart; ze blijven na uitval niet automatisch actief.

TSBridgeConfig.Locale = 'nl' is standaard. Teksten staan in locales/nl.lua en locales/en.lua en Nederlandse
fallback is ingebouwd. Configuratievelden voor teksten blijven expliciet instelbaar.

## Meldingen, radialmenu en configversie

Dezelfde API 1 blijft beschikbaar. Bestaande string- en table-aanroepen van Notify
werken zonder extra wachttijd; de limiet is optioneel en geldt per aanroepende resource
én melding-ID. Houd voor alle afwijzingen van één functie dezelfde ID aan.

```lua
exports.ts_bridge:Notify({
    id = 'gijzeling', title = 'Gijzeling', description = 'Geen speler dichtbij.'
}, 5000) -- false bij onderdrukking; true bij verzenden

exports.ts_bridge:RegisterRadialMenu({
    id = 'acties', label = 'Mijn acties', icon = 'circle',
    items = { { label = 'Voorbeeld', icon = 'circle', onSelect = function() end } }
})
exports.ts_bridge:RemoveRadialMenu('acties')

local actueel = exports.ts_bridge:CheckConfigVersion(Config.Version, '1.1.8')
```

RegisterRadialMenu/RemoveRadialMenu zijn clientexports. De bridge maakt IDs uniek
per resource en verwijdert eigen menu-items en callbacks bij resource-stop.
Als de bridge blijft draaien, worden radialregistraties na ox_lib-start hersteld.
Bij een volledige bridgeherstart moeten afhankelijke resources opnieuw starten;
verloren callbacks kunnen niet automatisch worden gereconstrueerd. Registraties uit een
andere resource blijven bij een gewone resource-stop bestaan.

CheckConfigVersion is beschikbaar op beide kanten; alleen de server print de
configstatus. De export vergelijkt schemaversies exact, wijzigt de config niet en
retourneert een boolean. Scripts bepalen zelf hun defaults en benodigde versie.
De bridge zelf verwacht TSBridgeConfig.Version = '0.0.8'. Het schemaversienummer
blijft bij toekomstige scriptupdates gelijk zolang de configuratie niet wijzigt.

Voor ts_hostage: gebruik de bijbehorende bijgewerkte 1.1.8, die minimaal bridge
0.0.3 en de nieuwe features controleert. De versie van hostage blijft 1.1.8 en
zijn configversie blijft 1.1.8. Gameplayregels blijven in hostage.

## Configuratie en herstel


### Configinhoud en diagnose

De bridge controleert de algemene instellingen en server-side webhookroutes:
verplichte velden, providernamen, resourcenamen, tabellen, booleans, numerieke limieten
en centrale webhook-URL's. Onbruikbare configuratie blokkeert de operationele exports;
GetStatus retourneert dan ready=false en een lege featurelijst. Er worden geen
bankinstellingen automatisch vervangen. Herstel het gemelde veld en herstart.
Configversie en configinhoud zijn afzonderlijke controles.

`ts_bridge_check` is uitsluitend voor de serverconsole. Het toont configfouten,
providerstatus, billingbeschikbaarheid, aantallen wachtende logs/screenshots en of
GitHub is ingesteld. Webhook-URL's en tokens worden niet getoond. Via de serverexports
`GetDiagnostics()` en `GetWebhookStatus()` zijn deze gegevens ook opvraagbaar.
Billingbeschikbaarheid betekent dat de resource en vereiste adapter beschikbaar zijn;
de diagnose maakt geen testfactuur en voert geen geldmutaties uit.

### Servermeldingen met optionele limiet

```lua
exports.ts_bridge:Notify(playerId, {
    id = 'mijn_actie', title = 'Melding', description = 'Voorbeeld'
}, 5000)
```

De limiet geldt per resource, speler en melding-ID. Alle afwijzingen van dezelfde
actie kunnen dezelfde ID delen. Zonder cooldown blijven bestaande aanroepen werken.
Player-disconnect en resource-stop ruimen de bijbehorende limieten op.

### Webhooks en screenshots

Elke webhookbestemming heeft een eigen wachtrij. Een time-out of HTTP 429 bij één
bestemming houdt de andere bestemmingen niet op; dezelfde bestemming behoudt
verzendvolgorde zodra de logs in de wachtrij staan. Screenshotverwerking is asynchroon.
MaxQueue blijft een gezamenlijke bovengrens inclusief gereserveerde screenshotplekken.
Een volle totale wachtrij kan dus nog logs weigeren. Dit is geen onbeperkte buffering.
Bij screenshotfalen blijft de oorspronkelijke embedbeschrijving behouden; er komt een
extra Screenshot-veld bij. Is de embed al vol, dan wordt beschikbare berichttekst
gebruikt; de bestaande inhoud wordt niet vervangen. De console vermeldt de fout ook.
Onzekere POST-time-outs worden niet automatisch opnieuw verstuurd.

### Herstel van registraties

Bij een herstart van ox_target registreert een draaiende bridge de bewaarde globale
player-/vehicle-opties en nog bestaande lokale NPC-opties opnieuw. Na ox_lib-start
worden bewaarde radialmenu's opnieuw geplaatst, als de bridge zelf nog draait.
Gestopte eigenaars worden niet hersteld. Resource-stop verwijdert hun registraties.
Als ox_lib-uitval ook de bridge of afhankelijke scripts stopt, start die resources
opnieuw. Na een volledige bridgeherstart is opnieuw starten van scripts zoals
hostage nog nodig wegens hun eigen stopcontrole. Lopende gijzelingen worden niet hervat.

### GitHub-versiecontrole

Standaard controleert de server één keer, drie seconden na de start:
https://github.com/troyscripts/ts_brigde

Plaats de meegeleverde version.json in de **hoofdmap van de standaardbranch**,
naast fxmanifest.lua. Het bestand bevat version en download. De controle vergelijkt
stabiele versies numeriek, toont een repositorylink bij een nieuwere versie en
installeert niets automatisch. HTTP-fouten, ongeldige JSON en een time-out stoppen
het script niet. De repository en version.json moeten publiek leesbaar zijn.

In TSBridgeConfig.Server van config/config.lua:
```lua
UpdateCheck = { Enabled = true, Repository = 'troyscripts/ts_brigde' },
```
Zonder dit blok worden dezelfde standaardwaarden gebruikt.
Enabled=false schakelt de controle uit. De GitHub-naam ts_brigde is bewust overgenomen;
de FiveM-resourcemap blijft ts_bridge. Bij een volgende release werk je zowel de
manifestversie als version.json bij.

Technische API-bron: [GitHub repository contents](https://docs.github.com/en/rest/repos/contents#get-repository-content).
Versievergelijking en foutafhandeling worden met gesimuleerde HTTP-antwoorden getest.

## Gedeelde GitHub-updatecontrole

De serverexport `CheckForUpdates(settings)` controleert de versie van de aanroepende
resource. De bridge gebruikt dezelfde code voor zijn eigen versiecheck. API 1 blijft
behouden en bestaande exports blijven werken. Het huidige configschema is **0.0.8**.

```lua
exports.ts_bridge:CheckForUpdates({
    Enabled = true,
    Repository = 'troyscripts/ts_keycard',
    File = 'version.txt', -- version.txt of version.json; standaard version.json
    Branch = 'main' -- optioneel; zonder Branch gebruikt GitHub de standaardbranch
})
```

De bridge leest de lokale versie uit het manifest van de aanroeper. Per resource
wordt eenmaal per start gecontroleerd; dubbele aanroepen starten geen tweede aanvraag.
De export retourneert true bij plannen, false bij uitschakelen, ongeldige instellingen
of een al geplande controle. GitHub wordt na drie seconden benaderd met een time-out
van vijftien seconden. Resource-stop maakt oude callbacks ongeldig. Geen automatische
installatie; alleen stabiele X.Y.Z-versies en een veilige repository-downloadlink.
JSON bevat version en optioneel download; een tekstbestand bevat alleen het versienummer.

Keycard 1.1.5 gebruikt deze nieuwe export en vereist daarom minimaal bridge 0.0.4.
Hostage 1.1.8 blijft compatibel en houdt voorlopig zijn bestaande eigen updatechecker.
Kaartspecifieke rechten, uitgifte en intrekking blijven in keycard.

## Webhook voor kentekenbewijzen

Zie WEBHOOKS-KENTEKENBEWIJS.md: aparte webhook voor nieuwe/vervangende bewijzen, met kaart-PNG en FiveM-modelafbeelding. URL uitsluitend server-side instellen.

## Tests en distributie

Testresultaten hoeven niet te worden geüpload. Bewaar tests en tools wel in GitHub om toekomstige wijzigingen te controleren; FiveM laadt deze niet. Gegenereerde rapporten worden genegeerd via `.gitignore`.

```sh
python tools/check_package.py
for test in tests/*_spec.lua; do lua "$test" || exit 1; done
node tests/screenshot_upload_spec.js
```

Lua 5.4 is vereist (alternatief: `luatex --luaonly` per test). Tests gebruiken gesimuleerde providers; controleer ook op een FiveM-testserver.


## Directe radiaalacties (1.0.9)

```lua
exports.ts_bridge:RegisterRadialAction({
    id = "shuffle", label = "Schuif naar bestuurder", icon = "chair",
    onSelect = function() --[[ eigen actie ]] end
})
exports.ts_bridge:RemoveRadialAction("shuffle")
```

Registreer alleen wanneer de actie beschikbaar is en verwijder bij statuswisseling. Controleer voorwaarden opnieuw in de callback. IDs worden per aanroepende resource gescheiden; registreren met dezelfde ID vervangt de eigen actie. De API kopieert invoer, geeft true/false terug, ruimt op bij stoppen en herstelt bij ox_lib-herstart. `keepOpen` is optioneel (standaard false). Bestaande RegisterRadialMenu/RemoveRadialMenu blijven ongewijzigd.

ts_nohelmet 1.0.2 gebruikt deze API voor zijn contextafhankelijke schuifoptie. Vanaf 1.1.0 wordt deze API ook bestuurd door de onderstaande radiaalinstellingen.

## Radiaalmenu instellen (1.1.0)

In `config/config.lua`, binnen `TSBridgeConfig`:

```lua
Radial = {
    Enabled = true,
    Provider = 'ox_lib'
},
```

`Provider = 'ox_lib'` is de ondersteunde koppeling. `Enabled = false` verbergt alle via de bridge geregistreerde submenu’s en directe acties; commands zoals `/schuif` blijven werken. Opties die andere scripts rechtstreeks in ox_lib registreren worden niet uitgeschakeld. ox_lib blijft een verplichte bridge-dependency voor de overige functies.

Voeg bij een bestaande configuratie dit blok toe en zet `Version = '0.0.9'`. Behoud je andere instellingen en webhooks. Herstart daarna de server zodat afhankelijke resources hun menu’s opnieuw registreren. De toetsenbinding wordt door ox_lib en de persoonlijke FiveM-instellingen bepaald.

Registratie bij een uitgeschakeld menu geeft `true`: de bridge bewaart de registratie maar toont niets. Er wordt dus geen ontbrekende-exportfout veroorzaakt bij bestaande aanroepers. Een oude config zonder `Radial` behoudt het eerdere ingeschakelde ox_lib-gedrag en geeft de gebruikelijke configversiewaarschuwing.
