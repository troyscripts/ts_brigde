# Werkpaskoppeling — ts_bridge 1.1.2

De bridge verbindt ts_keycard 1.3.0 met de optionele resource 0r_idcard. Sleutelkaarten blijven beschikbaar wanneer idcard ontbreekt of gestopt is.

```lua
JobCards = {
    Enabled = true,
    Resource = '0r_idcard',
    KeycardResource = 'ts_keycard',
},
```

Dit blok staat in `config/config.lua` naast `Locale`; configschema is **0.0.10**. De resourcenaam begint met een nul. Gebruik de aangepaste idcard-resource met export `OpenJobCardDesk`.

Client: `exports.ts_bridge:OpenJobCardDesk()` opent het idcard-menu en retourneert true. Bij uitgeschakelde koppeling, ontbrekende resource/export of een fout retourneert het false en toont het de NL/EN-melding dat jobkaarten momenteel niet werken. De melding komt uit `locales/` en gebruikt de bridge-taal.

Server: `exports.ts_bridge:IsAtKeycardDesk(source)` vraagt aan `ts_keycard:IsAtJobCardDesk` of deze speler met het huidige beroep bij het eigen officiële loket staat. Ongeldige ID, uitgeschakelde koppeling, gestopte loketresource of een exportfout levert false op. Dit is een serverexport, geen publiek net-event.

`GetStatus().features` bevat `OpenJobCardDesk` client-side en `IsAtKeycardDesk` server-side. De aanwezigheid van een API-feature betekent dat de bridgefunctie bestaat, niet dat de optionele idcard-resource draait.

Idcard bepaalt jobcard-items, foto's, persoonsgegevens, rangen, uiterlijk en serveruitgifte. Keycard bepaalt peds, opgeslagen locaties en eigen sleutelkaartregels. De bridge maakt zelf geen kaarten of peds en declareert geen dependency op beide optionele resources.

Start providers, dan `ts_bridge`, `ts_keycard` en optioneel `0r_idcard`. Na bridgeherstart moeten afhankelijke scripts opnieuw starten. Na uitsluitend idcard stoppen/starten is geen nieuwe keycard-ped nodig. In idcard staat `JobCardIntegration.UseKeycardDesks=true`; daarmee staat zijn eigen jobcard-ped uit. Gemeentehuis- en valsekaartpeds blijven bestaan.

Extra sleutelkaart-societies: mechanic → society_mechanic, taxi → society_taxi, sheriff → society_sheriff, justice → society_justice en fib → society_fib. Deze aliases staan onder `Server.SocietyAccounts`. Ze maken geen rekeningen of banen aan; controleer de bestaande ESX-database en pas namen zo nodig aan.

Volledige installatie, items en jobcardgedrag: `ts_keycard/INSTALLATIE.md` en `ts_keycard/JOBCARDS.md`. Documentatie en versienummer van 0r_idcard zijn niet gewijzigd.
