-- De server stuurt uitsluitend politieagenten de positie bij de start.
local pendingLocation, expiresAt

RegisterNetEvent('ts_bridge:jobAlert', function(data, coords, waypointSeconds)
    if source ~= 65535 then return end -- uitsluitend afkomstig van de server
    if type(data) ~= 'table' or type(coords) ~= 'table'
        or type(coords.x) ~= 'number' or type(coords.y) ~= 'number'
        or type(coords.z) ~= 'number' then return end

    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(streetHash) or ''
    local crossing = crossingHash ~= 0 and GetStreetNameFromHashKey(crossingHash) or ''
    local zoneCode = GetNameOfZone(coords.x, coords.y, coords.z)
    local zone = zoneCode and GetLabelText(zoneCode) or ''
    if zone == 'NULL' or zone == '' then zone = zoneCode or '' end

    local location = street
    if crossing ~= '' and crossing ~= street then
        location = location ~= '' and (location .. ' / ' .. crossing) or crossing
    end
    if zone ~= '' then
        location = location ~= '' and (location .. ' (' .. zone .. ')') or zone
    end
    if location == '' then
        location = (TSL('alerts_')):format(coords.x, coords.y)
    end
    local seconds = math.max(1, math.min(tonumber(waypointSeconds) or 60, 600))
    pendingLocation = { x = coords.x, y = coords.y }
    expiresAt = GetGameTimer() + seconds * 1000
    data.description = (data.description or '') .. TSL('alerts_locatie') .. location
        .. (TSL('alerts_gebruik_je_waypointtoets_standaard_seconden')):format(TSBridgeConfig.WaypointKey, seconds)
    lib.notify(data)
    print(TSL('alerts_troyscripts_politiemelding_ontvangen_locatie') .. location)
end)

RegisterCommand('ts_bridge_waypoint', function()
    if not pendingLocation then return end
    if GetGameTimer() > expiresAt then
        pendingLocation = nil
        return
    end
    SetNewWaypoint(pendingLocation.x, pendingLocation.y)
    pendingLocation = nil
    lib.notify({
        title = TSL('alerts_politiemelding'),
        description = TSL('alerts_waypoint_ingesteld_naar_de_gemelde_locatie'),
        type = 'success',
        duration = 4000
    })
end, false)
RegisterKeyMapping('ts_bridge_waypoint', TSL('alerts_troy_scripts_waypoint_naar_laatste_melding'), 'keyboard', TSBridgeConfig.WaypointKey)
