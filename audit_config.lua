-- Alleen server-side. Leeg = logging voor deze categorie uit.
-- Dezelfde Discord-webhook mag bij meerdere categorieën staan.
TSBridgeAuditConfig = {
    Version = '1.0.0',
    Enabled = true,
    Webhooks = {
        payments = '', -- succesvolle bij-/afschrijvingen bij spelers
        societies = '', -- succesvolle society-transacties
        invoices = '', -- aangemaakte facturen (niet betaald)
        errors = '', -- mislukte geldacties, facturen en saldo-/factuuropvragingen
    }
}
