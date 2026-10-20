-- ALLE WEBHOOK-URLs. Dit bestand wordt uitsluitend server-side geladen.
-- Leeg = geen centrale route; aangesloten scripts mogen hun eigen URL gebruiken.
TSBridgeServer.Webhooks = {
    ts_hostage = { start = '', actions = '' },
    ts_nlplates = { created = '', replacement = '', registration = '' }
}

-- Eigen bridge-logs. Leeg = categorie uit. Dezelfde URL mag bij meerdere categorieën.
-- Algemene aan/uit-schakelaar: TSBridgeConfig.Audit.Enabled in config.lua.
TSBridgeAuditConfig.Webhooks = {
    payments = '', -- geslaagde persoonlijke geldacties
    societies = '', -- geslaagde society-transacties
    invoices = '', -- aangemaakte facturen (niet betaald)
    errors = '', -- mislukte geldacties, facturen en saldo-/factuuropvragingen
}
