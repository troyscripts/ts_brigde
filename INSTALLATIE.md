# Installatie — ts_bridge 1.1.2

De repository heet `ts_brigde`; de FiveM-resourcemap moet **ts_bridge** heten.

1. Maak een back-up van je resource en eigen instellingen. Beëindig actieve gijzelingen en stop afhankelijke scripts, daarna de bridge.
2. Plaats de volledige resource. Bij een bestaande installatie op configschema 0.0.8: verplaats je eigen `config.lua` naar `config/config.lua` en `webhook_config.lua` naar `config/webhook_config.lua`. Behoud alle eigen waarden en URLs.
3. Bij oudere configuratie: neem algemene waarden over in `config/config.lua`. Oude `server_config.lua`-waarden gaan onder `Server`, `vehicle_config.lua` onder `Vehicles` en `audit_config.lua` Enabled onder `Audit`. Stel `InventoryResource` eenmaal bovenaan in. Kopieer alle webhook-URLs naar `config/webhook_config.lua`. Voeg ook het Radial-blok hieronder toe. Zet Version pas op `0.0.10` nadat alle velden zijn overgenomen.
4. Verwijder na overname de oude rootbestanden `config.lua`, `webhook_config.lua`, `locale.lua`, en indien aanwezig `server_config.lua`, `vehicle_config.lua`, `audit_config.lua`. Verwijder ook oude `UPDATE-*.md`, `UPDATE-BESTANDEN.txt`, `VERWIJDERD*` en `TESTRESULTATEN-*.md`. Als de geannuleerde 1.0.4 is geïnstalleerd: verwijder `okok_config.lua` en `server/okok.lua`.
5. Kies `Locale = 'nl'` of `Locale = 'en'` in `config/config.lua`. Eigen tekstinstellingen blijven voorrang houden. Bewerk vertalingen in `locales/`.
6. Start providers, de bridge en daarna alle afhankelijke resources opnieuw.

```cfg
ensure ox_lib
# Start ingestelde ESX-, inventory-, target-, banking- en billingproviders vooraf.
# Start ts_gemertmap vooraf indien gebruikt.
ensure ts_bridge
# Daarna alleen de daadwerkelijk geïnstalleerde scripts:
ensure ts_antipunch
ensure ts_hostage
ensure ts_keycard
```

Controleer Banking.Provider en Billing.Provider: Apex is standaard; kies de bij jouw installatie passende ondersteunde provider. Society-geld loopt via esx_addonaccount. Controleer dat society_police/socity_police en society_ambulance bestaan wanneer gebruikt. Zie KEYCARD-BANKING-BILLING.md, OKOK.md en VOERTUIGEN.md.

Configschema 0.0.8 bevat de firefighter-societyalias. Voor brandweer: zie BRANDWEER-INSTALLATIE.md en install/firefighter_society.sql. Webhook-URLs blijven server-only: publiceer geen ingevulde URLs op GitHub. Webhookinstellingen van andere resources blijven in die resources staan.

## Controle na installatie

Voer `ts_bridge_check` uit in de serverconsole. Controleer meldingen in de gekozen taal, G voor waypoint, Backspace voor persoonlijk negeren, verlopen en twee opeenvolgende meldingen. Bestaande routes en meldingen van collega's moeten intact blijven. Persoonlijke FiveM-keybindings worden niet overschreven door nieuwe defaults.

Test geldmutaties, societybetalingen, kaarten, facturen, screenshots en webhookaflevering. Test camera aanvragen/loslaten met meerdere scripts, voertuigcamera, overlijden en resource-stop. Geen live FiveM-/Discord-test is onderdeel van de lokale controles.

Ontbreekt een foto? Controleer de laatste screenshot-, Discord-resultaat- en Discord-foutregels. Deel geen webhook-URLs. De Node-runtime is ingebouwd in FiveM; npm of een upload-API-sleutel is niet nodig.

## Terugzetten

Stop afhankelijke scripts en herstel de volledige back-up, inclusief de oude manifest- en configuratie-indeling. Start de bridge en afhankelijke scripts opnieuw.


## ts_nohelmet 1.0.2 koppelen

Voor de directe schuifoptie in het ox_lib-radiaalmenu is ts_bridge 1.1.2 of nieuwer nodig. Start in deze volgorde:

```cfg
ensure ox_lib
ensure ts_bridge
ensure ts_nohelmet
```

De instellingen voor `/schuif`, de automatische stoelblokkering en de menutekst staan in `ts_nohelmet/config/config.lua`. Voor 1.1.0 moet het Radial-blok worden toegevoegd en de configversie naar 0.0.10. Behoud je overige instellingen en webhooks. De optie verschijnt alleen wanneer je op een voorstoel zit en de andere voorstoel vrij is.

## Configmigratie 1.1.0 — radiaalmenu

Voeg in de tabel `TSBridgeConfig` in `config/config.lua` toe:

```lua
Radial = {
    Enabled = true, -- false verbergt bridge-menuopties; commands blijven werken.
    Provider = 'ox_lib' -- Enige ondersteunde provider.
},
```

Verander in dezelfde tabel `Version = '0.0.8'` naar `Version = '0.0.10'`, nadat je het blok hebt overgenomen. Vervang niet je aangepaste bank-, job- of webhookinstellingen door defaults. Plan een serverherstart. ox_lib moet vóór ts_bridge starten en blijft ook bij een uitgeschakeld radiaalmenu vereist. Controleer met `Enabled = true` dat submenu’s en `Wissel voorstoel` verschijnen wanneer het aanroepende script ze beschikbaar maakt. Met `Enabled = false` mogen alleen de bridge-opties verdwijnen; `/schuif` blijft bruikbaar.

## Gedeelde werkpasloketten

Zie [JOBCARDS.md](JOBCARDS.md) voor de optionele koppeling met ts_keycard 1.3.0 en 0r_idcard. Neem het JobCards-blok en de extra societyaliases uit de nieuwe config over voordat je het configschema op 0.0.10 zet. Deze update voegt geen harde idcard-dependency toe.
