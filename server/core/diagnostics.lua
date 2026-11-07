local function diagnostics()
    local result = { version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0),
        configValid = not TSBridgeValidation or TSBridgeValidation.valid,
        configErrors = TSBridgeValidation and TSBridgeValidation.errors or {}, resources = {} }
    if not result.configValid then return result end
    result.framework = TSBridgeServer.Framework
    local names = { 'ox_lib', TSBridgeConfig.TargetResource, TSBridgeServer.InventoryResource, TSBridgeServer.SocietyResource }
    if TSBridgeServer.Framework == 'esx' then names[#names+1] = TSBridgeServer.ESXResource end
    if TSBridgeServer.Screenshots then names[#names+1] = TSBridgeServer.ScreenshotResource end
    for _, key in ipairs({ 'Banking', 'Billing' }) do
        local cfg = TSBridgeServer[key]
        if cfg.Provider ~= 'none' and cfg.Provider ~= 'esx' and cfg.Resource ~= '' then names[#names+1] = cfg.Resource end
    end
    for _, name in ipairs(names) do result.resources[name] = GetResourceState(name) end
    result.billing = TSBridge and TSBridge.BillingStatus and TSBridge.BillingStatus() or { ready=false, reason='billing_unavailable' }
    result.webhooks = TSBridgeWebhookStatus and TSBridgeWebhookStatus() or nil
    local update = TSBridgeServer.UpdateCheck or { Enabled=true, Repository='troyscripts/ts_brigde' }
    result.updateCheckConfigured = update.Enabled == true and update.Repository ~= ''
    return result
end
exports('GetDiagnostics', diagnostics)
RegisterCommand('ts_bridge_check', function(src)
    if src ~= 0 then return end
    local d = diagnostics()
    print(('[ts_bridge] %s | config: %s'):format(d.version or '?', d.configValid and 'OK' or TSL('runtime_error')))
    for _, field in ipairs(d.configErrors) do print(TSL('validation_error'):format(field)) end
    if not d.configValid then return end
    for name, state in pairs(d.resources) do print(('[ts_bridge] %s: %s'):format(name, state)) end
    print(('[ts_bridge] billing %s: %s (%s)'):format(d.billing.provider or '?', tostring(d.billing.ready), d.billing.reason or TSL('runtime_no_adapter_error')))
    if d.webhooks then print((TSL('runtime_ts_bridge_logs_d_d_screenshots_d_destinations_d')):format(
        d.webhooks.queued, d.webhooks.capacity, d.webhooks.pendingPhotos, d.webhooks.destinations)) end
    if d.webhooks then
        print(TSL('runtime_ts_bridge_last_screenshot') .. (d.webhooks.lastPhoto or TSL('runtime_unknown')))
        print(TSL('runtime_ts_bridge_last_discord_result') .. (d.webhooks.lastDelivery or TSL('runtime_unknown')))
        print(TSL('runtime_ts_bridge_last_discord_error') .. (d.webhooks.lastFailure or TSL('runtime_none')))
    end
    if d.webhooks then
        local totals = d.webhooks.deliveries or {}
        print(('[ts_bridge] Discord: bevestigd=%d | HTTP zonder bevestiging=%d | mislukt=%d | 429-pogingen=%d | foto-tekstfallback=%d'):format(
            totals.confirmed or 0, totals.unconfirmed or 0, totals.failed or 0,
            totals.rateLimited or 0, totals.photoFallbacks or 0))
        local owners = {}
        for owner in pairs(d.webhooks.configuredRoutes or {}) do owners[#owners + 1] = owner end
        table.sort(owners)
        for _, owner in ipairs(owners) do
            local routes = {}
            for route, enabled in pairs(d.webhooks.configuredRoutes[owner]) do
                if enabled then routes[#routes + 1] = route end
            end
            table.sort(routes)
            print(('[ts_bridge] Webhookroutes %s: %s'):format(owner, table.concat(routes, ', ')))
        end
        local audit = {}
        for route, enabled in pairs(d.webhooks.auditRoutes or {}) do
            if enabled then audit[#audit + 1] = route end
        end
        table.sort(audit)
        if #audit > 0 then print('[ts_bridge] Auditwebhooks: ' .. table.concat(audit, ', ')) end
    end
    print((TSL('runtime_ts_bridge_github_configured_s')):format(tostring(d.updateCheckConfigured)))
end, false)

