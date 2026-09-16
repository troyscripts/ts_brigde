-- Alleen server-exports; geen client-triggerbare upload- of webhookevents.
local queue, processing, pendingPhotos = {}, false, 0
local function warning(message) print('^3[ts_bridge webhook] ' .. message .. '^7') end
local function urlValid(url)
    return type(url) == 'string' and (
        url:match('^https://discord%.com/api/webhooks/%d+/[%w_-]+$') ~= nil
        or url:match('^https://discord%.com/api/v%d+/webhooks/%d+/[%w_-]+$') ~= nil)
end
local alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local values = {}
for i = 1, #alphabet do values[alphabet:byte(i)] = i - 1 end
local function decodeJpeg(uri)
    if type(uri) ~= 'string' or #uri > math.ceil(TSBridgeServer.MaxImageBytes / 3) * 4 + 64 then return nil end
    local encoded = uri:match('^data:image/jpeg;base64,([A-Za-z0-9+/=]+)$')
        or uri:match('^data:image/jpg;base64,([A-Za-z0-9+/=]+)$')
    if not encoded or #encoded % 4 ~= 0 then return nil end
    local blocks = {}
    for i = 1, #encoded, 4 do
        local a, b, c, d = encoded:byte(i, i + 3)
        local x, y, z, w = values[a], values[b], values[c], values[d]
        if not x or not y or (not z and c ~= 61) or (not w and d ~= 61) then return nil end
        if (c == 61 or d == 61) and i ~= #encoded - 3 then return nil end
        if c == 61 and d ~= 61 then return nil end
        local n = (x << 18) | (y << 12) | ((z or 0) << 6) | (w or 0)
        local part = string.char((n >> 16) & 255)
        if c ~= 61 then part = part .. string.char((n >> 8) & 255) end
        if d ~= 61 then part = part .. string.char(n & 255) end
        blocks[#blocks + 1] = part
    end
    local bytes = table.concat(blocks)
    if #bytes > TSBridgeServer.MaxImageBytes or bytes:sub(1, 3) ~= '\255\216\255' then return nil end
    return bytes
end
local function bodyFor(item)
    if not item.image then return json.encode(item.payload), 'application/json' end
    -- Boundary mag niet voorkomen in de afbeelding.
    local boundary = 'tsBridgeBoundary' .. tostring(GetGameTimer())
    while item.image:find(boundary, 1, true) do boundary = boundary .. 'x' end
    local body = '--' .. boundary .. '\r\nContent-Disposition: form-data; name="payload_json"\r\nContent-Type: application/json\r\n\r\n'
        .. json.encode(item.payload) .. '\r\n--' .. boundary
        .. '\r\nContent-Disposition: form-data; name="files[0]"; filename="screenshot.jpg"\r\nContent-Type: image/jpeg\r\n\r\n'
        .. item.image .. '\r\n--' .. boundary .. '--\r\n'
    return body, 'multipart/form-data; boundary=' .. boundary
end
local pump
pump = function()
    if processing or #queue == 0 then return end
    processing = true
    local item = queue[1]
    local body, contentType = bodyFor(item)
    local responded = false
    local function done(status, response)
        if responded then return end
        responded = true
        if status == 429 and item.retries < 3 then
            item.retries = item.retries + 1
            local ok, data = pcall(json.decode, response or '')
            local seconds = ok and type(data) == 'table' and tonumber(data.retry_after) or 2
            if not seconds or seconds ~= seconds then seconds = 2 end
            SetTimeout(math.floor(math.max(1, math.min(seconds, 60)) * 1000), function()
                processing = false; pump()
            end)
            return
        end
        if status < 200 or status >= 300 then warning('Versturen mislukt (HTTP ' .. tostring(status) .. '). Controleer de server-side webhookinstellingen; URL wordt niet gelogd.') end
        table.remove(queue, 1)
        SetTimeout(1000, function() processing = false; pump() end)
    end
    local ok = pcall(PerformHttpRequest, item.url, function(status, response) done(tonumber(status) or 0, response) end,
        'POST', body, { ['Content-Type'] = contentType }, { followLocation = false })
    if not ok then done(0, '') end
    -- Geen automatische POST-herhaling bij time-outs: voorkomt dubbele Discord-logs.
    SetTimeout(30000, function() done(0, '') end)
end
local function enqueue(url, payload, image)
    if #queue >= TSBridgeServer.MaxQueue then warning('Wachtrij vol; log overgeslagen.'); return false end
    queue[#queue + 1] = { url = url, payload = payload, image = image, retries = 0 }
    pump()
    return true
end

exports('SendWebhook', function(route, fallbackUrl, payload, options)
    local owner = GetInvokingResource()
    if not owner then return false, 'geen aanroepende resource' end
    local routes = TSBridgeServer.Webhooks[owner] or {}
    local url = routes[route]
    if type(url) ~= 'string' or url == '' then url = fallbackUrl end
    if url == '' or url == nil then return false, 'geen webhook ingesteld' end
    if not urlValid(url) then warning('Ongeldige Discord-webhook voor ' .. owner); return false, 'ongeldige URL' end
    if type(payload) ~= 'table' or type(payload.embeds) ~= 'table' or type(payload.embeds[1]) ~= 'table' then
        return false, 'embed ontbreekt'
    end
    if #queue + pendingPhotos >= TSBridgeServer.MaxQueue then warning('Wachtrij vol; log overgeslagen.'); return false, 'wachtrij vol' end
    -- Eigen kopie: async screenshotcallbacks mogen de invoer van de aanroeper niet wijzigen.
    local ok, copied = pcall(function() return json.decode(json.encode(payload)) end)
    if not ok or type(copied) ~= 'table' then return false, 'ongeldige payload' end
    payload = copied
    payload.allowed_mentions = { parse = {} }
    options = type(options) == 'table' and options or {}
    local embed = payload.embeds[1]
    local id = tonumber(options.playerId)
    if not options.screenshot then return enqueue(url, payload) end
    local function unavailable(reason)
        embed.description = 'Screenshot niet beschikbaar (' .. reason .. '); actie wel geregistreerd.'
        warning(owner .. ': ' .. reason)
        return enqueue(url, payload)
    end
    if not TSBridgeServer.Screenshots then return unavailable('screenshots uitgeschakeld in ts_bridge') end
    if GetResourceState(TSBridgeServer.ScreenshotResource) ~= 'started' then return unavailable('screenshotresource niet gestart') end
    if not id or id <= 0 or not GetPlayerName(id) then return unavailable('speler niet online') end
    pendingPhotos = pendingPhotos + 1
    local completed = false
    local function complete(image, reason)
        if completed then return end
        completed = true
        pendingPhotos = pendingPhotos - 1
        if image then
            embed.image = { url = 'attachment://screenshot.jpg' }
            payload.attachments = { { id = 0, filename = 'screenshot.jpg' } }
        else
            embed.description = 'Screenshot niet beschikbaar; actie wel geregistreerd.'
            warning(owner .. ': ' .. (reason or 'screenshot mislukt'))
        end
        enqueue(url, payload, image)
    end
    SetTimeout(TSBridgeServer.ScreenshotTimeoutMs, function() complete(nil, 'screenshot time-out') end)
    local requested = pcall(function()
        exports[TSBridgeServer.ScreenshotResource]:requestClientScreenshot(id, { encoding = 'jpg', quality = 0.65 }, function(err, data)
            if completed then return end
            if err then complete(nil, 'screenshotprovider meldt een fout'); return end
            local image = decodeJpeg(data)
            complete(image, image and nil or 'ongeldig of te groot JPEG-antwoord')
        end)
    end)
    if not requested then complete(nil, 'screenshotexport kon niet worden aangeroepen') end
    return true
end)
