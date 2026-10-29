# Bridge-audit — 22 oktober 2026

Gerichte vergelijking van de huidige GitHub-code en het volledige bridgepakket 1.0.5. Geen volledige beveiligingsaudit of live FiveM-test.

| Script | Bevinding | Besluit |
|---|---|---|
| ts_hostage | Eigen HTTP-updatechecker dupliceert CheckForUpdates. Camera, targets, meldingen en webhooktransport lopen al via de bridge. | Checker vervangen door bridge-aanroep in 1.2.2; CheckForUpdates toevoegen aan vereiste functies. Gijzelingssessies, animaties en berichtinhoud blijven hier. |
| ts_antipunch | Updatechecker, camera en combatcontext gebruiken de bridge al. | Geen extra verplaatsing nodig voor deze onderdelen; framegebonden controlblokkering blijft lokaal. |
| ts_keycard | Geld/inventory/permissions en webhooktransport zijn reeds adapters in de bridge. Uitgiftebetalingen bevatten compensatie bij mislukte kaartuitgifte. | Uitgifte, vervalsing en intrekking blijven scriptlogica; geen generieke betalingstransactie introduceren zonder gedeeld gebruik. |
| ts_flatbed | Updatechecker en UI/job/targetfuncties gebruiken de bridge. | Geometrie, lier, lepel en voertuigsynchronisatie blijven lokaal. Instelbare toleranties horen in eigen config. |
| ts_nlplates | Eigen updatechecker met consolecommando en hercontrole na 60 seconden. Webhooktransport en voertuigadapters gebruiken de bridge. | Goede volgende kandidaat, maar eerst gecontroleerde hercontrole toevoegen aan de bridge. De huidige bridge accepteert slechts één check per resource-start; blind vervangen zou het commando beperken. Kentekengeneratie en bewijsuitgifte blijven lokaal. |
| ts_gemertmap | Zelfstandige kaart zonder bridge-afhankelijkheid, met eigen updatechecker. | Zelfstandig houden. Hoogstens optioneel hergebruik; geen verplichte afhankelijkheid toevoegen voor alleen een versiecheck. |
| ts_nlplates_migrate | Eenmalige consolemigratie met gestopte resources en databasetransactie. | Zelfstandig onderhoudsgereedschap houden. |
| Discord-bot | Afzonderlijke Node.js/Discord-runtime. | Geen FiveM-bridgekoppeling. |

## Mogelijke vervolgstap

De bridgeguards van hostage, antipunch en keycard overlappen. Een gedeelde validatiehelper kan versie/API/functiecontroles uniform maken, maar de lokale bootstrap, stopafhandeling en scriptgebonden providervereisten moeten blijven werken wanneer de bridge ontbreekt. Dit verdient een afzonderlijke, geteste wijziging over alle betrokken repositories.

## Afbakening

Alle algemene bridge-instellingen blijven in config/config.lua; geheime webhook-URLs staan in config/webhook_config.lua. De configversie stijgt alleen bij een daadwerkelijke schemawijziging. Bij deze herstelrelease blijft die 0.0.7.


## Gedeelde werkpasloketten

Zie [JOBCARDS.md](JOBCARDS.md) voor de optionele koppeling met ts_keycard 1.3.0 en 0r_idcard. Neem het JobCards-blok en de extra societyaliases uit de nieuwe config over voordat je het configschema op 0.0.10 zet. Deze update voegt geen harde idcard-dependency toe.
