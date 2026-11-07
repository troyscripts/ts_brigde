-- Alleen expliciete kentekenlezers; overschrijft geen FiveM-native of inventory-ID.
TSBridgePlate = {}
function TSBridgePlate.GetFakeState(vehicle)
    local cfg = TSBridgeConfig.Vehicles and TSBridgeConfig.Vehicles.SkyFakePlates
    if not cfg or not cfg.Enabled or not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
    local state = Entity(vehicle).state[cfg.StateKey]
    if type(state) == 'table' and state.active == true then return state end
end
function TSBridgePlate.GetReal(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return '' end
    local state = TSBridgePlate.GetFakeState(vehicle)
    if state and type(state.realPlate) == 'string' then
        local plate = state.realPlate:match('^%s*(.-)%s*$'):upper()
        if #plate > 0 and #plate <= 8 and not plate:find('%c') then return plate end
    end
    return GetVehicleNumberPlateText(vehicle)
end
exports('GetVehicleRealPlate', TSBridgePlate.GetReal)
exports('HasVehicleFakePlate', function(vehicle) return TSBridgePlate.GetFakeState(vehicle) ~= nil end)
