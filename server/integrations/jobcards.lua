-- Server-side authority stays in the resource that owns the current persisted desk positions.
exports('IsAtKeycardDesk', function(src)
    local cfg = type(TSBridgeConfig.JobCards) == 'table' and TSBridgeConfig.JobCards or {}
    if cfg.Enabled ~= true or type(cfg.KeycardResource) ~= 'string'
        or GetResourceState(cfg.KeycardResource) ~= 'started' then return false end
    if type(src) ~= 'number' or src < 1 or src % 1 ~= 0 then return false end
    local ok, allowed = pcall(function() return exports[cfg.KeycardResource]:IsAtJobCardDesk(src) end)
    return ok and allowed == true
end)
