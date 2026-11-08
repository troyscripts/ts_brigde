# Mappenstructuur — ts_bridge 1.1.6

De GitHub-repository heet **`ts_brigde`**. De FiveM-resourcemap moet ongewijzigd **`ts_bridge`** blijven heten. Veel TroyScripts-resources gebruiken die naam bij exports en dependencies.

```text
ts_bridge/
├── fxmanifest.lua
├── version.json
├── README.md
├── shared_status.lua            # bestaand pad behouden voor externe tests
├── config/
│   ├── config.lua                # gedeeld; Config.Version 0.1.1
│   └── webhook_config.lua        # uitsluitend server; eigen URLs
├── shared/
│   ├── config_validation.lua
│   ├── config_version.lua
│   └── vehicle_plates.lua
├── locales/
│   ├── locale.lua
│   ├── nl.lua
│   └── en.lua
├── client/
│   ├── core/                    # meldingen, camera, radial, alerts en foto's
│   └── integrations/            # keycard, werkpassen en voertuigen
├── server/
│   ├── core/                    # framework, money, inventory, billing, diagnose
│   ├── integrations/            # voertuigen en werkpassen
│   ├── services/                # webhooks, updates en updatecontrole
│   └── uploads/                 # uploader, documentrenderer, fontatlas (server-only)
├── web/                          # bestaande NUI-alertpagina
├── install/
│   └── sql/firefighter_society.sql
├── docs/                         # handleidingen, changelog, licentie
└── .github/workflows/check.yml
```

## Behoud van compatibiliteit

- De `fxmanifest.lua` gebruikt alle nieuwe paden in **exact de oude uitvoervolgorde**. `shared_status.lua` blijft bewust in de hoofdmap en wordt op client én server geladen, zodat tests van andere resources met een hard pad blijven werken.
- `server/uploads/screenshot_upload.js` laadt `server/uploads/document_image.js`, die `document_font.json` uit dezelfde map leest.
- Exports, events, `TSBridgeConfig`, `TSBridgeServer`, `TSBridgeAuditConfig`, `GetStatus` API-versie en resource-KVPs wijzigen niet.
- Scriptversie 1.1.5 → 1.1.6. Configschema 0.1.1 blijft gelijk.
- Alle lokale webhookroutes blijven in `config/webhook_config.lua` staan. Hier is een lege string `''` een **bewuste uitschakeling**: een tekst als `plaat_hier_jou_webhook` is geen geldige Discord-webhook en zou de validatie niet doorstaan.

## Veilig bijwerken

1. Maak een back-up van je geïnstalleerde `ts_bridge` en vooral van `config/config.lua` en `config/webhook_config.lua`. Bewaar ingevulde URLs nooit in je openbare GitHub-repository.
2. Stop scripts die de bridge gebruiken en stop daarna `ts_bridge`.
3. Vervang de **volledige** resource-map met de nieuwe versie en neem eigen instellingen over in de bestaande configpaden. Laat geen oude root-, client- of serverbestanden achter.
4. Start eerst framework, inventory, bank, `ox_lib` en overige benodigde providers, dan `ts_bridge`, vervolgens de afhankelijke TroyScripts-resources.
5. Voer `ts_bridge_check` uit. Controleer daarna op de FiveM-testserver de keycard-uitgifte, werkpassen, societybetalingen, `ts_nlplates`, voertuigintegraties, alerts, screenshots en kentekenbewijsafbeeldingen.
6. Als de controles falen: zet de back-up van de gehele oude resource terug en herstart de afhankelijkheden.

## Niet gewijzigd

`config/config.lua` en `config/webhook_config.lua` hebben dezelfde inhoud en hetzelfde pad. De brandweer-SQL is uitsluitend **verplaatst**, en hoeft door deze onderhoudsupdate niet opnieuw te worden uitgevoerd.

