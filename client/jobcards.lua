-- Deliberately no dependency: idcard may be missing, stopped or restarted independently.
exports('OpenJobCardDesk', function()
    local cfg = type(TSBridgeConfig.JobCards) == 'table' and TSBridgeConfig.JobCards or {}
    local ok, opened = false, false
    if cfg.Enabled == true and type(cfg.Resource) == 'string' and GetResourceState(cfg.Resource) == 'started' then
        ok, opened = pcall(function() return exports[cfg.Resource]:OpenJobCardDesk() end)
    end
    if ok and opened == true then return true end
    exports[GetCurrentResourceName()]:Notify({title=TSL('jobcards_title'),description=TSL('jobcards_unavailable'),type='error'})
    return false
end)
