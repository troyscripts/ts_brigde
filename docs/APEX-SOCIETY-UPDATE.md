# ts_bridge 1.1.8 — Apex-societyupdate

## Installatie op de server

1. Bewaar je huidige `config/config.lua` en `config/webhook_config.lua`.
2. Installeer de volledige resource als `resources/<jouw-categorie>/ts_bridge/`.
3. Behoud je eigen configwaarden en webhookinstellingen. In `config/config.lua`, binnen
   `TSBridgeConfig.Server`, kies je `SocietyResource = 'apex_banking'` voor de Apex-bedrijfsrekening,
   of `SocietyResource = 'esx_addonaccount'` voor ESX-societies. Het schema blijft 0.1.1.
4. Start de gekozen bankprovider vóór `ts_bridge`; start afhankelijke Troy Scripts daarna.
   Herstart tijdens onderhoud om alle aangepaste bestanden te laden.
5. Voer `ts_bridge_check` uit in de serverconsole en controleer providerstatus en config.
6. Test een kaartuitgifte of bedrijfsbetaling en controleer het saldo in Apex Banking en het baasmenu.
   Controleer dat andere scripts dezelfde rekening gebruiken.

De adapter is gecontroleerd tegen Apex Banking 2.3.3. Het pakket bevat geen databasesaldi,
geen saldomigratie en geen wijzigingen voor Sky-, JG- of Apex-resources. Bestaande
ESX-societygelden worden door deze bridge niet naar Apex overgeboekt.

## Gedrag bij fouten

Een gestopte provider veroorzaakt een fout, zonder fallback naar een andere rekening.
Een succesvolle Apex-mutatie retourneert een getal; een eindsaldo van 0 is ook succes.
Aanroepende scripts moeten `result.ok` controleren. Bij `uncertain = true` mag niet
blind opnieuw worden betaald of gecompenseerd. Er is geen atomaire transactie over
meerdere resources en geen persistente transactieadministratie toegevoegd.

## Zelf op GitHub zetten

Pak de ZIP uit en upload de **inhoud** van de map `ts_bridge` in de hoofdmap van
`troyscripts/ts_brigde`. Zo staat `fxmanifest.lua` direct in de repositoryroot.
Neem ook de meegeleverde `.github/workflows/check.yml` mee als je Git gebruikt.
Publiceer nooit je eigen webhook-URLs; de meegeleverde webhookconfig bevat de template.
Een GitHub-release met tag `v1.1.8` kan daarna naar deze versie verwijzen.

## Controle

Lua-syntax, manifestbestanden, versienummers en geldadapterregressies worden gecontroleerd.
De geldtests gebruiken gesimuleerde providers; een live test op de eigen server is nodig.
