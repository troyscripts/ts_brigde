-- ALLE ALGEMENE INSTELLINGEN VAN TS_BRIDGE
-- Alleen geheime webhook-URLs staan in webhook_config.lua (server-only).
-- Dit bestand is gedeeld met clients: plaats hier nooit sleutels of URLs met tokens.

-- 1. Algemeen, meldingen, toetsen en inventory
TSBridgeConfig = {
    Version = '0.0.7', -- configschema; alleen wijzigen na overnemen van nieuwe velden
    Locale = 'nl', -- Hoofdtaal; teksten staan in locales/nl.lua
    NotificationTitle = TSL('config_troy_scripts'),
    NotificationDuration = 5000,
    WaypointKey = 'G',
    AlertDismissKey = 'BACK', -- Backspace; per speler opnieuw te binden in FiveM
    AlertLocation = {
        MapResource = 'ts_gemertmap',
        ShowArea = true,
        ShowPostcode = true,
        ShowStreet = false,
        MaxPostcodeDistance = 1500.0 -- meter; 0 = geen afstandslimiet
    },
    AlertBlip = true, -- tijdelijke incidentblip; geen automatische route

    InventoryResource = 'ox_inventory', -- één instelling voor client én server
    TargetResource = 'ox_target', -- alleen een ox_target-compatibele resource
    DeadStateKeys = { 'dead', 'isDead', 'laststand' }
}

-- 2. Voertuigen, dealer, garage en sleutels
TSBridgeConfig.Vehicles = {
    Enabled = true,
    Ownership = 'esx', -- owned_vehicles + users + jobs
    Inventory = 'ox', -- ox_inventory API; resourcenaam in bestaande config
    DatabaseResource = 'oxmysql',
    Dealer = { Provider = 'jg', Resource = 'jg-dealerships' },
    Garage = { Provider = 'jg', Resource = 'jg-advancedgarages' },
    Keys = { Provider = 'mrnewb', Resource = 'MrNewbVehicleKeys' }, -- of Provider = 'none'
    PlatesResource = 'ts_nlplates'
}

-- 3. Framework, bank, facturen, society en screenshots
TSBridgeConfig.Server = {
    UpdateCheck = { Enabled = true, Repository = 'troyscripts/ts_brigde' }, -- controle, geen automatische installatie
    Banking = { Provider = 'apex', Resource = 'apex_banking' }, -- 'apex', 'esx' of 'okok' (Resource = 'okokBanking')
    Billing = { Provider = 'apex', Resource = 'apex_billing' }, -- 'apex', 'custom', 'none'; 'okok' vereist nog versiegebonden adapter

    -- okokBanking: persoonlijk ESX-bankaccount; society altijd via addonaccount hieronder.
    -- okokBilling: Resource = 'okokBilling'; eerst de echte serveradapter aansluiten.
    Framework = 'esx', -- 'esx' of 'standalone'; standalone heeft geen jobontvangers
    ESXResource = 'es_extended',
    SocietyResource = 'esx_addonaccount', -- gebruikt het ESX getSharedAccount-event
    SocietyAccounts = {
        -- Standaardrekening eerst; oude spelling uitsluitend als fallback.
        police = { 'society_police', 'socity_police' },
        ambulance = { 'society_ambulance' }
    },
    ScreenshotResource = 'screenshot-basic', -- screenshot-basic-compatibele export
    Screenshots = true,
    ScreenshotTimeoutMs = 8000,
    MaxImageBytes = 4 * 1024 * 1024,
    MaxQueue = 32, -- gezamenlijke bovengrens voor alle aangesloten scripts
}

-- 4. Eigen bridge-logging (URLs staan in webhook_config.lua)
TSBridgeConfig.Audit = {
    Enabled = true -- false schakelt alle eigen bridge-auditlogs uit
}

-- Interne koppeling; hieronder niets instellen.
TSBridgeVehicles = TSBridgeConfig.Vehicles
TSBridgeServer = TSBridgeConfig.Server
TSBridgeServer.InventoryResource = TSBridgeConfig.InventoryResource
TSBridgeServer.Webhooks = {}
TSBridgeAuditConfig = TSBridgeConfig.Audit
TSBridgeAuditConfig.Webhooks = {}
