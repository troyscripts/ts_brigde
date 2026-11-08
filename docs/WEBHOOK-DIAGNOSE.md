# Webhookdiagnose — ts_bridge 1.1.7

De consoleopdracht `ts_bridge_check` toont naast de bestaande resource- en screenshotstatus nu ook veilige informatie over Discord-webhooks.

- **Webhookroutes:** per resource de namen van ingestelde centrale routes, bijvoorbeeld `ts_keycard: issue, revoke`. Alleen geldig geconfigureerde Discord-URL's tellen; de URL en het token verschijnen nooit.
- **Bevestigd:** Discord leverde een 2xx-status met een message-id.
- **HTTP zonder bevestiging:** Discord leverde 2xx maar zonder te verifiëren message-id; dit wordt niet automatisch opnieuw verzonden.
- **Mislukt:** definitieve non-2xx / transportfouten na eventuele retries en fotofallback.
- **429-pogingen:** het aantal uitgevoerde retry-pogingen bij rate limits.
- **Foto-tekstfallback:** het aantal keren dat een afgewezen foto als tekstbericht opnieuw werd aangeboden.

De tellers worden bij elke herstart van `ts_bridge` teruggezet. Ze zijn geen auditarchief.

## API

`exports.ts_bridge:GetWebhookStatus()` (server-side) bevat voortaan ook `configuredRoutes`, `auditRoutes` en `deliveries`, naast de bestaande velden. `configuredRoutes.ts_keycard.issue == true` betekent dat een **centrale** route is geconfigureerd. Een extern script kan daarnaast een eigen server-side fallback hebben die niet in dit overzicht staat.

```lua
local status = exports.ts_bridge:GetWebhookStatus()
local central = status.configuredRoutes.ts_keycard
if central and central.issue then print('Centrale uitgifte-webhook ingesteld') end
```

Gebruik nooit een echte webhook-URL in je publieke GitHub-config. Het centrale bestand `config/webhook_config.lua` blijft uitsluitend server-side en accepteert `''` voor een uitgeschakelde route. Laat de bestaande `Config.Version` op `0.1.1`.

