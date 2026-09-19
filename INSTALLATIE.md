# Installatie — ts_bridge 0.0.4 (stabiel)

De FiveM-resourcemap heet **ts_bridge**. De GitHub-repository heet **ts_brigde**.

1. Maak een backup van resources en configuraties.
2. Stop afhankelijke scripts, waaronder ts_keycard en ts_hostage, en daarna ts_bridge.
3. Vervang alle bridge-programmabestanden met ts_bridge-0.0.4.zip, inclusief het
   manifest en server/updates.lua. Behoud je eigen config.lua en server_config.lua.
4. Configschema blijft 0.0.3. Heb je nog geen TSBridgeConfig.Version, voeg dan
   Version = '0.0.3' binnen de TSBridgeConfig-tabel toe en controleer de bestaande velden.
5. Installeer ts_keycard 1.1.5 en neem zijn nieuwe configvelden over volgens diens
   UPDATE-INSTALLATIE.md. De bestaande ts_hostage 1.1.8 kan blijven staan.
6. Start providers, daarna de bridge en vervolgens afhankelijke scripts.

```cfg
ensure ox_lib
# Bestaande framework-, inventory-, target- en bankingproviders vooraf starten.
ensure ts_bridge
ensure ts_keycard
ensure ts_hostage
```

Start alleen de scripts die geïnstalleerd zijn. Behoud de bestaande Apex Banking/Billing-
instellingen, society-aliases en webhookroutes. Deze update verandert geen database.

Controleer versie 0.0.4, configschema 0.0.3 en ts_bridge_check in de serverconsole.
De diagnose controleert configuratie en providerstatus zonder testbetalingen te doen.
Bij onbruikbare configuratie worden operationele exports geblokkeerd. Herstel de
vermelde velden en herstart; alleen het configversienummer aanpassen is onvoldoende.

Test met twee spelers kaartuitgifte, saldo/society, intrekking en de bestaande
hostage-bediening. Target- en radialregistraties herstellen bij providerstart zolang
de bridge en eigenaar blijven draaien. Na volledige bridge-uitval de afhankelijke
scripts opnieuw starten. Geen automatische hervatting van lopende sessies.

## GitHub

Bridge: plaats version.json met 0.0.4 naast fxmanifest.lua in de hoofdmap van de
standaardbranch van https://github.com/troyscripts/ts_brigde.
Keycard: plaats version.txt met 1.1.5 in main van https://github.com/troyscripts/ts_keycard.
De controle vergelijkt versienummers en toont een downloadlink; installeert niets.
Publicatie op GitHub wordt niet automatisch uitgevoerd door het downloaden van deze ZIP.

Het bestaande UpdateCheck-blok van de bridge kan blijven staan. Zonder dat blok
wordt de standaardrepository gebruikt. De configschema-versie blijft 0.0.3 omdat
geen nieuwe verplichte instellingen zijn toegevoegd.

## Terugzetten

Stop afhankelijke scripts en zet bridge én de bijpassende scriptversies terug uit
backup. Keycard 1.1.5 vereist minimaal bridge 0.0.4 en de nieuwe CheckForUpdates-export.
