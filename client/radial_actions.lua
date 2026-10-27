if TSBridgeValidation and not TSBridgeValidation.valid then return end

-- Directe acties naast de bestaande submenu-API. Elke resource bezit eigen IDs.
local actions = {}
local function key(owner, id) return owner .. ':action:' .. id end
local function show(owner, id, data)
    lib.addRadialItem({ id = key(owner, id), label = data.label, icon = data.icon,
        onSelect = data.onSelect, keepOpen = data.keepOpen })
end
exports('RegisterRadialAction', function(data)
    local owner = GetInvokingResource()
    if not owner or type(data) ~= 'table' or type(data.id) ~= 'string'
        or data.id == '' or #data.id > 100 or type(data.label) ~= 'string'
        or data.label == '' or type(data.onSelect) ~= 'function'
        or (data.icon ~= nil and type(data.icon) ~= 'string')
        or (data.keepOpen ~= nil and type(data.keepOpen) ~= 'boolean') then return false end
    if GetResourceState('ox_lib') ~= 'started' then return false end
    local copy = { label = data.label, icon = data.icon or 'circle',
        onSelect = data.onSelect, keepOpen = data.keepOpen == true }
    show(owner, data.id, copy)
    actions[owner] = actions[owner] or {}
    actions[owner][data.id] = copy
    return true
end)
exports('RemoveRadialAction', function(id)
    local owner = GetInvokingResource()
    if not owner or type(id) ~= 'string' or not actions[owner] or not actions[owner][id] then return false end
    if GetResourceState('ox_lib') == 'started' then lib.removeRadialItem(key(owner, id)) end
    actions[owner][id] = nil
    return true
end)
AddEventHandler('onClientResourceStop', function(name)
    for owner, ids in pairs(actions) do
        if name == owner or name == GetCurrentResourceName() then
            if GetResourceState('ox_lib') == 'started' then
                for id in pairs(ids) do lib.removeRadialItem(key(owner, id)) end
            end
            actions[owner] = nil
        end
    end
end)
AddEventHandler('onClientResourceStart', function(name)
    if name ~= 'ox_lib' then return end
    for owner, ids in pairs(actions) do
        if GetResourceState(owner) == 'started' then
            for id, data in pairs(ids) do show(owner, id, data) end
        else actions[owner] = nil end
    end
end)
