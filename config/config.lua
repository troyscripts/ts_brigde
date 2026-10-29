-- ALLE ALGEMENE INSTELLINGEN VAN TS_BRIDGE
-- Alleen geheime webhook-URLs staan in config/webhook_config.lua (server-only).
-- Dit bestand gaat ook naar clients: plaats hier nooit sleutels of URLs met tokens.
-- true = aan, false = uit. Resourcenamen zijn hoofdlettergevoelig.
-- Een andere resourcenaam werkt alleen wanneer die resource dezelfde vereiste API biedt.

-- 1. Algemeen, meldingen, toetsen en inventory
TSBridgeConfig = {
    Version = '0.0.9', -- Vereist configschema; geen keuze. Alleen wijzigen na overnemen van nieuwe velden.
    Locale = 'nl', -- 'nl' = Nederlands, 'en' = Engels; ontbrekende teksten vallen terug op Nederlands.
    NotificationTitle = 'Troy Scripts', -- Eigen, niet-lege standaardtitel; een melding mag deze overschrijven.
    NotificationDuration = 5000, -- Geheel getal 1–300000 milliseconden; 5000 = 5 seconden.
    WaypointKey = 'G', -- FiveM keyboard-key ID, bv. 'G' of 'F6'; stelt incidentlocatie als waypoint in.
    AlertDismissKey = 'BACK', -- Keyboard-key ID: 'BACK' = Backspace. Negeert uitsluitend de eigen melding.
    -- Bestaande persoonlijke FiveM-keybindings blijven voorrang houden op bovenstaande defaults.
    AlertLocation = {
        MapResource = 'ts_gemertmap', -- Resource met GetLocation-export; bij ontbreken geldt native locatie-fallback.
        ShowArea = true, -- true = gebiedsnaam tonen; false = verbergen.
        ShowPostcode = true, -- true = dichtstbijzijnde postcode tonen als de kaartprovider die aanlevert.
        ShowStreet = true, -- true = GTA-straat/kruising toevoegen; false = weglaten.
        MaxPostcodeDistance = 1500.0 -- Eindig getal >= 0, in meters; 0 = geen afstandslimiet.
    },
    AlertBlip = true, -- true = tijdelijke incidentblip; false = geen blip. Geen automatische route.

    Radial = {
        Enabled = true, -- true = bridge-opties tonen; false = alle bridge-opties verbergen. Commands blijven werken.
        Provider = 'ox_lib' -- Alleen 'ox_lib' ondersteund; gebruikt het bestaande ox_lib-radiaalmenu.
        -- ox_lib blijft ook bij Enabled = false nodig voor andere bridgefuncties.
        -- Herstart de server na wijzigen; hiermee wijzig je niet de persoonlijke menu-keybinding.
    },

    InventoryResource = 'ox_inventory', -- ox_inventory-compatibele resource; één naam voor client én server.
    TargetResource = 'ox_target', -- Alleen ox_target-compatibele API; geen qb-target-adapter.
    DeadStateKeys = { 'dead', 'isDead', 'laststand' } -- Lijst statebag-sleutels voor dood/laststand; {} = geen extra statekeys.
}

-- 2. Voertuigen, dealer, garage en sleutels
TSBridgeConfig.Vehicles = {
    Enabled = true, -- false = voertuigmodule uitschakelen; overige bridgefuncties blijven beschikbaar.
    Ownership = 'esx', -- Alleen 'esx': owned_vehicles, users en jobs. Vereist Server.Framework = 'esx'.
    Inventory = 'ox', -- Alleen 'ox': ox_inventory API; resourcenaam staat bovenaan bij InventoryResource.
    DatabaseResource = 'oxmysql', -- oxmysql-compatibele query-export; alleen nodig bij gebruik voertuigmodule.
    Dealer = { Provider = 'jg', Resource = 'jg-dealerships' }, -- Alleen 'jg'; dealer roept de kentekengenerator aan.
    Garage = { Provider = 'jg', Resource = 'jg-advancedgarages' }, -- Alleen 'jg'; jobgarages vereisen TSGetJobGarages-export.
    Keys = { Provider = 'mrnewb', Resource = 'MrNewbVehicleKeys' }, -- 'mrnewb' = GiveKeys/RemoveKeys; 'none' = geen sleutelkoppeling (Resource wordt dan genegeerd).
    PlatesResource = 'ts_nlplates' -- Resource met GeneratePlate-export voor de dealer; geen andere ingebouwde kentekenadapter.
}

