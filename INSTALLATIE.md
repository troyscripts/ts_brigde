# Installatie — ts_bridge 1.0.8

De repository heet `ts_brigde`; de FiveM-resourcemap moet **ts_bridge** heten.

1. Maak een back-up van je resource en eigen instellingen. Beëindig actieve gijzelingen en stop afhankelijke scripts, daarna de bridge.
2. Plaats de volledige resource. Bij een bestaande installatie op configschema 0.0.8: verplaats je eigen `config.lua` naar `config/config.lua` en `webhook_config.lua` naar `config/webhook_config.lua`. Behoud alle eigen waarden en URLs.
3. Bij oudere configuratie: neem algemene waarden over in `config/config.lua`. Oude `server_config.lua`-waarden gaan onder `Server`, `vehicle_config.lua` onder `Vehicles` en `audit_config.lua` Enabled onder `Audit`. Stel `InventoryResource` eenmaal bovenaan in. Kopieer alle webhook-URLs naar `config/webhook_config.lua`. Zet Version pas op `0.0.8` nadat de velden zijn overgenomen.
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
