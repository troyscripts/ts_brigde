# ts_bridge 1.0.6

De GitHub-upload van 1.0.5 miste de runtime-mappen. Deze versie herstelt de bestanden uit ts_bridge-v1.0.5-volledig.zip. Alle 20 al aanwezige GitHub-bestanden kwamen exact overeen met dat pakket voordat de versieverhoging werd toegepast.

1. Maak een back-up van je huidige resource en eigen instellingen.
2. Plaats het volledige pakket in de resource-map **ts_bridge** (repository heet ts_brigde).
3. Behoud je bestaande config.lua en webhook_config.lua als je al op schema 0.0.7 zit. Bij oudere configuratie: volg UPDATE-1.0.5.md.
4. Start de bridge vóór de afhankelijke scripts. Controleer `ts_bridge_check` en test geld, kaarten, screenshots en camera op een testserver.

Scriptversie 1.0.6; configschema blijft 0.0.7. Geen SQL-migratie. De geannuleerde okok-uitbreiding is niet teruggeplaatst.

Dit herstelt de GitHub-distributie; er is geen live FiveM-server getest. Zie BRIDGE-AUDIT.md voor de beoordeling van gedeelde functies.
