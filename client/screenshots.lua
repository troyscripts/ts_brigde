if TSBridgeValidation and not TSBridgeValidation.valid then return end
local busy = false
local photoCam
local function restorePhotoCamera()
    if not photoCam then return end
    local cam = photoCam
    photoCam = nil
    if GetRenderingCam() == cam then RenderScriptCams(false, false, 0, true, true) end
    if DoesCamExist(cam) then DestroyCam(cam, false) end
end
AddEventHandler('onClientResourceStop', function(name)
    if name == GetCurrentResourceName() then restorePhotoCamera() end
end)
RegisterNetEvent('ts_bridge:screenshot:capture', function(token, resource, maxBytes, timeoutMs, vehicleNetId, vehiclePlate)
    -- Alleen de server mag een opname aanvragen.
    if source ~= 65535 then return end
    if type(token) ~= 'string' or type(resource) ~= 'string' then return end
    if type(maxBytes) ~= 'number' or maxBytes <= 0 or type(timeoutMs) ~= 'number' then return end
    local function fail(reason)
        TriggerServerEvent('ts_bridge:screenshot:result', token, nil, reason)
    end
    if busy then fail('busy'); return end
    if GetResourceState(resource) ~= 'started' then fail('unavailable'); return end
    busy = true
    local finished = false
    local function complete(data, failure)
        if finished then return end
        finished = true
        busy = false
        restorePhotoCamera()
        if failure then fail(failure); return end
        if type(data) ~= 'string' or #data > math.ceil(maxBytes / 3) * 4 + 64
            or not data:match('^data:image/jpe?g;base64,') then
            fail('invalid'); return
        end
        -- Begrensde overdracht zonder het normale eventkanaal met een grote foto te blokkeren.
        TriggerLatentServerEvent('ts_bridge:screenshot:result', 1000000, token, data)
    end
    SetTimeout(math.max(100, math.min(vehicleNetId and 19000 or 6000, timeoutMs - 500)), function()
        complete(nil, 'timeout')
    end)
    local function capture()
        local ok = pcall(function()
            exports[resource]:requestScreenshot({ encoding = 'jpg', quality = 0.65 }, function(data)
                complete(data)
            end)
        end)
        if not ok then complete(nil, 'capture') end
    end
    if not vehicleNetId then capture(); return end
    CreateThread(function()
        local ok = pcall(function()
            -- Wacht tot het kastje/menu dicht is: geen foto van de inventory-overlay.
            while not finished and ((LocalPlayer.state and LocalPlayer.state.invOpen) or IsNuiFocused() or IsPauseMenuActive()) do Wait(100) end
            if finished then return end
            local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
            local ped = PlayerPedId()
            if vehicle == 0 or not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2
                or IsEntityDead(ped) or GetEntitySpeed(vehicle) > 0.5
                or #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) > 12
                or type(vehiclePlate) ~= 'string'
                or GetVehicleNumberPlateText(vehicle):upper():match('^%s*(.-)%s*$') ~= vehiclePlate
                or not IsGameplayCamRendering() then complete(nil, 'vehicle_unavailable'); return end
            local minimum, maximum = GetModelDimensions(GetEntityModel(vehicle))
            local length = math.max(3.0, maximum.y - minimum.y)
            local point = GetOffsetFromEntityInWorldCoords(vehicle, length * 0.75, length * 0.85, math.max(1.6, maximum.z + 0.7))
            photoCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            SetCamCoord(photoCam, point.x, point.y, point.z)
            PointCamAtEntity(photoCam, vehicle, 0.0, 0.0, 0.4, true)
            SetCamFov(photoCam, 55.0)
            RenderScriptCams(true, false, 0, true, true)
            CreateThread(function()
                while photoCam and not finished do HideHudAndRadarThisFrame(); Wait(0) end
            end)
            Wait(250)
            if finished then return end
            if not DoesEntityExist(vehicle) or GetEntitySpeed(vehicle) > 0.5 then complete(nil, 'vehicle_unavailable'); return end
            capture()
        end)
        if not ok then complete(nil, 'capture') end
    end)
end)

