# Installatie — ts_bridge 0.0.3 (stabiel)

De resourcemap moet **ts_bridge** heten; niet ts_brigde-main of ts_bridge-main.

1. Maak backups van ts_bridge, ts_hostage en hun configuratiebestanden.
2. Stop afhankelijke scripts, waaronder ts_hostage en eventueel ts_keycard. Stop daarna ts_bridge.
3. Vervang ts_bridge door de inhoud van ts_bridge-0.0.3.zip.
4. Bewaar je eigen server_config.lua: het nieuwe UpdateCheck-blok is optioneel; zonder dit blok gelden de meegeleverde standaardwaarden.
   Neem eigen waarden over in config.lua en voeg TSBridgeConfig.Version = '0.0.3'
   toe binnen de bestaande TSBridgeConfig-tabel. Deze release voegt alleen dit veld toe.
5. Installeer ook de bijbehorende bijgewerkte ts_hostage 1.1.8 als je de nieuwe
   gedeelde functies wilt gebruiken. Behoud de configversie 1.1.8; als je nog van
   hostage 1.1.7 komt, volg ook zijn UPDATE-INSTALLATIE.md.
6. Start je bestaande providers en daarna ox_lib, ts_bridge en de afhankelijke scripts.

```cfg
ensure ox_lib
# Hier jouw bestaande framework/inventory/target/banking-providers.
ensure ts_bridge
ensure ts_hostage
# Indien geïnstalleerd:
ensure ts_keycard
```

Behoud de bestaande providerinstellingen, webhookroutes en eigen sleutels.
Geen databasewijziging. De keycard-resource wordt niet in deze download meegeleverd.
De bestaande API 1 blijft bruikbaar voor keycard; de configuratie daarvan verandert niet.

Controleer in de serverconsole versie 0.0.3 en de configstatus. Ontbreekt Config.Version,
dan volgt een waarschuwing; de bestaande bridge-instellingen blijven bruikbaar.
Test daarna met twee spelers de E/target/radial-bediening van hostage, first person,
meldingslimiet, loslaten/omleggen en politie-/webhookmeldingen.
Na een volledige bridgeherstart ook de afhankelijke resources herstarten. Target- en radialregistraties worden bij providerstart hersteld zolang de bridge blijft draaien.

Terugzetten: stop afhankelijke scripts, zet beide resources terug uit dezelfde backup,
en start eerst de oude bridge. De nieuwe hostage-aansluiting vereist bridge 0.0.3.

## Aanvulling binnen dezelfde versie

Vervang ook bij een al geïnstalleerde 0.0.3 alle programmabestanden, inclusief
fxmanifest.lua, config_validation.lua en de nieuwe serverbestanden. Behoud je eigen
config.lua en server_config.lua wanneer die al correct zijn; configversie blijft 0.0.3.
Het optionele UpdateCheck-blok staat in de meegeleverde server_config.lua.
Gebruik ts_bridge_check om inhoud en providers te controleren. Foutieve velden eerst
herstellen: alleen het versienummer verhogen lost een ongeldige configuratie niet op.

Voor GitHub: upload version.json naast fxmanifest.lua naar de hoofdmap van de
standaardbranch van https://github.com/troyscripts/ts_brigde.
De repositorynaam bevat brigde, de FiveM-mapnaam blijft ts_bridge.
De updatecontrole toont geen verschil tussen twee builds die beide 0.0.3 heten.
De eerder meegeleverde ts_hostage 1.1.8 kan blijven staan; voor deze aanvulling is
geen nieuwe hostage-download nodig.

Controleer live: opstart/configmelding, ts_bridge_check, een normale webhook en
screenshotfalen, targetopties na ox_target-herstart en radialmenu na providerstart.
Test providerherstarts buiten een actieve gijzeling. De GitHub-controle moet na
publicatie aangeven dat 0.0.3 actueel is.
