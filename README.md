# Troy Scripts — ts_bridge

**Versie 0.0.2(BETA)** · FiveM · ts_hostage 1.1.7 en ts_keycard 1.1.4

Centrale ondersteuningsresource voor Troy Scripts. Lees INSTALLATIE.md voor installatie,
configuratie, teststappen en terugzetten.

Deze beta ondersteunt ESX-jobcontrole, ox_lib-meldingen, ox_target, politiemeldingen met
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
De onderstaande exports zijn de API van deze beta; hun namen zijn hoofdlettergevoelig.

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
De aangesloten scripts controleren deze gegevens en minimaal bridgeversie 0.0.2.
Herstart afhankelijke scripts na een bridgeherstart; ze blijven na uitval niet automatisch actief.

TSBridgeConfig.Locale = 'nl' is standaard. Teksten staan in locales/nl.lua en Nederlandse
fallback is ingebouwd. Configuratievelden voor teksten blijven expliciet instelbaar.