-- 3. Framework, bank, facturen, society en screenshots
TSBridgeConfig.Server = {
    UpdateCheck = {
        Enabled = true, -- false = versiecontrole uit; true = melding, nooit automatische installatie.
        Repository = 'troyscripts/ts_brigde' -- 'eigenaar/repository'; '' = niet ingesteld. Dit is de GitHub-spelling.
        -- Optioneel: Branch = 'main' (weglaten = standaardbranch van GitHub).
        -- Optioneel: File = 'version.json' of 'version.txt' (weglaten = version.json).
    },
    -- Banking.Provider:
    -- 'apex' -> Resource = 'apex_banking', persoonlijke bankmutaties via Apex.
    -- 'esx'  -> persoonlijk ESX-bankaccount, geen aparte bankresource nodig (Resource mag '').
    -- 'okok' -> Resource = 'okokBanking'; persoonlijk saldo via ESX, okok-resource moet gestart zijn.
    -- Cash gebruikt altijd ESX; society-geld loopt altijd via SocietyResource hieronder.
    Banking = { Provider = 'apex', Resource = 'apex_banking' },
    -- Billing.Provider:
    -- 'apex'   -> Resource = 'apex_billing'; ingebouwde adapter voor aanmaken/opvragen, niet automatisch betalen.
    -- 'none'   -> facturen uit; Resource mag ''.
    -- 'custom' -> Resource = exacte naam van jouw resource die RegisterBillingProvider aanroept.
    -- 'okok'   -> Resource = 'okokBilling'; vereist een passende serveradapter via RegisterBillingProvider.
    -- Alleen 'okok' instellen maakt de koppeling NIET werkend; zonder adapter wordt billing_adapter_required teruggegeven.
    Billing = { Provider = 'apex', Resource = 'apex_billing' },

    Framework = 'esx', -- 'esx' of 'standalone'. Standalone heeft geen ESX-spelers/jobs/geld en geen jobontvangers.
    ESXResource = 'es_extended', -- ESX-resource met getSharedObject-export; gebruikt bij Framework = 'esx'.
    SocietyResource = 'esx_addonaccount', -- ESX getSharedAccount-event; geen andere ingebouwde society-adapter.
    SocietyAccounts = {
        -- Eigen aliases toevoegen is mogelijk: alias = { 'rekeningnaam', 'optionele_fallback' }.
        -- Minimaal één rekeningnaam per alias. Standaardrekening eerst; oude spelling alleen als fallback.
        police = { 'society_police', 'socity_police' },
        ambulance = { 'society_ambulance' },
        firefighter = { 'society_firefighter' } -- Brandweer; exacte ESX-job: firefighter.
    },
    ScreenshotResource = 'screenshot-basic', -- screenshot-basic-compatibele requestScreenshot-export.
    Screenshots = true, -- false = geen screenshots; webhook-tekst blijft beschikbaar.
    ScreenshotTimeoutMs = 8000, -- Geheel getal 100–300000 ms. Voertuigfoto-aanvragen gebruiken minimaal 20000 ms.
    MaxImageBytes = 4 * 1024 * 1024, -- Geheel getal 1–26214400 bytes (max. 25 MiB); standaard 4 MiB.
    MaxQueue = 32, -- Geheel getal 1–1000; totaal voor logs én gereserveerde screenshotplaatsen, alle scripts samen.
}

-- 4. Eigen bridge-logging (URLs staan in config/webhook_config.lua)
TSBridgeConfig.Audit = {
    Enabled = true -- true = eigen auditlogs aan; false = alle eigen auditcategorieën uit, overige scriptwebhooks blijven werken.
}

-- Interne koppeling; hieronder niets instellen.
TSBridgeVehicles = TSBridgeConfig.Vehicles
TSBridgeServer = TSBridgeConfig.Server
TSBridgeServer.InventoryResource = TSBridgeConfig.InventoryResource
TSBridgeServer.Webhooks = {}
TSBridgeAuditConfig = TSBridgeConfig.Audit
TSBridgeAuditConfig.Webhooks = {}

