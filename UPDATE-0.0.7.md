# ts_bridge 0.0.7 — ambulance-society

Kopieer uitsluitend de gewijzigde bestanden van dit pakket over je bestaande `ts_bridge` resource. In `server_config.lua` is `ambulance = { 'society_ambulance' }` toegevoegd. Neem eventuele eigen banking-, billing-, webhook- en politie-instellingen uit je bestaande serverconfig over; overschrijf die niet blind.

Controleer dat de gedeelde ESX-rekening `society_ambulance` bestaat en via `esx_addonaccount` bereikbaar is. Start `ts_bridge` vóór `ts_keycard`. Herstart beide resources nadat de serverconfig en keycard 1.1.7 zijn geplaatst. Test een betaalde ambulancekaart: €10 bij de ontvanger afgeschreven en €10 op de ambulance-society bijgeschreven.

De scriptversie en `version.json` zijn 0.0.7. De gedeelde `config.lua` en configschemaversie blijven 0.0.6, omdat die instellingen niet zijn gewijzigd. Geen nieuwe exports. Dit pakket is statisch gecontroleerd; geen live FiveM-test uitgevoerd.
