local function notify(data)
    if type(data) == 'string' then data = { description = data } end
    if type(data) ~= 'table' then return false end
    data.title = data.title or TSBridgeConfig.NotificationTitle
    data.duration = data.duration or TSBridgeConfig.NotificationDuration
    lib.notify(data)
    return true
end
exports('Notify', notify)
RegisterNetEvent('ts_bridge:notify', function(data)
    if source ~= 65535 then return end
    notify(data)
end)
exports('IsDead', function(ped)
    ped = ped or PlayerPedId()
    if IsEntityDead(ped) or IsPedFatallyInjured(ped) then return true end
    if ped == PlayerPedId() then
        for _, key in ipairs(TSBridgeConfig.DeadStateKeys) do
            if LocalPlayer.state[key] == true then return true end
        end
    end
    return false
end)

-- Registreer opties namens de aanroeper en ruim ze op als die resource stopt.
local registered = {}
local function remove(kind, names)
    if GetResourceState(TSBridgeConfig.TargetResource) ~= 'started' then return end
    if kind == 'player' then exports[TSBridgeConfig.TargetResource]:removeGlobalPlayer(names)
    else exports[TSBridgeConfig.TargetResource]:removeGlobalVehicle(names) end
end
local function add(kind, options)
    local owner = GetInvokingResource()
    if not owner or type(options) ~= 'table' then return false end
    if GetResourceState(TSBridgeConfig.TargetResource) ~= 'started' then return false end
    local names = {}
    for _, option in ipairs(options) do
        if type(option.name) ~= 'string' or option.name:sub(1, #owner + 1) ~= owner .. '_' then
            error(TSL('main_targetopties_moeten_een_unieke_naam_met_resourceprefix') .. owner .. '_')
        end
        names[#names + 1] = option.name
    end
    if kind == 'player' then exports[TSBridgeConfig.TargetResource]:addGlobalPlayer(options)
    else exports[TSBridgeConfig.TargetResource]:addGlobalVehicle(options) end
    registered[owner] = registered[owner] or {}
    for _, name in ipairs(names) do registered[owner][name] = kind end
    return true
end
exports('AddGlobalPlayer', function(options) return add('player', options) end)
exports('AddGlobalVehicle', function(options) return add('vehicle', options) end)
local function removeOwned(kind, name)
    local owner = GetInvokingResource()
    if not owner or not registered[owner] or registered[owner][name] ~= kind then return false end
    remove(kind, name)
    registered[owner][name] = nil
    return true
end
exports('RemoveGlobalPlayer', function(name) return removeOwned('player', name) end)
exports('RemoveGlobalVehicle', function(name) return removeOwned('vehicle', name) end)
exports('GetTargetResource', function() return TSBridgeConfig.TargetResource end)
AddEventHandler('onClientResourceStop', function(name)
    if name == TSBridgeConfig.TargetResource then registered = {}; return end
    for owner, options in pairs(registered) do
        if name == owner or name == GetCurrentResourceName() then
            for option, kind in pairs(options) do remove(kind, option) end
            registered[owner] = nil
        end
    end
end)
