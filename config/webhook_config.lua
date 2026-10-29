-- ALLE WEBHOOK-URLs. Dit bestand wordt uitsluitend server-side geladen.
-- Opties per veld: '' (leeg) of een volledige Discord-webhook-URL:
-- https://discord.com/api/webhooks/ID/TOKEN (ook /api/v10/webhooks/ID/TOKEN).
-- Geen queryparameters of andere hosts. Deel/upload nooit ingevulde URLs.
-- Lege centrale route = aangesloten script mag zijn eigen server-side URL gebruiken.
-- Aanvullende routes: resource_naam = { route_naam = 'URL' }; de aanroeper bepaalt de route.
TSBridgeServer.Webhooks = {
    ts_hostage = {
        start = 'https://discord.com/api/webhooks/1548028422721249290/2BY9OPXPOvFkCNNoFGf1O5Sb1ne_qeA6wbxNJk7oHl23aI6l7wZ-ue6KbOi-l0MCj5P4', -- Start van een gijzeling.
        actions = 'https://discord.com/api/webhooks/1548028526966345729/shdpZ1si1HGukYZRbqgQQjQz1jR8GHGnMweSv2wYWxeBYm6DxkAfSNMpdkVaKG8UaCMG' -- Vervolgacties zoals loslaten of doden, aangeleverd door ts_hostage.
    },
    ts_nlplates = {
        created = 'https://discord.com/api/webhooks/1561825008915845133/eRoK7zRBTSLq5fKyM93NGvH67hMvcAKmfRw41w8fQ5O2xo-Qd2UKedp68-spdsLC6YNR', -- Nieuw aangemaakt kentekenbewijs.
        replacement = 'https://discord.com/api/webhooks/1562859304187596890/Ax0H3CxfZrL4y3Jzzgpq4e4l6aGTP7h2lFrw3zPvusidWL-kbA9mvtTSUwcfk0N9Kdec', -- Vervangend kentekenbewijs.
        registration = 'https://discord.com/api/webhooks/1562859420453576804/QdgheQ6tOExmuoEhXs-mJCC_EIaswILnOrplmucADwHUTYmJKpgBvnhdGIvboPGZ_Is3' -- Oude/gedeelde fallbackroute, gebruikt door compatibele ts_nlplates-versies.
    }
}

-- Eigen bridge-logs: '' = categorie uit; volledige URL = categorie aan.
-- Dezelfde URL mag bij meerdere categorieën. Alleen acties VIA de bridge worden gelogd.
-- Hoofdschakelaar: TSBridgeConfig.Audit.Enabled in config/config.lua.
TSBridgeAuditConfig.Webhooks = {
    payments = 'https://discord.com/api/webhooks/1562088209523933216/-zPpgbCbtIDIDwCe4MEkjxxiCZdna00P1lXq_5zSCh7AueJp9d7z6UB3pAjYPdK70Tv4', -- Geslaagde persoonlijke geldacties.
    societies = 'https://discord.com/api/webhooks/1562088392425218088/SR64NsXweuKwWpeNBPROwLmpT_UIgXaEwziGnKqP0cWtv8xAAt7Xws_hzXVx2Hu5h9ZC', -- Geslaagde society-transacties.
    invoices = 'https://discord.com/api/webhooks/1562088488843612212/GubBYPbJXZiIhrfro8btyQbD5h0uinWAPO6N3O25UmZrRKNOx7sSF6hd6FULEse03aAV', -- Aangemaakte facturen; dit betekent niet dat ze zijn betaald.
    errors = 'https://discord.com/api/webhooks/1562088583941324941/DKItLcEPZraa54l0NIpeBmsmjtMUEIxOOV_11QZSfwrMrb7amyZyPlxDFM76fomhlK--', -- Mislukte geldacties, facturen en saldo-/factuuropvragingen; geen algemene consolelogger.
}

