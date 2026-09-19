# Troy Scripts — ts_bridge

**Versie 0.0.3 — stabiel** · FiveM · ts_hostage 1.1.8 en ts_keycard 1.1.4

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
| config.lua | Gedeelde instellingen zonder geheimen |
| server_config.lua | ESX, screenshotlimieten en centrale webhookroutes |
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
De aangesloten scripts controleren deze gegevens; de bijgewerkte ts_hostage 1.1.8 vereist minimaal 0.0.3.
Herstart afhankelijke scripts na een bridgeherstart; ze blijven na uitval niet automatisch actief.

TSBridgeConfig.Locale = 'nl' is standaard. Teksten staan in locales/nl.lua en Nederlandse
fallback is ingebouwd. Configuratievelden voor teksten blijven expliciet instelbaar.

## Nieuw in stabiele versie 0.0.3

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
De bridge zelf verwacht TSBridgeConfig.Version = '0.0.3'. Het schemaversienummer
blijft bij toekomstige scriptupdates gelijk zolang de configuratie niet wijzigt.

Voor ts_hostage: gebruik de bijbehorende bijgewerkte 1.1.8, die minimaal bridge
0.0.3 en de nieuwe features controleert. De versie van hostage blijft 1.1.8 en
zijn configversie blijft 1.1.8. Gameplayregels blijven in hostage.

## Aanvulling binnen 0.0.3

Deze aanvulling behoudt scriptversie en configversie 0.0.3. Wie de eerdere 0.0.3
gebruikt, vervangt deze bestanden handmatig. De GitHub-versiecontrole kan twee
verschillende builds met hetzelfde versienummer niet onderscheiden.

### Configinhoud en diagnose

De bridge controleert nu ook de inhoud van config.lua en server_config.lua:
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

Optioneel in TSBridgeServer (server_config.lua):
```lua
UpdateCheck = { Enabled = true, Repository = 'troyscripts/ts_brigde' },
```
Een oude server_config.lua zonder dit blok gebruikt dezelfde standaardwaarden.
Enabled=false schakelt de controle uit. De GitHub-naam ts_brigde is bewust overgenomen;
de FiveM-resourcemap blijft ts_bridge. Bij een volgende release werk je zowel de
manifestversie als version.json bij. Publiceren op GitHub is niet in deze download uitgevoerd.

Technische API-bron: [GitHub repository contents](https://docs.github.com/en/rest/repos/contents#get-repository-content).
De openbare repository kon vanuit deze omgeving niet live worden opgehaald;
versievergelijking en foutafhandeling zijn met gesimuleerde HTTP-antwoorden getest.
