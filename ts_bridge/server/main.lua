local function getJob(id)
    if TSBridgeServer.Framework == 'standalone' then return nil end
    if TSBridgeServer.Framework ~= 'esx' then return nil, 'onbekend framework' end
    if GetResourceState(TSBridgeServer.ESXResource) ~= 'started' then return nil, 'ESX niet gestart' end
    local ok, job = pcall(function()
        local esx = exports[TSBridgeServer.ESXResource]:getSharedObject()
        local player = esx.GetPlayerFromId(tonumber(id))
        if not player then return nil end
        local value = type(player.getJob) == 'function' and player.getJob() or player.job
        if type(value) == 'string' then value = { name = value } end
        if type(value) ~= 'table' or type(value.name) ~= 'string' then return nil end
        return { name = value.name, grade = tonumber(value.grade) or 0, label = value.label, grade_label = value.grade_label }
    end)
    if not ok then return nil, 'ESX spelercontrole mislukt' end
    return job
end
exports('GetJob', getJob)
exports('Notify', function(id, data)
    id = tonumber(id)
    if not id or id <= 0 or not GetPlayerName(id) then return false end
    TriggerClientEvent('ts_bridge:notify', id, data)
    return true
end)
exports('AlertJobs', function(jobs, data, coords, seconds)
    if type(jobs) ~= 'table' or type(data) ~= 'table' or type(coords) ~= 'table' then return 0 end
    for _, key in ipairs({ 'x', 'y', 'z' }) do
        local n = coords[key]
        if type(n) ~= 'number' or n ~= n or math.abs(n) == math.huge then return 0 end
    end
    local recipients = 0
    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        local job = id and getJob(id)
        if job and jobs[job.name] == true then
            TriggerClientEvent('ts_bridge:jobAlert', id, data, coords, seconds)
            recipients = recipients + 1
        end
    end
    return recipients
end)
RegisterCommand('ts_bridge_check', function(src)
    if src ~= 0 then return end
    print('[Troy Scripts] ts_bridge 0.0.1(BETA) | framework: ' .. TSBridgeServer.Framework)
    for _, name in ipairs({ 'ox_lib', TSBridgeServer.ESXResource, TSBridgeConfig.TargetResource, TSBridgeServer.ScreenshotResource, TSBridgeServer.InventoryResource, TSBridgeServer.SocietyResource, TSBridgeServer.Banking.Resource, TSBridgeServer.Billing.Resource }) do
        print(('[ts_bridge] %s: %s'):format(name, GetResourceState(name)))
    end
end, false)
print('^5[Troy Scripts]^7 ts_bridge 0.0.1(BETA) gestart')
