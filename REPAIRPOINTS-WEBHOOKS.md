# Webhooks — ts_repairpoints 1.1.1 / ts_bridge 1.1.4

Vul in `ts_bridge/config/webhook_config.lua` de routes onder `ts_repairpoints` in:

```lua
ts_repairpoints = {
    murder = '',
    placed = '',
    removed = '',
},
```

Gebruik een volledige Discord-webhook-URL. Dezelfde URL mag op alle drie de regels. Leeg = die melding uit. Bewaar bestaande routes voor andere scripts. URLs blijven uitsluitend op de server.

In `ts_repairpoints/config/server.lua` staat `RepairWebhookConfig`: hoofdschakelaar Enabled, Events en Photos per route. Standaard staan alle gebeurtenissen en foto's aan; er wordt pas verzonden zodra een URL is ingevuld.

- **murder:** één melding per bevestigd overlijden, met punt-ID, locatie, bevestigde dader of onbekend, en gevraagde vergoeding. Een gevraagde vergoeding is geen bewijs van betaling; onvoldoende saldo blijft als schuld staan. Ook een echte dood met onbekende oorzaak wordt gelogd, zonder iemand daarvoor aan te wijzen.
- **placed / removed:** alleen na een geslaagde opslag van een in-game punt; bevat de beheerder, punt-ID en locatie. Configpunten handmatig wijzigen en de vertrekplek wijzigen vallen hier niet onder.
- **Foto:** huidig spelbeeld kort na de gebeurtenis. Bij een moord krijgt de bevestigde dader in dezelfde instantie binnen WitnessRadius (standaard 75 meter) voorrang. Anders wordt de dichtstbijzijnde speler binnen die afstand gebruikt en als fotobron benoemd, nooit als dader. Bij beheeracties is de beheerder de fotobron. Het is geen replay: de reparateur of het exacte moordmoment hoeft niet in beeld te zijn.
- Vereist voor foto's: `screenshot-basic` gestart, `TSBridgeServer.Screenshots = true`. De bestaande bridge verzorgt de foto, wachtrij en tekstfallback bij fout of time-out. Geen geschikte speler: direct alleen tekst.
- Discordmeldingen zijn best effort. Een mislukte webhook verhindert geen opgeslagen beheeractie, politiealarm of schadevergoeding. Geen testmelding wordt automatisch verstuurd bij opstarten.

## Bijwerken

1. Bewaar eigen configs en de volledige `ts_repairpoints/data/`-map.
2. Installeer de twee complete resources. Behoud de huidige ts_bridge-instellingen en voeg de drie routes toe; configschema bridge is 0.1.1, reparatiepunten 1.1.1.
3. Neem `RepairWebhookConfig` over in de serverconfig van reparatiepunten.
4. Start screenshot-basic vóór de bridge. Stop eerst ts_repairpoints, herstart ts_bridge en start daarna ts_repairpoints.
5. Test een plaatsing en verwijdering, en daarna een moord op een testserver. Controleer één melding per actie, foto/tekstfallback en de bestaande politieafhandeling.

## Foto-time-outs
De bridge reserveert minimaal 45 seconden voor opname plus foto-overdracht, ook met een oude ScreenshotTimeoutMs = 8000. Normale opname krijgt 15 seconden. Via ts_bridge_check is zichtbaar of de client de aanvraag ontvangt en of de foto-overdracht begint. Bij uitblijvende bevestiging: controleer F8 bij de fotobron en eventuele eventblokkades. Verhoog niet blind de time-out als de client niet antwoordt.
