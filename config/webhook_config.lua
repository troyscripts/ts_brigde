-- ALLE WEBHOOK-URLs. Dit bestand wordt uitsluitend server-side geladen.
-- Opties per veld: '' (leeg) of een volledige Discord-webhook-URL:
-- https://discord.com/api/webhooks/ID/TOKEN (ook /api/v10/webhooks/ID/TOKEN).
-- Geen queryparameters of andere hosts. Deel/upload nooit ingevulde URLs.
-- Lege centrale route = aangesloten script mag zijn eigen server-side URL gebruiken.
-- Aanvullende routes: resource_naam = { route_naam = 'URL' }; de aanroeper bepaalt de route.
TSBridgeServer.Webhooks = {
    ts_hostage = {
        start = '', -- Start van een gijzeling.
        actions = '' -- Vervolgacties zoals loslaten of doden, aangeleverd door ts_hostage.
    },
    ts_nlplates = {
        created = '', -- Nieuw aangemaakt kentekenbewijs.
        replacement = '', -- Vervangend kentekenbewijs.
        registration = '' -- Oude/gedeelde fallbackroute, gebruikt door compatibele ts_nlplates-versies.
    }
}

-- Eigen bridge-logs: '' = categorie uit; volledige URL = categorie aan.
-- Dezelfde URL mag bij meerdere categorieën. Alleen acties VIA de bridge worden gelogd.
-- Hoofdschakelaar: TSBridgeConfig.Audit.Enabled in config/config.lua.
TSBridgeAuditConfig.Webhooks = {
    payments = '', -- Geslaagde persoonlijke geldacties.
    societies = '', -- Geslaagde society-transacties.
    invoices = '', -- Aangemaakte facturen; dit betekent niet dat ze zijn betaald.
    errors = '', -- Mislukte geldacties, facturen en saldo-/factuuropvragingen; geen algemene consolelogger.
}
